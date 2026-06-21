import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/models/founder_profile.dart';
import '../domain/models/community_message.dart';
import '../domain/models/community_room.dart';
import '../domain/repositories/community_repository.dart';

class FirebaseCommunityRepository implements CommunityRepository {
  FirebaseCommunityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  @override
  Stream<List<CommunityMessage>> watchRoomMessages(CommunityRoom room) {
    return _posts.where('roomId', isEqualTo: room.id).snapshots().map((
      snapshot,
    ) {
      final messages = snapshot.docs
          .map(CommunityMessage.fromFirestore)
          .where((message) => message.content.trim().isNotEmpty)
          .toList();
      messages.sort((first, second) {
        final firstTime =
            first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondTime =
            second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return firstTime.compareTo(secondTime);
      });
      return messages;
    });
  }

  @override
  Future<void> addRoomMessage({
    required CommunityRoom room,
    required FounderProfile author,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await _posts.add({
      'roomId': room.id,
      'roomTitle': room.title,
      'authorId': author.uid,
      'authorName': _valueOrFallback(author.displayName, 'Founder'),
      'authorInitials': _initials(author.displayName),
      'content': trimmed,
      'isAnnouncement': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _valueOrFallback(String value, String fallback) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    return trimmed;
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'FC';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
