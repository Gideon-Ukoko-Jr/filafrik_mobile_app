import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../core/website_url.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../application/registration_draft.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({
    super.key,
    required this.draft,
    required this.onNext,
    required this.onSignIn,
  });

  final RegistrationDraft draft;
  final VoidCallback onNext;
  final VoidCallback onSignIn;

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.draft.email);
    _passwordController = TextEditingController(text: widget.draft.password);
    _confirmPasswordController = TextEditingController(
      text: widget.draft.password,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _continue() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!email.contains('@')) {
      setState(() => _errorText = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorText = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorText = 'Passwords do not match.');
      return;
    }

    widget.draft.email = email;
    widget.draft.password = password;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterLayout(
      step: 1,
      title: 'Create your account',
      footer: Column(
        children: [
          if (_errorText != null) ErrorMessage(_errorText!),
          PrimaryButton(label: 'Continue →', onPressed: _continue),
          TextButton(
            onPressed: widget.onSignIn,
            child: Text(
              'Already a member? Sign In',
              style: TextStyle(color: context.colors.muted, fontSize: 12),
            ),
          ),
          Text(
            "By continuing you agree to FilAfrik's Terms of Service",
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.dim, fontSize: 11),
          ),
        ],
      ),
      children: [
        AppTextField(
          label: 'Email Address',
          controller: _emailController,
          hint: 'amara@kente.co',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Password',
          controller: _passwordController,
          hint: 'Create a password',
          obscure: true,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          hint: 'Repeat password',
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

class RegisterProfileScreen extends StatefulWidget {
  const RegisterProfileScreen({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onNext,
  });

  final RegistrationDraft draft;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  State<RegisterProfileScreen> createState() => _RegisterProfileScreenState();
}

class _RegisterProfileScreenState extends State<RegisterProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  late final TextEditingController _cityController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.draft.fullName);
    _businessNameController = TextEditingController(
      text: widget.draft.businessName,
    );
    _bioController = TextEditingController(text: widget.draft.bio);
    _websiteController = TextEditingController(text: widget.draft.website);
    _cityController = TextEditingController(text: widget.draft.city);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_fullNameController.text.trim().isEmpty ||
        _businessNameController.text.trim().isEmpty) {
      setState(() => _errorText = 'Full name and business name are required.');
      return;
    }
    if (!isBlankOrValidWebsite(_websiteController.text)) {
      setState(() => _errorText = 'Enter a valid website or leave it blank.');
      return;
    }

    widget.draft.fullName = _fullNameController.text.trim();
    widget.draft.businessName = _businessNameController.text.trim();
    widget.draft.bio = _bioController.text.trim();
    widget.draft.website = _websiteController.text.trim();
    widget.draft.city = _cityController.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterLayout(
      step: 2,
      title: 'Tell us about you',
      footer: Column(
        children: [
          if (_errorText != null) ErrorMessage(_errorText!),
          StepButtons(onBack: widget.onBack, onNext: _continue),
        ],
      ),
      children: [
        AppTextField(
          label: 'Full Name',
          controller: _fullNameController,
          hint: 'Amara Osei',
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Business Name',
          controller: _businessNameController,
          hint: 'Kente Digital',
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Bio',
          controller: _bioController,
          hint: 'What does your business do?',
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
        AppTextField(
          label: 'Website',
          controller: _websiteController,
          hint: 'https://kentedigital.com',
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'City',
          controller: _cityController,
          hint: 'London, ON',
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

class RegisterIndustryScreen extends StatefulWidget {
  const RegisterIndustryScreen({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onNext,
  });

  final RegistrationDraft draft;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  State<RegisterIndustryScreen> createState() => _RegisterIndustryScreenState();
}

class _RegisterIndustryScreenState extends State<RegisterIndustryScreen> {
  static const _industries = [
    'Technology',
    'Food & Hospitality',
    'Fashion & Beauty',
    'Finance & Consulting',
    'Media & Marketing',
    'Healthcare',
    'Real Estate',
    'Education',
    'Agriculture',
    'Retail',
    'Arts & Entertainment',
    'Other',
  ];

  static const _stages = [
    'Idea Stage',
    'Early Stage (0-1 yrs)',
    'Growth Stage (1-3 yrs)',
    'Established (3+ yrs)',
    'Scaling Up',
  ];

  @override
  Widget build(BuildContext context) {
    return RegisterLayout(
      step: 3,
      title: 'Industry & stage',
      footer: StepButtons(onBack: widget.onBack, onNext: widget.onNext),
      children: [
        const FieldLabel('Select your industry'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _industries.map((industry) {
            return GestureDetector(
              onTap: () => setState(() => widget.draft.industry = industry),
              child: ChoiceChipView(
                industry,
                selected: widget.draft.industry == industry,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        const FieldLabel('Business stage'),
        ..._stages.map((stage) {
          return GestureDetector(
            onTap: () => setState(() => widget.draft.businessStage = stage),
            child: StageTile(
              stage,
              selected: widget.draft.businessStage == stage,
            ),
          );
        }),
      ],
    );
  }
}

class RegisterNeedsScreen extends StatefulWidget {
  const RegisterNeedsScreen({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onDone,
    this.isLoading = false,
    this.errorText,
  });

  final RegistrationDraft draft;
  final VoidCallback onBack;
  final VoidCallback onDone;
  final bool isLoading;
  final String? errorText;

  @override
  State<RegisterNeedsScreen> createState() => _RegisterNeedsScreenState();
}

class _RegisterNeedsScreenState extends State<RegisterNeedsScreen> {
  static const _needs = [
    'Funding & Grants',
    'Mentorship',
    'Networking',
    'Marketing Support',
    'Legal Advice',
    'Tech Solutions',
    'Export Markets',
    'Talent Acquisition',
  ];

  String? _localErrorText;

  void _finish() {
    if (widget.draft.needs.isEmpty) {
      setState(() => _localErrorText = 'Choose at least one business need.');
      return;
    }
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterLayout(
      step: 4,
      title: 'What do you need most?',
      subtitle: 'Pick all that apply',
      footer: Column(
        children: [
          if (_localErrorText != null) ErrorMessage(_localErrorText!),
          if (widget.errorText != null) ErrorMessage(widget.errorText!),
          StepButtons(
            onBack: widget.onBack,
            onNext: widget.isLoading ? () {} : _finish,
            nextLabel: widget.isLoading
                ? 'Creating account...'
                : 'Enter the Circle 🌍',
          ),
        ],
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _needs.map((need) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (widget.draft.needs.contains(need)) {
                    widget.draft.needs.remove(need);
                  } else {
                    widget.draft.needs.add(need);
                  }
                });
              },
              child: ChoiceChipView(
                need,
                selected: widget.draft.needs.contains(need),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class RegisterLayout extends StatelessWidget {
  const RegisterLayout({
    super.key,
    required this.step,
    required this.title,
    required this.children,
    required this.footer,
    this.subtitle,
  });

  final int step;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProgressBars(step: step),
              const SizedBox(height: 14),
              Text(
                'Step $step of 4'.toUpperCase(),
                style: TextStyle(
                  color: context.colors.gold,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              AppTitle(title, size: 22),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(color: context.colors.muted, fontSize: 12),
                ),
              ],
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children
                        .map(
                          (child) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: child,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              footer,
            ],
          ),
        ),
      ),
    );
  }
}
