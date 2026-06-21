/**
 * FilAfrik Founders Circle — Firebase Cloud Functions
 * ─────────────────────────────────────────────────────────────────────────────
 * All functions in one file for simplicity during the summit MVP build.
 * The Claude API key lives ONLY here — never in the Flutter app.
 *
 * Deploy:  firebase deploy --only functions
 * Emulate: firebase emulators:start --only functions,firestore
 * Logs:    firebase functions:log
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Anthropic from "@anthropic-ai/sdk";
import { createHash } from "crypto";

// ── INIT ──────────────────────────────────────────────────────────────────────
admin.initializeApp();
const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });

// ── TYPES ─────────────────────────────────────────────────────────────────────

interface FounderProfile {
  uid: string;
  displayName: string;
  businessName: string;
  industry: string;
  businessStage: string;
  needs: string[];
  bio?: string;
  city?: string;
}

interface GrantResource {
  name: string;
  amount: string;
  deadline: string;
  description: string;
  eligibility: string;
  url: string;
  relevanceScore: number; // 1-10 — how well it matches this founder
}

interface ToolResource {
  name: string;
  category: string;
  description: string;
  url: string;
  isFree: boolean;
}

interface FounderTip {
  title: string;
  body: string;
  category: string; // 'funding' | 'growth' | 'networking' | 'operations'
}

interface AiResourcesResult {
  grants: GrantResource[];
  tools: ToolResource[];
  tips: FounderTip[];
  generatedAt: string;
  cachedUntil: string;
}

interface AiSessionDoc {
  promptHash: string;
  content: AiResourcesResult;
  generatedAt: admin.firestore.Timestamp;
  expiresAt: admin.firestore.Timestamp;
}

// ── CONSTANTS ─────────────────────────────────────────────────────────────────

const CACHE_DAYS = 7;
const MAX_RETRIES = 2;
const SESSION_COLLECTION = "ai_sessions";
const CLAUDE_MODEL = "claude-sonnet-4-20250514";

// ── HELPERS ───────────────────────────────────────────────────────────────────

/**
 * Hash the founder's profile to detect stale cache.
 * If the user changes their industry or needs, we regenerate.
 */
function buildPromptHash(profile: FounderProfile): string {
  const key = `${profile.industry}|${profile.businessStage}|${profile.needs.sort().join(",")}|${profile.city || ""}`;
  return createHash("md5").update(key).digest("hex");
}

/**
 * Build the prompt sent to Claude.
 * Instructs Claude to return strict JSON with real, Canadian resources.
 */
function buildPrompt(profile: FounderProfile): string {
  return `You are a business resource advisor for African diaspora entrepreneurs in Canada, specifically in Ontario. You have deep knowledge of Canadian federal and Ontario provincial programs.

FOUNDER PROFILE:
- Name: ${profile.displayName}
- Business: ${profile.businessName}
- Industry: ${profile.industry}
- Stage: ${profile.businessStage}
- Primary needs: ${profile.needs.join(", ")}
- Location: ${profile.city || "Ontario, Canada"}
- Bio: ${profile.bio || "Not provided"}

TASK:
Generate highly personalised, real, currently available resources for this specific founder.

STRICT REQUIREMENTS:
1. All grants and programs must be REAL and available in Canada (federal or Ontario)
2. Relevance scores must reflect genuine fit with this founder's profile
3. Tools must be appropriate for their stage and industry
4. Tips must be specific and actionable — not generic advice
5. URLs must be real government or official organization URLs

Return ONLY a valid JSON object with NO markdown fences, NO preamble:

{
  "grants": [
    {
      "name": "Full official program name",
      "amount": "Exact funding amount e.g. Up to $15,000",
      "deadline": "Specific deadline or Rolling",
      "description": "2-3 sentence description of what the program funds and why it fits this founder",
      "eligibility": "Key eligibility criteria that this founder meets",
      "url": "https://real-official-url.gc.ca",
      "relevanceScore": 8
    }
  ],
  "tools": [
    {
      "name": "Tool name",
      "category": "Category e.g. Financial Planning, CRM, Marketing",
      "description": "How this specific tool helps at their stage and industry",
      "url": "https://tool-website.com",
      "isFree": true
    }
  ],
  "tips": [
    {
      "title": "Specific actionable tip title",
      "body": "2-3 sentence specific advice for this founder based on their industry, stage, and needs",
      "category": "funding"
    }
  ]
}

Return exactly 5 grants, 5 tools, and 4 tips. Sort grants by relevanceScore descending.
The category field in tips must be one of: funding, growth, networking, operations.`;
}

/**
 * Call Claude API with retry logic.
 */
