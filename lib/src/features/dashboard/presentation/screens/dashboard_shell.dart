import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../../community/domain/models/community_room.dart';
import '../../../community/domain/repositories/community_repository.dart';
import '../../../community/presentation/community_screens.dart';
import '../../../directory/domain/repositories/directory_repository.dart';
import '../../../directory/presentation/directory_screens.dart';
import '../../../profile/presentation/profile_screens.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../widgets/dashboard_widgets.dart';
import 'home_dashboard.dart';
import 'placeholder_tab.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({
    super.key,
    required this.profile,
    required this.dashboardRepository,
    required this.directoryRepository,
    required this.communityRepository,
    required this.selectedIndex,
    required this.onSaveProfile,
    required this.onSignOut,
    required this.onTabSelected,
  });

  final FounderProfile? profile;
  final DashboardRepository dashboardRepository;
  final DirectoryRepository directoryRepository;
  final CommunityRepository communityRepository;
  final int selectedIndex;
  final Future<void> Function(FounderProfile profile) onSaveProfile;
  final Future<void> Function() onSignOut;
  final ValueChanged<int> onTabSelected;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  FounderProfile? _selectedDirectoryProfile;
  CommunityRoom? _selectedCommunityRoom;

  void _selectTab(int index) {
    setState(() {
      _selectedDirectoryProfile = null;
      _selectedCommunityRoom = null;
    });
    widget.onTabSelected(index);
  }

  void _openBusinessProfile(FounderProfile profile) {
    setState(() => _selectedDirectoryProfile = profile);
  }

  void _closeBusinessProfile() {
    setState(() => _selectedDirectoryProfile = null);
  }

  void _openDiscussionRoom(CommunityRoom room) {
    setState(() => _selectedCommunityRoom = room);
  }

  void _closeDiscussionRoom() {
    setState(() => _selectedCommunityRoom = null);
  }

  @override
  Widget build(BuildContext context) {
    final directoryProfile = _selectedDirectoryProfile;
    final communityRoom = _selectedCommunityRoom;
    final pages = [
      HomeDashboard(
        profile: widget.profile,
        dashboardRepository: widget.dashboardRepository,
        onDirectorySelected: () => _selectTab(1),
        onCommunitySelected: () => _selectTab(3),
      ),
      directoryProfile == null
          ? DirectoryScreen(
              directoryRepository: widget.directoryRepository,
              onProfileSelected: _openBusinessProfile,
            )
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 200) {
                  _closeBusinessProfile();
                }
              },
              child: BusinessProfileScreen(
                profile: directoryProfile,
                onBack: _closeBusinessProfile,
              ),
            ),
      const PlaceholderTab(
        title: 'AI Resources',
        subtitle: 'Grant matching and resource cards come next.',
        icon: Icons.auto_awesome,
      ),
      communityRoom == null
          ? CommunityRoomsScreen(onRoomSelected: _openDiscussionRoom)
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 200) {
                  _closeDiscussionRoom();
                }
              },
              child: DiscussionRoomScreen(
                room: communityRoom,
                profile: widget.profile,
                communityRepository: widget.communityRepository,
                onBack: _closeDiscussionRoom,
              ),
            ),
      MyProfileScreen(
        profile: widget.profile,
        onSaveProfile: widget.onSaveProfile,
        onSignOut: widget.onSignOut,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedDirectoryProfile != null) {
          _closeBusinessProfile();
        } else if (_selectedCommunityRoom != null) {
          _closeDiscussionRoom();
        } else {
          SystemNavigator.pop();
        }
      },
      child: AppScaffold(
        child: Stack(
          children: [
            Positioned.fill(child: pages[widget.selectedIndex]),
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNav(
                selectedIndex: widget.selectedIndex,
                onSelected: _selectTab,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
