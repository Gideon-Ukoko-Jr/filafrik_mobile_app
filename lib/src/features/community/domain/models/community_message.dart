import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityMessage {
  const CommunityMessage({
    required this.id,
    required this.roomId,
    required this.authorId,
    required this.authorName,
    required this.authorInitials,
    required this.content,
    this.createdAt,
  });

  final String id;
  final String roomId;
  final String authorId;
  final String authorName;
  final String authorInitials;
  final String content;
  final DateTime? createdAt;

  factory CommunityMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];

    return CommunityMessage(
      id: doc.id,
      roomId: data['roomId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Founder',
      authorInitials: data['authorInitials'] as String? ?? 'FC',
      content: data['content'] as String? ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  String get displayTime {
    final value = createdAt;
    if (value == null) {
      return 'now';
    }

    final hour = value.hour == 0
        ? 12
        : value.hour > 12
        ? value.hour - 12
        : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String dayLabel(DateTime now) {
    final value = createdAt;
    if (value == null) {
      return 'Sending';
    }

    final messageDate = DateTime(value.year, value.month, value.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (messageDate == today) {
      return 'Today';
    }
    if (messageDate == yesterday) {
      return 'Yesterday';
    }

    return '${value.month}/${value.day}/${value.year}';
  }
}
