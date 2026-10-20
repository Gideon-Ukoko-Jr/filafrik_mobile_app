import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/models/community_room.dart';

class CommunityHeader extends StatelessWidget {
  const CommunityHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 37, 18, 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTitle(title, size: 19),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class CommunitySectionLabel extends StatelessWidget {
  const CommunitySectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.dim,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class CommunityRoomTile extends StatelessWidget {
  const CommunityRoomTile({super.key, required this.room, required this.onTap});

  final CommunityRoom room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // exclusive + no onTap = locked; exclusive + onTap = accredited member, unlocked
    final locked = room.exclusive && onTap == null;
    final content = AppCard(
      child: Opacity(
        opacity: locked ? .55 : 1,
        child: Row(
          children: [
            RoomIcon(emoji: room.emoji, locked: locked),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (locked)
              const Text('🔒', style: TextStyle(fontSize: 18))
            else if (room.exclusive)
              const Text('👑', style: TextStyle(fontSize: 16))
            else
              Text(
                room.lastActive,
                style: const TextStyle(color: AppColors.dim, fontSize: 10),
              ),
          ],
        ),
      ),
    );

    return GestureDetector(onTap: onTap, child: content);
  }
}

class RoomIcon extends StatelessWidget {
  const RoomIcon({super.key, required this.emoji, this.locked = false});

  final String emoji;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: locked
            ? AppColors.gold.withValues(alpha: .08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.gold.withValues(alpha: .18)),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 19)),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.author,
    required this.initials,
    required this.message,
    required this.time,
    this.mine = false,
  });

  final String author;
  final String initials;
  final String message;
  final String time;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    if (mine) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 230),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'You · $time',
                    style: const TextStyle(
                      color: AppColors.dim,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .15),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                      bottomLeft: Radius.circular(13),
                      bottomRight: Radius.circular(3),
                    ),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: .22),
                    ),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Avatar(initials: initials),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 230),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$author · $time',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(13),
                  ),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: .18),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
