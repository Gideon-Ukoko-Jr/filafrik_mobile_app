import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../domain/models/community_room.dart';
import '../widgets/community_widgets.dart';

class CommunityRoomsScreen extends StatelessWidget {
  const CommunityRoomsScreen({
    super.key,
    required this.profile,
    required this.onRoomSelected,
  });

  final FounderProfile? profile;
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
                CommunityRoomTile(
                  room: accreditedLoungeRoom,
                  onTap: profile?.isAccredited == true
                      ? () => onRoomSelected(accreditedLoungeRoom)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  'Room activity is placeholder data until community posts are connected.',
                  style: TextStyle(color: context.colors.dim, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
