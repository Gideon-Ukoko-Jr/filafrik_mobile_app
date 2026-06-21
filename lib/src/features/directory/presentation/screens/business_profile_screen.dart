import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/website_url.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../widgets/directory_widgets.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({
    super.key,
    required this.profile,
    required this.onBack,
  });

  final FounderProfile profile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final founderName = _valueOrFallback(
      profile.displayName,
      'Founder not available',
    );
    final businessName = _valueOrFallback(
      profile.businessName,
      'Business not available',
    );
    final website = normalizedWebsiteUrl(profile.website);
    final contactEmail = _normalizedEmail(profile.email);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BusinessProfileHeader(
            profile: profile,
            businessName: businessName,
            founderName: founderName,
            onBack: onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 104),
              children: [
                Text(
                  _valueOrFallback(
                    profile.bio,
                    'Business description not available.',
                  ),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    ProfileFactCard(
                      label: 'Industry',
                      value: _valueOrFallback(
                        profile.industry,
                        'Not available',
                      ),
                    ),
                    ProfileFactCard(
                      label: 'Location',
                      value: _valueOrFallback(profile.city, 'Not available'),
                    ),
                    ProfileFactCard(
                      label: 'Stage',
                      value: _valueOrFallback(
                        profile.businessStage,
                        'Not available',
                      ),
                    ),
                    const ProfileFactCard(
                      label: 'Founded',
                      value: 'Not available',
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                BusinessNeedsRow(needs: profile.needs),
                const SizedBox(height: 14),
                ProfileActionButton(
                  label: contactEmail == null
                      ? 'Contact not available'
                      : 'Connect with $founderName',
                  disabled: contactEmail == null,
                  onTap: contactEmail == null
                      ? null
                      : () => _openEmailApp(context, contactEmail),
                ),
                const SizedBox(height: 8),
                ProfileActionButton(
                  label: website == null
                      ? 'Website not available'
                      : 'Visit Website',
                  outlined: true,
                  disabled: website == null,
                  onTap: website == null ? null : () => _openWebsite(website),
                ),
              ],
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

  Future<void> _openWebsite(Uri website) async {
    await launchUrl(website, mode: LaunchMode.externalApplication);
  }

  String? _normalizedEmail(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      return null;
    }
    return trimmed;
  }

  Future<void> _openEmailApp(BuildContext context, String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: const {'subject': 'FilAfrik Founders Circle connection'},
    );
    final messenger = ScaffoldMessenger.of(context);

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No email app is available on this device.'),
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Email app could not be opened.')),
      );
    }
  }
}

class BusinessProfileHeader extends StatelessWidget {
  const BusinessProfileHeader({
    super.key,
    required this.profile,
    required this.businessName,
    required this.founderName,
    required this.onBack,
  });

  final FounderProfile profile;
  final String businessName;
  final String founderName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 37, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '←',
                  style: TextStyle(color: AppColors.muted, fontSize: 18),
                ),
                SizedBox(width: 8),
                Text(
                  'Directory',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BusinessMark(profile: profile, size: 50, rounded: true),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTitle(businessName, size: 18),
                    const SizedBox(height: 2),
                    Text(
                      'by $founderName · Established not available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    MemberBadge(isAccredited: profile.isAccredited),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BusinessNeedsRow extends StatelessWidget {
  const BusinessNeedsRow({super.key, required this.needs});

  final List<String> needs;

  @override
  Widget build(BuildContext context) {
    final availableNeeds = needs
        .map((need) => need.trim())
        .where((need) => need.isNotEmpty)
        .toList();

    if (availableNeeds.isEmpty) {
      return const Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [UnavailablePill('Business needs not available')],
      );
    }

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: availableNeeds
          .map((need) => UnavailablePill(need))
          .toList(growable: false),
    );
  }
}

class ProfileActionButton extends StatelessWidget {
  const ProfileActionButton({
    super.key,
    required this.label,
    this.outlined = false,
    this.disabled = false,
    this.onTap,
  });

  final String label;
  final bool outlined;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? .72 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: outlined ? 13 : 14),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : AppColors.gold,
            borderRadius: BorderRadius.circular(14),
            border: outlined
                ? Border.all(
                    color: AppColors.gold.withValues(alpha: .35),
                    width: 1.5,
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: outlined ? AppColors.muted : AppColors.background,
              fontSize: outlined ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
