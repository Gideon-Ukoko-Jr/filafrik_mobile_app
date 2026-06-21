import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
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
              const Text(
                "Connect, access AI-powered resources, and build your business in Canada's leading African founders community.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
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
                child: const Text.rich(
                  TextSpan(
                    text: 'Already a member? ',
                    style: TextStyle(color: AppColors.muted),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: AppColors.gold,
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
