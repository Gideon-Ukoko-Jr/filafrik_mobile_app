import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../domain/models/community_room.dart';
import '../widgets/community_widgets.dart';

class CommunityRoomsScreen extends StatelessWidget {
  const CommunityRoomsScreen({super.key, required this.onRoomSelected});

  final ValueChanged<CommunityRoom> onRoomSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CommunityHeader(
            title: 'Community Rooms',
            subtitle: 'Connect with founders',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
              children: [
                const CommunitySectionLabel('Open Rooms'),
                ...defaultCommunityRooms.map(
                  (room) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: CommunityRoomTile(
                      room: room,
                      onTap: () => onRoomSelected(room),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const CommunitySectionLabel('Exclusive'),
                CommunityRoomTile(room: accreditedLoungeRoom, onTap: null),
                const SizedBox(height: 8),
                const Text(
                  'Room activity is placeholder data until community posts are connected.',
                  style: TextStyle(color: AppColors.dim, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
