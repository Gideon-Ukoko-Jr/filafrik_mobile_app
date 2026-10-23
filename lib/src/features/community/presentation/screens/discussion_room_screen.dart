import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../domain/models/community_message.dart';
import '../../domain/models/community_room.dart';
import '../../domain/repositories/community_repository.dart';
import '../widgets/community_widgets.dart';

class DiscussionRoomScreen extends StatefulWidget {
  const DiscussionRoomScreen({
    super.key,
    required this.room,
    required this.profile,
    required this.communityRepository,
    required this.onBack,
  });

  final CommunityRoom room;
  final FounderProfile? profile;
  final CommunityRepository communityRepository;
  final VoidCallback onBack;

  @override
  State<DiscussionRoomScreen> createState() => _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends State<DiscussionRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  var _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final profile = widget.profile;
    final content = _messageController.text.trim();
    if (profile == null || content.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await widget.communityRepository.addRoomMessage(
        room: widget.room,
        author: profile,
        content: content,
      );
      _messageController.clear();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          DiscussionRoomHeader(room: widget.room, onBack: widget.onBack),
          Expanded(
            child: StreamBuilder<List<CommunityMessage>>(
              stream: widget.communityRepository.watchRoomMessages(widget.room),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: context.colors.gold),
                  );
                }

                final messages = snapshot.data ?? const <CommunityMessage>[];
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No posts yet. Start the conversation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.muted, fontSize: 12),
                      ),
                    ),
                  );
                }

                final items = _buildMessageItems(messages);

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return switch (item) {
                      _DayDividerItem(:final label) => DayChip(label: label),
                      _MessageItem(:final message) => _MessageRow(
                        message: message,
                        currentUserId: widget.profile?.uid,
                      ),
                    };
                  },
                  separatorBuilder: (context, index) {
                    final next = items[index + 1];
                    return SizedBox(height: next is _DayDividerItem ? 16 : 12);
                  },
                  itemCount: items.length,
                );
              },
            ),
          ),
          DiscussionComposer(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSend: _sendMessage,
            enabled: widget.profile != null && !_isSending,
          ),
        ],
      ),
    );
  }

  List<_RoomTimelineItem> _buildMessageItems(List<CommunityMessage> messages) {
    final now = DateTime.now();
    String? activeDay;
    final items = <_RoomTimelineItem>[];

    for (final message in messages) {
      final day = message.dayLabel(now);
      if (day != activeDay) {
        activeDay = day;
        items.add(_DayDividerItem(day));
      }
      items.add(_MessageItem(message));
    }

    return items;
  }
}

sealed class _RoomTimelineItem {
  const _RoomTimelineItem();
}

class _DayDividerItem extends _RoomTimelineItem {
  const _DayDividerItem(this.label);

  final String label;
}

class _MessageItem extends _RoomTimelineItem {
  const _MessageItem(this.message);

  final CommunityMessage message;
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.currentUserId});

  final CommunityMessage message;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      author: message.authorName,
      initials: message.authorInitials,
      message: message.content,
      time: message.displayTime,
      mine: message.authorId == currentUserId,
    );
  }
}

class DiscussionRoomHeader extends StatelessWidget {
  const DiscussionRoomHeader({
    super.key,
    required this.room,
    required this.onBack,
  });

  final CommunityRoom room;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 37, 16, 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Text(
              '←',
              style: TextStyle(color: context.colors.muted, fontSize: 18),
            ),
          ),
          const SizedBox(width: 10),
          RoomIcon(emoji: room.emoji),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Live room',
                  style: TextStyle(color: context.colors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DayChip extends StatelessWidget {
  const DayChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colors.gold.withValues(alpha: .14))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.gold.withValues(alpha: .18)),
            ),
            child: Text(
              label,
              style: TextStyle(color: context.colors.dim, fontSize: 10),
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colors.gold.withValues(alpha: .14))),
      ],
    );
  }
}

class DiscussionComposer extends StatelessWidget {
  const DiscussionComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      margin: EdgeInsets.only(bottom: math.max(82.0, keyboardHeight)),
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.gold.withValues(alpha: .14)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: enabled ? focusNode.requestFocus : null,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                cursorColor: context.colors.gold,
                style: TextStyle(color: context.colors.text, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Write a post or question...',
                  hintStyle: TextStyle(
                    color: context.colors.dim,
                    fontSize: 12,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: context.colors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: context.colors.gold.withValues(alpha: .18),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: context.colors.gold),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: context.colors.gold.withValues(alpha: .12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Opacity(
              opacity: enabled ? 1 : .6,
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.gold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '⇧',
                  style: TextStyle(color: context.colors.background, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
