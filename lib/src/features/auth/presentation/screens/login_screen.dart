import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onJoin,
    required this.onSignedIn,
    this.isLoading = false,
    this.errorText,
  });

  final VoidCallback onJoin;
  final Future<void> Function(String email, String password) onSignedIn;
  final bool isLoading;
  final String? errorText;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _localErrorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (!email.contains('@') || password.isEmpty) {
      setState(() => _localErrorText = 'Enter your email and password.');
      return;
    }

    setState(() => _localErrorText = null);
    await widget.onSignedIn(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTitle('Welcome back'),
              const SizedBox(height: 4),
              const Text(
                'Sign in to the Founders Circle',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 28),
              AppTextField(
                label: 'Email Address',
                controller: _emailController,
                hint: 'amara@kente.co',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Password',
                obscure: true,
                textInputAction: TextInputAction.done,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppColors.gold, fontSize: 12),
                  ),
                ),
              ),
              if (_localErrorText != null) ErrorMessage(_localErrorText!),
              if (widget.errorText != null) ErrorMessage(widget.errorText!),
              PrimaryButton(
                label: widget.isLoading ? 'Signing in...' : 'Sign In',
                onPressed: widget.isLoading ? () {} : _signIn,
              ),
              const SizedBox(height: 18),
              const Splitter(),
              const SizedBox(height: 14),
              SecondaryButton(
                label: '🔒  Sign in with Biometrics',
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              SecondaryButton(label: 'Continue with Google', onPressed: () {}),
              const Spacer(),
              TextButton(
                onPressed: widget.onJoin,
                child: const Text.rich(
                  TextSpan(
                    text: 'No account? ',
                    style: TextStyle(color: AppColors.muted),
                    children: [
                      TextSpan(
                        text: 'Join the Circle',
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
