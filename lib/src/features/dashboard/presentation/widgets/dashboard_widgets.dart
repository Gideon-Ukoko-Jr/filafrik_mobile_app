import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../../domain/models/dashboard_stats_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('🏠', 'Home'),
      ('🏢', 'Dir'),
      ('✨', 'AI'),
      ('💬', 'Chat'),
      ('👤', 'Me'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0805),
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: .14)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final selected = index == selectedIndex;
          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    items[index].$1,
                    style: TextStyle(
                      color: selected ? AppColors.gold : AppColors.dim,
                      fontSize: selected ? 23 : 20,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index].$2,
                    style: TextStyle(
                      color: selected ? AppColors.gold : AppColors.dim,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 14,
                    height: 2,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.gold : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.profile});

  final FounderProfile? profile;

  @override
  Widget build(BuildContext context) {
    final businessName = _valueOrFallback(
      profile?.businessName,
      'Your business',
    );
    final stage = _valueOrFallback(profile?.businessStage, 'Founder');
    final industry = _valueOrFallback(profile?.industry, 'Industry');
    final needs = profile?.needs.isNotEmpty == true
        ? profile!.needs.take(2).join(' · ')
        : 'Complete your profile';
    final status = profile?.isAccredited == true
        ? 'Accredited Member'
        : 'Listed Member';

    return AppCard(
      accent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$businessName · $stage',
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            '$industry · $needs',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .13),
              border: Border.all(color: AppColors.gold.withValues(alpha: .30)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(color: AppColors.gold, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrFallback(String? value, String fallback) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }
    return trimmed;
  }
}

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key, required this.dashboardRepository});

  final DashboardRepository dashboardRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardStatsData>(
      future: dashboardRepository.loadHomeStats(),
      builder: (context, snapshot) {
        final members = snapshot.data?.members;
        final stats = [
          (members?.toString() ?? '...', 'Members'),
          ('0', 'Businesses'),
          ('0', 'Rooms'),
          ('0', 'Events'),
        ];

        return _StatsGrid(stats: stats);
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.9,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: stats
          .map(
            (stat) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stat.$1,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  Text(
                    stat.$2,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class QuickAccessTile extends StatelessWidget {
  const QuickAccessTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
