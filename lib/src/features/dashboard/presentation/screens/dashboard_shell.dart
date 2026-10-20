import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/widgets/app_widgets.dart';
import '../../../admin/domain/repositories/admin_repository.dart';
import '../../../admin/presentation/admin_screens.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../../community/domain/models/community_room.dart';
import '../../../community/domain/repositories/community_repository.dart';
import '../../../community/presentation/community_screens.dart';
import '../../../directory/domain/repositories/directory_repository.dart';
import '../../../directory/presentation/directory_screens.dart';
import '../../../profile/presentation/profile_screens.dart';
import '../../../resources/domain/repositories/resource_repository.dart';
import '../../../resources/presentation/resources_screens.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../widgets/dashboard_widgets.dart';
import 'home_dashboard.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({
    super.key,
    required this.profile,
    required this.dashboardRepository,
    required this.directoryRepository,
    required this.communityRepository,
    required this.resourceRepository,
    required this.adminRepository,
    required this.selectedIndex,
    required this.onSaveProfile,
    required this.onSignOut,
    required this.onTabSelected,
  });

  final FounderProfile? profile;
  final DashboardRepository dashboardRepository;
  final DirectoryRepository directoryRepository;
  final CommunityRepository communityRepository;
  final ResourceRepository resourceRepository;
  final AdminRepository adminRepository;
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
  bool _showAdminPanel = false;

  void _selectTab(int index) {
    setState(() {
      _selectedDirectoryProfile = null;
      _selectedCommunityRoom = null;
      _showAdminPanel = false;
    });
    widget.onTabSelected(index);
  }

  void _openAdminPanel() => setState(() => _showAdminPanel = true);
  void _closeAdminPanel() => setState(() => _showAdminPanel = false);

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
    final viewerIsAdmin = widget.profile?.isAdmin == true;

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
                viewerIsAdmin: viewerIsAdmin,
                onToggleAccreditation: viewerIsAdmin
                    ? (uid, isAccredited) => widget.adminRepository
                        .setAccreditation(uid, isAccredited: isAccredited)
                    : null,
              ),
            ),
      AIResourcesScreen(
        profile: widget.profile,
        resourceRepository: widget.resourceRepository,
      ),
      communityRoom == null
          ? CommunityRoomsScreen(
              profile: widget.profile,
              onRoomSelected: _openDiscussionRoom,
            )
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
        onOpenAdminPanel: viewerIsAdmin ? _openAdminPanel : null,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showAdminPanel) {
          _closeAdminPanel();
        } else if (_selectedDirectoryProfile != null) {
          _closeBusinessProfile();
        } else if (_selectedCommunityRoom != null) {
          _closeDiscussionRoom();
        } else {
          SystemNavigator.pop();
        }
      },
      child: AppScaffold(
        child: _showAdminPanel
            ? AdminPanelScreen(
                adminRepository: widget.adminRepository,
                onBack: _closeAdminPanel,
              )
            : Stack(
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
