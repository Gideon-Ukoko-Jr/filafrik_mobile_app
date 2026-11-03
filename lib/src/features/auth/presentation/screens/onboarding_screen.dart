import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../shared/widgets/app_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              const Text('🌍', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 22),
              const AppTitle(
                'Where African Founders Grow Together',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Connect, access AI-powered resources, and grow your business — a home for African and Black diaspora founders in Canada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.muted,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AccentWord('Culture'),
                  SizedBox(width: 20),
                  AccentWord('Community'),
                  SizedBox(width: 20),
                  AccentWord('Commerce'),
                ],
              ),
              const Spacer(),
              const PageDots(),
              const SizedBox(height: 18),
              PrimaryButton(label: 'Get Started', onPressed: onGetStarted),
              TextButton(
                onPressed: onSignIn,
                child: Text.rich(
                  TextSpan(
                    text: 'Already a member? ',
                    style: TextStyle(color: context.colors.muted),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: context.colors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
