import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../widgets/dashboard_widgets.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.profile,
    required this.dashboardRepository,
    required this.onDirectorySelected,
    required this.onCommunitySelected,
  });

  final FounderProfile? profile;
  final DashboardRepository dashboardRepository;
  final VoidCallback onDirectorySelected;
  final VoidCallback onCommunitySelected;

  @override
  Widget build(BuildContext context) {
    final displayName = profile?.displayName.trim().isNotEmpty == true
        ? profile!.displayName.trim()
        : 'Founder';
    final initials = _initials(displayName);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 36, 18, 104),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: TextStyle(color: context.colors.muted, fontSize: 12),
                    ),
                    AppTitle(displayName, size: 21),
                  ],
                ),
              ),
              Avatar(initials: initials),
            ],
          ),
          const SizedBox(height: 16),
          MemberCard(profile: profile),
          const SizedBox(height: 16),
          DashboardStats(dashboardRepository: dashboardRepository),
          const SizedBox(height: 18),
          const SectionLabel('Quick Access'),
          const SizedBox(height: 8),
          QuickAccessTile(
            emoji: '🏢',
            title: 'Directory',
            subtitle: 'Find & connect',
            onTap: onDirectorySelected,
          ),
          const QuickAccessTile(
            emoji: '✨',
            title: 'AI Resources',
            subtitle: 'Tailored grants & tools',
          ),
          QuickAccessTile(
            emoji: '💬',
            title: 'Community',
            subtitle: 'Chat & network',
            onTap: onCommunitySelected,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'FC';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