async function callClaude(
  client: Anthropic,
  prompt: string,
  attempt = 0
): Promise<AiResourcesResult> {
  try {
    const response = await client.messages.create({
      model: CLAUDE_MODEL,
      max_tokens: 2000,
      messages: [{ role: "user", content: prompt }],
    });

    const rawText = response.content
      .filter((b) => b.type === "text")
      .map((b) => (b as { type: "text"; text: string }).text)
      .join("");

    // Strip any accidental markdown fences
    const cleaned = rawText
      .replace(/^```json\s*/i, "")
      .replace(/^```\s*/i, "")
      .replace(/\s*```$/i, "")
      .trim();

    const parsed = JSON.parse(cleaned) as {
      grants: GrantResource[];
      tools: ToolResource[];
      tips: FounderTip[];
    };

    // Validate structure
    if (!Array.isArray(parsed.grants) || !Array.isArray(parsed.tools) || !Array.isArray(parsed.tips)) {
      throw new Error("Invalid response structure from Claude");
    }

    const now = new Date();
    const expiresAt = new Date(now.getTime() + CACHE_DAYS * 24 * 60 * 60 * 1000);

    return {
      grants: parsed.grants,
      tools: parsed.tools,
      tips: parsed.tips,
      generatedAt: now.toISOString(),
      cachedUntil: expiresAt.toISOString(),
    };
  } catch (err) {
    if (attempt < MAX_RETRIES) {
      functions.logger.warn(`Claude API attempt ${attempt + 1} failed, retrying...`, err);
      await new Promise((r) => setTimeout(r, 1000 * (attempt + 1)));
      return callClaude(client, prompt, attempt + 1);
    }
    throw err;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 1: generateAiResources
//  Called from Flutter via:
//  FirebaseFunctions.instance.httpsCallable('generateAiResources').call(data)
// ─────────────────────────────────────────────────────────────────────────────
export const generateAiResources = functions
  .runWith({
    timeoutSeconds: 60,
    memory: "256MB",
    secrets: ["ANTHROPIC_API_KEY"],
  })
  .https.onCall(async (data, context) => {

    // ── Auth check ──────────────────────────────────────────────────────────
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be signed in to access AI resources."
      );
    }

    const uid = context.auth.uid;

    // ── Validate input ──────────────────────────────────────────────────────
    const profile = data as FounderProfile;

    if (!profile.industry || !profile.businessStage || !Array.isArray(profile.needs) || profile.needs.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Profile must include industry, businessStage, and at least one need."
      );
    }

    // Force uid to match authenticated user — never trust client-provided uid
    profile.uid = uid;

    const promptHash = buildPromptHash(profile);

    // ── Check cache ─────────────────────────────────────────────────────────
    try {
      const sessionsRef = db
        .collection("users")
        .doc(uid)
        .collection(SESSION_COLLECTION);

      const cached = await sessionsRef
        .where("promptHash", "==", promptHash)
        .where("expiresAt", ">", admin.firestore.Timestamp.now())
        .limit(1)
        .get();

      if (!cached.empty) {
        const session = cached.docs[0].data() as AiSessionDoc;
        functions.logger.info(`Cache hit for user ${uid}`);
        return {
          ...session.content,
          fromCache: true,
        };
      }
    } catch (cacheErr) {
      // Cache miss is fine — continue to generate
      functions.logger.warn("Cache lookup failed, generating fresh", cacheErr);
    }

    // ── Call Claude ─────────────────────────────────────────────────────────
    functions.logger.info(`Generating AI resources for ${profile.businessName} (${profile.industry})`);

    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
      throw new functions.https.HttpsError(
        "internal",
        "AI service is not configured. Please contact FilAfrik support."
      );
    }

    const client = new Anthropic({ apiKey });
    const prompt = buildPrompt(profile);

    let result: AiResourcesResult;
    try {
      result = await callClaude(client, prompt);
    } catch (aiErr) {
      functions.logger.error("Claude API call failed", aiErr);
      throw new functions.https.HttpsError(
        "internal",
        "AI resource generation failed. Please try again in a moment."
      );
    }

    // ── Cache result ────────────────────────────────────────────────────────
    try {
      const now = admin.firestore.Timestamp.now();
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + CACHE_DAYS * 24 * 60 * 60 * 1000)
      );

      await db
        .collection("users")
        .doc(uid)
        .collection(SESSION_COLLECTION)
        .add({
          promptHash,
          content: result,
          generatedAt: now,
          expiresAt,
        } as AiSessionDoc);

      // Also create an ai_ready notification
      await db.collection("notifications").add({
        recipientId: uid,
        type: "ai_ready",
        title: "Your resources are ready",
        body: `We found ${result.grants.length} grants and ${result.tools.length} tools tailored for ${profile.businessName}.`,
        isRead: false,
        createdAt: now,
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
        ),
      });
    } catch (saveErr) {
      // Don't fail the request if caching fails — return result anyway
      functions.logger.warn("Failed to cache AI session", saveErr);
    }

    return { ...result, fromCache: false };
  });

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 2: onUserCreated
//  Fires automatically when a new user registers.
//  Creates a welcome notification.
// ─────────────────────────────────────────────────────────────────────────────
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  functions.logger.info(`New user registered: ${user.uid}`);

  const now = admin.firestore.Timestamp.now();
  const expires = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
  );

  await db.collection("notifications").add({
    recipientId: user.uid,
    type: "welcome",
    title: "Welcome to the Founders Circle 🌍",
    body: "You're now part of Canada's leading African founders community. Explore the directory, join a room, and check your personalised AI resources.",
    isRead: false,
    createdAt: now,
    expiresAt: expires,
  });
});

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 3: onBusinessApproved
//  Fires when a business isListed changes to true.
//  Notifies founders in the same industry.
// ─────────────────────────────────────────────────────────────────────────────
export const onBusinessApproved = functions.firestore
  .document("businesses/{businessId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only fire when isListed changes false → true
    if (before.isListed === after.isListed) return null;
    if (!after.isListed) return null;

    functions.logger.info(`Business approved: ${after.name} (${after.industry})`);

    const { businessId } = context.params;
    const now = admin.firestore.Timestamp.now();
    const expires = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    );

    // Find founders in the same industry (excluding the business owner)
    const usersSnap = await db
      .collection("users")
      .where("industry", "==", after.industry)
      .limit(100)
      .get();

    if (usersSnap.empty) return null;

    const batch = db.batch();
    let count = 0;

    usersSnap.docs.forEach((doc) => {
      if (doc.id === after.ownerId) return; // Skip the owner
      const notifRef = db.collection("notifications").doc();
      batch.set(notifRef, {
        recipientId: doc.id,
        type: "new_business",
        title: `New ${after.industry} business in the directory`,
        body: `${after.name} by ${after.ownerName} just joined the Founders Circle.`,
        businessId,
        isRead: false,
        createdAt: now,
        expiresAt: expires,
      });
      count++;
    });

    await batch.commit();
    functions.logger.info(`Sent new_business notifications to ${count} founders`);
    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 4: onAccreditationGranted
//  Fires when isAccredited changes false → true on a business.
//  Notifies the business owner.
// ─────────────────────────────────────────────────────────────────────────────
export const onAccreditationGranted = functions.firestore
  .document("businesses/{businessId}")
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only fire when isAccredited changes false → true
    if (before.isAccredited === after.isAccredited) return null;
    if (!after.isAccredited) return null;

    functions.logger.info(`Accreditation granted to: ${after.name}`);

    const now = admin.firestore.Timestamp.now();
    const expires = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 90 * 24 * 60 * 60 * 1000) // 90 days
    );

    // Update the user's isAccredited field
    await db.collection("users").doc(after.ownerId).update({
      isAccredited: true,
      updatedAt: now,
    });

    // Notify the owner
    await db.collection("notifications").add({
      recipientId: after.ownerId,
      type: "accreditation",
      title: "🏅 Your business is now Accredited!",
      body: `${after.name} has been granted FilAfrik Accredited status. You now have access to the Accredited Lounge and exclusive resources.`,
      businessId: change.after.id,
      isRead: false,
      createdAt: now,
      expiresAt: expires,
    });

    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 5: onNewPost
//  Fires when a new post is created.
//  Updates room metadata. Notifications can be added in Phase 2.
// ─────────────────────────────────────────────────────────────────────────────
export const onNewPost = functions.firestore
  .document("posts/{postId}")
  .onCreate(async (snap) => {
    const post = snap.data();
    const { roomId } = post;

    if (!roomId) return null;

    // Update room's lastPostAt and increment postCount
    await db
      .collection("rooms")
      .doc(roomId)
      .update({
        lastPostAt: admin.firestore.FieldValue.serverTimestamp(),
        postCount: admin.firestore.FieldValue.increment(1),
      });

    functions.logger.info(`New post in room '${roomId}' by ${post.authorName}`);
    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 6: onNewComment
//  Fires when a comment is added.
//  Increments comment count on the parent post.
// ─────────────────────────────────────────────────────────────────────────────
export const onNewComment = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snap, context) => {
    const { postId } = context.params;
    const comment = snap.data();

    // Increment commentCount on parent post
    await db.collection("posts").doc(postId).update({
      commentCount: admin.firestore.FieldValue.increment(1),
    });

    // Notify the post author (if not commenting on their own post)
    const postDoc = await db.collection("posts").doc(postId).get();
    if (!postDoc.exists) return null;

    const post = postDoc.data()!;
    if (post.authorId === comment.authorId) return null; // No self-notification

    const now = admin.firestore.Timestamp.now();
    const expires = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    );

    await db.collection("notifications").add({
      recipientId: post.authorId,
      type: "new_comment",
      title: `${comment.authorName} replied to your post`,
      body: comment.content.length > 80
        ? comment.content.substring(0, 80) + "..."
        : comment.content,
      postId,
      roomId: post.roomId,
      triggeredBy: comment.authorId,
      isRead: false,
      createdAt: now,
      expiresAt: expires,
    });

    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 7: cleanupExpiredNotifications
//  Runs daily at 2am UTC.
//  Deletes notifications older than 30 days to control Firestore size.
// ─────────────────────────────────────────────────────────────────────────────
export const cleanupExpiredNotifications = functions.pubsub
  .schedule("0 2 * * *")
  .timeZone("America/Toronto")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const expired = await db
      .collection("notifications")
      .where("expiresAt", "<", now)
      .limit(500)
      .get();

    if (expired.empty) {
      functions.logger.info("No expired notifications to clean up");
      return null;
    }

    const batch = db.batch();
    expired.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    functions.logger.info(`Deleted ${expired.docs.length} expired notifications`);
    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 8: cleanupExpiredAiSessions
//  Runs weekly on Sundays at 3am UTC.
//  Deletes stale AI cache sessions across all users.
// ─────────────────────────────────────────────────────────────────────────────
export const cleanupExpiredAiSessions = functions.pubsub
  .schedule("0 3 * * 0")
  .timeZone("America/Toronto")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    // Get all users
    const users = await db.collection("users").select().limit(500).get();
    let totalDeleted = 0;

    for (const userDoc of users.docs) {
      const expired = await db
        .collection("users")
        .doc(userDoc.id)
        .collection(SESSION_COLLECTION)
        .where("expiresAt", "<", now)
        .get();

      if (!expired.empty) {
        const batch = db.batch();
        expired.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        totalDeleted += expired.docs.length;
      }
    }

    functions.logger.info(`Cleaned up ${totalDeleted} expired AI sessions`);
    return null;
  });

// ─────────────────────────────────────────────────────────────────────────────
//  FUNCTION 9: adminPostAnnouncement
//  HTTP callable — admin only.
//  Creates an announcement document and sends notifications to all users.
// ─────────────────────────────────────────────────────────────────────────────
export const adminPostAnnouncement = functions
  .runWith({ timeoutSeconds: 120, memory: "256MB" })
  .https.onCall(async (data, context) => {

    // Verify caller is admin
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");
    }

    const callerDoc = await db.collection("users").doc(context.auth.uid).get();
    if (!callerDoc.exists || !callerDoc.data()!.isAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Admin access required.");
    }

    const { title, content, ctaLabel, ctaUrl, isPinned } = data as {
      title: string;
      content: string;
      ctaLabel?: string;
      ctaUrl?: string;
      isPinned?: boolean;
    };

    if (!title || !content) {
      throw new functions.https.HttpsError("invalid-argument", "Title and content are required.");
    }

    const now = admin.firestore.Timestamp.now();

    // Create announcement document
    const announcementRef = await db.collection("announcements").add({
      authorId: context.auth.uid,
      title,
      content,
      ctaLabel: ctaLabel || null,
      ctaUrl: ctaUrl || null,
      isPinned: isPinned || false,
      publishedAt: now,
      expiresAt: null,
    });

    // Send announcement notifications to all users in batches
    let totalSent = 0;
    let lastDoc: admin.firestore.QueryDocumentSnapshot | null = null;

    while (true) {
      let query = db.collection("users").select("uid").limit(500);
      if (lastDoc) query = query.startAfter(lastDoc);

      const batch_users = await query.get();
      if (batch_users.empty) break;

      const notifBatch = db.batch();
      const expires = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
      );

      batch_users.docs.forEach((doc) => {
        const notifRef = db.collection("notifications").doc();
        notifBatch.set(notifRef, {
          recipientId: doc.id,
          type: "announcement",
          title: `📢 ${title}`,
          body: content.length > 100 ? content.substring(0, 100) + "..." : content,
          announcementId: announcementRef.id,
          isRead: false,
          createdAt: now,
          expiresAt: expires,
        });
      });

      await notifBatch.commit();
      totalSent += batch_users.docs.length;
      lastDoc = batch_users.docs[batch_users.docs.length - 1];

      if (batch_users.docs.length < 500) break;
    }

    functions.logger.info(`Announcement posted: "${title}" — ${totalSent} notifications sent`);

    return {
      success: true,
      announcementId: announcementRef.id,
      notificationsSent: totalSent,
    };
  });
