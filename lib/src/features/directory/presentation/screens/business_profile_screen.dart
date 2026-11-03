import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../core/website_url.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';
import '../widgets/directory_widgets.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({
    super.key,
    required this.profile,
    required this.onBack,
    this.viewerIsAdmin = false,
    this.onToggleAccreditation,
  });

  final FounderProfile profile;
  final VoidCallback onBack;
  final bool viewerIsAdmin;
  final Future<void> Function(String uid, bool isAccredited)? onToggleAccreditation;

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  bool _isTogglingAccreditation = false;
  late bool _localIsAccredited;

  @override
  void initState() {
    super.initState();
    _localIsAccredited = widget.profile.isAccredited;
  }

  @override
  void didUpdateWidget(covariant BusinessProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isTogglingAccreditation) {
      _localIsAccredited = widget.profile.isAccredited;
    }
  }

  Future<void> _toggleAccreditation() async {
    final toggle = widget.onToggleAccreditation;
    if (toggle == null || _isTogglingAccreditation) return;
    setState(() => _isTogglingAccreditation = true);
    try {
      final newValue = !_localIsAccredited;
      await toggle(widget.profile.uid, newValue);
      if (mounted) setState(() => _localIsAccredited = newValue);
    } finally {
      if (mounted) setState(() => _isTogglingAccreditation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final founderName = _valueOrFallback(
      widget.profile.displayName,
      'Founder not available',
    );
    final businessName = _valueOrFallback(
      widget.profile.businessName,
      'Business not available',
    );
    final website = normalizedWebsiteUrl(widget.profile.website);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BusinessProfileHeader(
            profile: widget.profile,
            businessName: businessName,
            founderName: founderName,
            onBack: widget.onBack,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 104),
              children: [
                Text(
                  _valueOrFallback(
                    widget.profile.bio,
                    'Business description not available.',
                  ),
                  style: TextStyle(
                    color: context.colors.muted,
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
                        widget.profile.industry,
                        'Not available',
                      ),
                    ),
                    ProfileFactCard(
                      label: 'Location',
                      value: _valueOrFallback(
                        widget.profile.city,
                        'Not available',
                      ),
                    ),
                    ProfileFactCard(
                      label: 'Stage',
                      value: _valueOrFallback(
                        widget.profile.businessStage,
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
                BusinessNeedsRow(needs: widget.profile.needs),
                const SizedBox(height: 14),
                ProfileActionButton(
                  label: website == null
                      ? 'Website not available'
                      : 'Visit Website',
                  outlined: true,
                  disabled: website == null,
                  onTap: website == null ? null : () => _openWebsite(website),
                ),
                if (widget.viewerIsAdmin) ...[
                  const SizedBox(height: 16),
                  _AdminAccreditationButton(
                    isAccredited: _localIsAccredited,
                    isLoading: _isTogglingAccreditation,
                    onTap: _toggleAccreditation,
                  ),
                ],
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
}

class _AdminAccreditationButton extends StatelessWidget {
  const _AdminAccreditationButton({
    required this.isAccredited,
    required this.isLoading,
    required this.onTap,
  });

  final bool isAccredited;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.red.withValues(alpha: .08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              top: BorderSide(color: context.colors.red.withValues(alpha: .2)),
              left: BorderSide(color: context.colors.red.withValues(alpha: .2)),
              right: BorderSide(color: context.colors.red.withValues(alpha: .2)),
            ),
          ),
          child: const Text(
            'Admin Action',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB05050),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
        ),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: isAccredited
                  ? context.colors.red.withValues(alpha: .08)
                  : context.colors.gold.withValues(alpha: .10),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isAccredited
                      ? context.colors.red.withValues(alpha: .2)
                      : context.colors.gold.withValues(alpha: .3),
                ),
                left: BorderSide(
                  color: isAccredited
                      ? context.colors.red.withValues(alpha: .2)
                      : context.colors.gold.withValues(alpha: .3),
                ),
                right: BorderSide(
                  color: isAccredited
                      ? context.colors.red.withValues(alpha: .2)
                      : context.colors.gold.withValues(alpha: .3),
                ),
              ),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: context.colors.gold,
                        strokeWidth: 1.5,
                      ),
                    ),
                  )
                : Text(
                    isAccredited
                        ? 'Revoke Accredited Status'
                        : 'Grant Accredited Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isAccredited
                          ? const Color(0xFFB05050)
                          : context.colors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
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
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '←',
                  style: TextStyle(color: context.colors.muted, fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Directory',
                  style: TextStyle(color: context.colors.muted, fontSize: 13),
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
                      style: TextStyle(
                        color: context.colors.muted,
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
            color: outlined ? Colors.transparent : context.colors.gold,
            borderRadius: BorderRadius.circular(14),
            border: outlined
                ? Border.all(
                    color: context.colors.gold.withValues(alpha: .35),
                    width: 1.5,
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: outlined ? context.colors.muted : context.colors.background,
              fontSize: outlined ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
