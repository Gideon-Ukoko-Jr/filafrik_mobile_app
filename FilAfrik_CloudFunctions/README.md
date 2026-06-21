# FilAfrik Founders Circle — Cloud Functions

Complete Firebase Cloud Functions for the summit MVP.

---

## Functions Included

| Function | Trigger | Purpose |
|---|---|---|
| `generateAiResources` | HTTP Callable | Calls Claude API, returns grants/tools/tips, caches result |
| `onUserCreated` | Auth trigger | Sends welcome notification on registration |
| `onBusinessApproved` | Firestore trigger | Notifies same-industry founders when a business is listed |
| `onAccreditationGranted` | Firestore trigger | Notifies owner when business is accredited |
| `onNewPost` | Firestore trigger | Updates room metadata on new post |
| `onNewComment` | Firestore trigger | Notifies post author of new comment |
| `cleanupExpiredNotifications` | Scheduled daily | Deletes notifications older than 30 days |
| `cleanupExpiredAiSessions` | Scheduled weekly | Deletes stale AI cache sessions |
| `adminPostAnnouncement` | HTTP Callable | Admin only — broadcasts announcement to all members |

---

## Setup — Do This Once

### Step 1 — Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### Step 2 — Link your Firebase project
```bash
firebase use --add
# Select your project: filafrik-founders-circle
```

### Step 3 — Store the Anthropic API key securely
The API key must NEVER be in your Flutter code or committed to Git.
Store it in Firebase Secret Manager:
```bash
firebase functions:secrets:set ANTHROPIC_API_KEY
# Paste your Anthropic API key when prompted
# Get your key from: https://console.anthropic.com
```

Verify it was stored:
```bash
firebase functions:secrets:access ANTHROPIC_API_KEY
```

### Step 4 — Install dependencies
```bash
cd functions
npm install
```

### Step 5 — Build TypeScript
```bash
npm run build
```

### Step 6 — Deploy everything
```bash
# Deploy functions + Firestore rules + indexes
firebase deploy --only functions,firestore
```

Or deploy just functions during development:
```bash
firebase deploy --only functions
```

---

## Local Development with Emulators

```bash
# Start emulators (Firestore + Functions + UI dashboard)
firebase emulators:start

# Open emulator UI
http://localhost:4000
```

Set this environment variable so the Flutter app hits local emulators:
```dart
// In main.dart — before runApp()
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
```

---

## Flutter Integration — AI Copilot

Call the function from Flutter like this:

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<Map<String, dynamic>> generateAiResources(UserModel user) async {
  final callable = FirebaseFunctions.instance
      .httpsCallable('generateAiResources');

  final result = await callable.call({
    'uid': user.uid,
    'displayName': user.displayName,
    'businessName': user.businessName,
    'industry': user.industry,
    'businessStage': user.businessStage,
    'needs': user.needs,
    'bio': user.bio,
    'city': user.city,
  });

  return result.data as Map<String, dynamic>;
}
```

The response shape:
```json
{
  "grants": [
    {
      "name": "CDAP Grant",
      "amount": "Up to $15,000",
      "deadline": "March 2026",
      "description": "...",
      "eligibility": "...",
      "url": "https://...",
      "relevanceScore": 9
    }
  ],
  "tools": [ { "name": "...", "category": "...", "description": "...", "url": "...", "isFree": true } ],
  "tips": [ { "title": "...", "body": "...", "category": "funding" } ],
  "generatedAt": "2026-05-18T...",
  "cachedUntil": "2026-05-25T...",
  "fromCache": false
}
```

---

## Flutter Integration — Admin Announcement

```dart
Future<void> postAnnouncement(String title, String content) async {
  final callable = FirebaseFunctions.instance
      .httpsCallable('adminPostAnnouncement');

  final result = await callable.call({
    'title': title,
    'content': content,
    'isPinned': false,
    'ctaLabel': 'Learn More',   // optional
    'ctaUrl': 'https://...',    // optional
  });

  final data = result.data as Map<String, dynamic>;
  print('Sent ${data['notificationsSent']} notifications');
}
```

---

## Caching Behaviour

The `generateAiResources` function caches results for **7 days** per user.

Cache is invalidated when the user changes:
- Industry
- Business stage
- Needs selection

The cache key is an MD5 hash of these three fields. When the user taps "Refresh"
in the app, call the function with `forceRefresh: true` (add this field to the
callable data and the function will skip the cache check).

---

## Cost Estimates (Free Tier)

Firebase Spark (free) limits:
- Cloud Functions: 2M invocations/month — far more than enough for MVP
- Firestore reads: 50,000/day — sufficient for the summit

Claude API costs (approximate):
- Each `generateAiResources` call: ~1,500 input tokens + ~600 output tokens
- Cost per call: ~$0.003 (less than half a cent)
- 100 users refreshing once per week: ~$0.30/week

Keep the 7-day cache to minimise API calls.

---

## Secrets — Never Commit These

Add to `.gitignore`:
```
.env
.env.local
*.key
service-account*.json
```

The `ANTHROPIC_API_KEY` is stored in Firebase Secret Manager only.
Never put it in `.env`, `firebase.json`, or any file committed to Git.

---

## Deployment Checklist Before Summit

- [ ] `firebase functions:secrets:set ANTHROPIC_API_KEY` done
- [ ] `firebase deploy --only functions,firestore` succeeded
- [ ] Test `generateAiResources` from Flutter emulator
- [ ] Test `onUserCreated` by registering a test account
- [ ] Test `adminPostAnnouncement` from admin account
- [ ] Verify indexes deployed: Firebase Console > Firestore > Indexes
- [ ] Verify security rules deployed: Firebase Console > Firestore > Rules
