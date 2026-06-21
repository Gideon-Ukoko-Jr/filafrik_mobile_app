import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';

class DirectoryCard extends StatelessWidget {
  const DirectoryCard({super.key, required this.profile, required this.onTap});

  final FounderProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        accent: profile.isAccredited,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BusinessMark(profile: profile),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _valueOrFallback(
                                profile.businessName,
                                'Business not available',
                              ),
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
                              'by ${_valueOrFallback(profile.displayName, 'Founder not available')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                MemberBadge(isAccredited: profile.isAccredited),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              _valueOrFallback(
                profile.bio,
                'Business description not available.',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessMark extends StatelessWidget {
  const BusinessMark({
    super.key,
    required this.profile,
    this.size = 36,
    this.rounded = false,
  });

  final FounderProfile profile;
  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(profile.businessName);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.green],
        ),
        borderRadius: BorderRadius.circular(rounded ? 14 : size / 2),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: .35),
          width: 1.5,
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.text,
          fontSize: size >= 48 ? 16 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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

class DirectoryFilterPill extends StatelessWidget {
  const DirectoryFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 29,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.gold.withValues(alpha: .35),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? AppColors.background : AppColors.muted,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class MemberBadge extends StatelessWidget {
  const MemberBadge({super.key, required this.isAccredited});

  final bool isAccredited;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isAccredited
            ? AppColors.gold.withValues(alpha: .13)
            : AppColors.green.withValues(alpha: .10),
        border: Border.all(
          color: isAccredited
              ? AppColors.gold.withValues(alpha: .30)
              : AppColors.green.withValues(alpha: .20),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAccredited ? '✦ Accredited' : 'Listed',
        style: TextStyle(
          color: isAccredited ? AppColors.gold : AppColors.green,
          fontSize: 9,
          fontWeight: isAccredited ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class ProfileFactCard extends StatelessWidget {
  const ProfileFactCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.dim, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class UnavailablePill extends StatelessWidget {
  const UnavailablePill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: .18)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.muted, fontSize: 10),
      ),
    );
  }
}

String _valueOrFallback(String? value, String fallback) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
}
