import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../auth/domain/models/founder_profile.dart';
import '../domain/models/resource_item.dart';
import '../domain/repositories/resource_repository.dart';

class FirebaseResourceRepository implements ResourceRepository {
  FirebaseResourceRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Primary path: reads curated `resources` collection from Firestore.
  /// Also checks `users/{uid}/ai_sessions` for a cached AI result first.
  @override
  Future<ResourcesResult> getResources(FounderProfile profile) async {
    // 1. Check for a cached AI session (written by Cloud Function when deployed)
    final cached = await _cachedAiSession(profile.uid);
    if (cached != null) return cached;

    // 2. Fall back to curated Firestore collection
    return _curatedResources(profile);
  }

  /// Refresh: tries the Cloud Function for personalised AI results.
  /// Falls back silently to curated Firestore data if CF isn't deployed.
  @override
  Future<ResourcesResult> refreshResources(FounderProfile profile) async {
    try {
      final callable = _functions.httpsCallable(
        'generateAiResources',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 70)),
      );
      final result = await callable.call<Map<String, dynamic>>({
        'uid': profile.uid,
        'displayName': profile.displayName,
        'businessName': profile.businessName,
        'industry': profile.industry,
        'businessStage': profile.businessStage,
        'needs': profile.needs,
        'bio': profile.bio,
        'city': profile.city,
      });
      return ResourcesResult.fromMap(result.data);
    } catch (e) {
      debugPrint('[ResourceRepository] CF unavailable, using curated data: $e');
      return _curatedResources(profile);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<ResourcesResult?> _cachedAiSession(String uid) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('ai_sessions')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      final content =
          snap.docs.first.data()['content'] as Map<String, dynamic>?;
      if (content == null) return null;

      return ResourcesResult.fromMap({...content, 'fromCache': true});
    } catch (e) {
      debugPrint('[ResourceRepository] Cache lookup failed: $e');
      return null;
    }
  }

  Future<ResourcesResult> _curatedResources(FounderProfile profile) async {
    final snap = await _firestore
        .collection('resources')
        .where('active', isEqualTo: true)
        .orderBy('order')
        .get();

    final grants = <GrantResource>[];
    final tools = <ToolResource>[];
    final tips = <FounderTip>[];

    for (final doc in snap.docs) {
      final data = doc.data();
      final type = data['type'] as String?;

      // Include resources tagged 'all' or matching the user's industry
      final industries =
          List<String>.from(data['industries'] as List? ?? ['all']);
      final matchesIndustry = industries.contains('all') ||
          industries.any(
            (i) => i.toLowerCase() == profile.industry.toLowerCase(),
          );
      if (!matchesIndustry) continue;

      switch (type) {
        case 'grant':
          grants.add(GrantResource.fromMap(data));
        case 'tool':
          tools.add(ToolResource.fromMap(data));
        case 'tip':
          tips.add(FounderTip.fromMap(data));
      }
    }

    return ResourcesResult(
      grants: grants,
      tools: tools,
      tips: tips,
      generatedAt: DateTime.now().toIso8601String(),
      fromCache: false,
    );
  }
}
