import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../auth/domain/models/founder_profile.dart';
import '../../community/domain/models/community_message.dart';
import '../domain/models/admin_stats.dart';
import '../domain/repositories/admin_repository.dart';

class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository({FirebaseFirestore? firestore, FirebaseFunctions? functions})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  @override
  Future<AdminStats> loadStats() async {
    final weekAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );
    final results = await Future.wait([
      _safeCount(_firestore.collection('users')),
      _safeCount(
        _firestore.collection('users').where('createdAt', isGreaterThan: weekAgo),
      ),
      _safeCount(_firestore.collection('rooms')),
    ]);
    return AdminStats(
      totalMembers: results[0],
      newThisWeek: results[1],
      activeRooms: results[2],
    );
  }

  @override
  Stream<List<FounderProfile>> watchAllMembers() {
    return _firestore
        .collection('users')
        .orderBy('businessName')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(FounderProfile.fromFirestore)
              .where((p) => p.email.isNotEmpty)
              .toList(),
        );
  }

  @override
  Future<void> setAccreditation(String uid, {required bool isAccredited}) {
    return _firestore.collection('users').doc(uid).update({
      'isAccredited': isAccredited,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> postAnnouncement({
    required String title,
    required String content,
    bool isPinned = false,
  }) async {
    final callable = _functions.httpsCallable('adminPostAnnouncement');
    await callable.call({'title': title, 'content': content, 'isPinned': isPinned});
  }

  @override
  Stream<List<Map<String, dynamic>>> watchAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('publishedAt', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  @override
  Stream<List<CommunityMessage>> watchRecentPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(CommunityMessage.fromFirestore).toList());
  }

  @override
  Future<void> deletePost(String postId) {
    return _firestore.collection('posts').doc(postId).delete();
  }

  Future<int> _safeCount(Query<Map<String, dynamic>> query) async {
    try {
      final snap = await query.count().get();
      return snap.count ?? 0;
    } on FirebaseException catch (e) {
      debugPrint('[AdminRepository] count failed: $e');
      return 0;
    }
  }
}
