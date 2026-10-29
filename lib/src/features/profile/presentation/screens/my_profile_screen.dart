import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../core/website_url.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../../auth/domain/models/founder_profile.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({
    super.key,
    required this.profile,
    required this.onSaveProfile,
    required this.onSignOut,
    this.onOpenAdminPanel,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final FounderProfile? profile;
  final Future<void> Function(FounderProfile profile) onSaveProfile;
  final Future<void> Function() onSignOut;
  final VoidCallback? onOpenAdminPanel;
  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _businessController;
  late final TextEditingController _industryController;
  late final TextEditingController _stageController;
  late final TextEditingController _cityController;
  late final TextEditingController _websiteController;
  late final TextEditingController _bioController;
  late final TextEditingController _needsController;

  var _isEditing = false;
  var _isSaving = false;
  var _isSigningOut = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _businessController = TextEditingController();
    _industryController = TextEditingController();
    _stageController = TextEditingController();
    _cityController = TextEditingController();
    _websiteController = TextEditingController();
    _bioController = TextEditingController();
    _needsController = TextEditingController();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant MyProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile && !_isEditing) {
      _syncControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _industryController.dispose();
    _stageController.dispose();
    _cityController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    _needsController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    final profile = widget.profile;
    _nameController.text = profile?.displayName ?? '';
    _businessController.text = profile?.businessName ?? '';
    _industryController.text = profile?.industry ?? '';
    _stageController.text = profile?.businessStage ?? '';
    _cityController.text = profile?.city ?? '';
    _websiteController.text = profile?.website ?? '';
    _bioController.text = profile?.bio ?? '';
    _needsController.text = profile?.needs.join(', ') ?? '';
  }

  void _startEditing() {
    _syncControllers();
    setState(() {
      _isEditing = true;
      _errorText = null;
    });
  }

  void _cancelEditing() {
    _syncControllers();
    setState(() {
      _isEditing = false;
      _errorText = null;
    });
  }

  Future<void> _save() async {
    final profile = widget.profile;
    if (profile == null || _isSaving) {
      return;
    }

    final displayName = _nameController.text.trim();
    final businessName = _businessController.text.trim();
    final industry = _industryController.text.trim();
    final stage = _stageController.text.trim();
    final city = _cityController.text.trim();
    final website = _websiteController.text.trim();
    final bio = _bioController.text.trim();
    final needs = _needsController.text
        .split(',')
        .map((need) => need.trim())
        .where((need) => need.isNotEmpty)
        .toList();

    if (displayName.isEmpty || businessName.isEmpty) {
      setState(() => _errorText = 'Name and business name are required.');
      return;
    }
    if (industry.isEmpty || stage.isEmpty || city.isEmpty || bio.isEmpty) {
      setState(() => _errorText = 'Profile fields cannot be blank.');
      return;
    }
    if (needs.isEmpty) {
      setState(() => _errorText = 'Add at least one business need.');
      return;
    }
    if (!isBlankOrValidWebsite(website)) {
      setState(() => _errorText = 'Enter a valid website or leave it blank.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await widget.onSaveProfile(
        profile.copyWith(
          displayName: displayName,
          businessName: businessName,
          industry: industry,
          businessStage: stage,
          needs: needs,
          city: city,
          website: website,
          bio: bio,
        ),
      );
      if (mounted) {
        setState(() => _isEditing = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = 'Profile could not be saved. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    if (_isSigningOut) {
      return;
    }
    setState(() => _isSigningOut = true);
    await widget.onSignOut();
    if (mounted) {
      setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    if (profile == null) {
      return SafeArea(
        child: Center(
          child: Text(
            'Profile not available.',
            style: TextStyle(color: context.colors.muted),
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyProfileHeader(
            profile: profile,
            isEditing: _isEditing,
            isSaving: _isSaving,
            onEdit: _startEditing,
            onCancel: _cancelEditing,
            onSave: _save,
          ),
          Expanded(
            child: _isEditing
                ? _EditProfileForm(
                    nameController: _nameController,
                    businessController: _businessController,
                    industryController: _industryController,
                    stageController: _stageController,
                    cityController: _cityController,
                    websiteController: _websiteController,
                    bioController: _bioController,
                    needsController: _needsController,
                    errorText: _errorText,
                    isSaving: _isSaving,
                    onSave: _save,
                  )
                : _ProfileDetails(
                    profile: profile,
                    onSignOut: _signOut,
                    onOpenAdminPanel: widget.onOpenAdminPanel,
                    themeMode: widget.themeMode,
                    onThemeModeChanged: widget.onThemeModeChanged,
                  ),
          ),
        ],
      ),
    );
  }
}

class MyProfileHeader extends StatelessWidget {
  const MyProfileHeader({
    super.key,
    required this.profile,
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final FounderProfile profile;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final city = _valueOrFallback(profile.city, 'Location not available');

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 37, 18, 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: AppTitle('My Profile', size: 19)),
              if (isEditing) ...[
                _HeaderAction(label: 'Cancel', onTap: onCancel),
                const SizedBox(width: 8),
                _HeaderAction(
                  label: isSaving ? 'Saving...' : 'Save',
                  onTap: isSaving ? null : onSave,
                  filled: true,
                ),
              ] else
                _HeaderAction(label: 'Edit', onTap: onEdit),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ProfileAvatar(initials: _initials(profile.displayName)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTitle(
                      _valueOrFallback(profile.displayName, 'Founder'),
                      size: 17,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _valueOrFallback(
                        profile.businessName,
                        'Business not available',
                      ),
                      style: TextStyle(
                        color: context.colors.gold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_valueOrFallback(profile.industry, 'Industry not available')} · '
                      '${_valueOrFallback(profile.businessStage, 'Stage not available')} · $city',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.muted,
                        fontSize: 11,
                      ),
                    ),
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

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: filled ? context.colors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.gold, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? context.colors.background : context.colors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.colors.forest, context.colors.green],
        ),
        border: Border.all(color: context.colors.gold, width: 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: context.colors.text,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({
    required this.profile,
    required this.onSignOut,
    this.onOpenAdminPanel,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final FounderProfile profile;
  final VoidCallback onSignOut;
  final VoidCallback? onOpenAdminPanel;
  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 104),
      children: [
        _ProfileCard(
          label: 'About',
          child: Text(
            _valueOrFallback(profile.bio, 'About not available.'),
            style: TextStyle(
              color: context.colors.muted,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ),
        _ProfileCard(
          label: 'Website',
          child: Text(
            _valueOrFallback(profile.website, 'Website not available.'),
            style: TextStyle(
              color: context.colors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
        _ProfileCard(
          label: 'Business Needs',
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: profile.needs.isEmpty
                ? [_NeedPill('Needs not available')]
                : profile.needs.map((need) => _NeedPill(need)).toList(),
          ),
        ),
        _ThemeToggleCard(
          themeMode: themeMode,
          onThemeModeChanged: onThemeModeChanged,
        ),
        AppCard(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.gold.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🎍', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.isAccredited
                          ? 'Accredited Member'
                          : 'Listed Member',
                      style: TextStyle(
                        color: context.colors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.isAccredited
                          ? 'Verified by FilAfrik'
                          : 'Contact FilAfrik for Accredited status',
                      style: TextStyle(
                        color: context.colors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (profile.isAdmin && onOpenAdminPanel != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onOpenAdminPanel,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: context.colors.red.withValues(alpha: .3),
                ),
                color: context.colors.red.withValues(alpha: .06),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🛡️', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 7),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Color(0xFFB05050),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onSignOut,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: context.colors.red.withValues(alpha: .25),
              ),
            ),
            child: const Text(
              'Sign Out',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB05050), fontSize: 13),
            ),
          ),
        ),
      ].separatedBy(const SizedBox(height: 10)),
    );
  }
}

class _ThemeToggleCard extends StatelessWidget {
  const _ThemeToggleCard({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;

  bool get _isDark => themeMode == ThemeMode.dark ||
      (themeMode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  void _toggle() {
    onThemeModeChanged(_isDark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    final usingSystem = themeMode == ThemeMode.system;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Appearance'),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                _isDark ? '🌙' : '☀️',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: context.colors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (usingSystem)
                      Text(
                        'Following system setting',
                        style: TextStyle(
                          color: context.colors.muted,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: _isDark,
                onChanged: (_) => _toggle(),
                activeThumbColor: context.colors.background,
                activeTrackColor: context.colors.gold,
                inactiveThumbColor: context.colors.dim,
                inactiveTrackColor: context.colors.gold.withValues(alpha: .18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => onThemeModeChanged(ThemeMode.system),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  usingSystem ? '✓ Using system default' : 'Use system default',
                  style: TextStyle(
                    color: usingSystem
                        ? context.colors.gold
                        : context.colors.muted,
                    fontSize: 10,
                    fontWeight:
                        usingSystem ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  const _EditProfileForm({
    required this.nameController,
    required this.businessController,
    required this.industryController,
    required this.stageController,
    required this.cityController,
    required this.websiteController,
    required this.bioController,
    required this.needsController,
    required this.errorText,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController businessController;
  final TextEditingController industryController;
  final TextEditingController stageController;
  final TextEditingController cityController;
  final TextEditingController websiteController;
  final TextEditingController bioController;
  final TextEditingController needsController;
  final String? errorText;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('profile_edit_list'),
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 104),
      children: [
        if (errorText != null) ErrorMessage(errorText!),
        AppTextField(
          label: 'Full Name',
          controller: nameController,
          textFieldKey: const ValueKey('profile_name_field'),
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Business Name',
          controller: businessController,
          textFieldKey: const ValueKey('profile_business_field'),
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Industry',
          controller: industryController,
          textFieldKey: const ValueKey('profile_industry_field'),
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Business Stage',
          controller: stageController,
          textFieldKey: const ValueKey('profile_stage_field'),
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'City',
          controller: cityController,
          textFieldKey: const ValueKey('profile_city_field'),
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Website',
          controller: websiteController,
          textFieldKey: const ValueKey('profile_website_field'),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Bio',
          controller: bioController,
          textFieldKey: const ValueKey('profile_bio_field'),
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
        AppTextField(
          label: 'Business Needs',
          controller: needsController,
          textFieldKey: const ValueKey('profile_needs_field'),
          hint: 'Funding & Grants, Mentorship',
          textInputAction: TextInputAction.done,
        ),
        PrimaryButton(
          label: isSaving ? 'Saving...' : 'Save Profile',
          onPressed: isSaving ? () {} : onSave,
        ),
      ].separatedBy(const SizedBox(height: 10)),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SectionLabel(label), const SizedBox(height: 8), child],
      ),
    );
  }
}

class _NeedPill extends StatelessWidget {
  const _NeedPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.gold.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.gold.withValues(alpha: .25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

extension _SeparatedWidgets on List<Widget> {
  List<Widget> separatedBy(Widget separator) {
    if (isEmpty) {
      return this;
    }

    return [
      for (var index = 0; index < length; index++) ...[
        if (index > 0) separator,
        this[index],
      ],
    ];
  }
}

String _valueOrFallback(String? value, String fallback) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
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
