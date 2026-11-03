import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../shared/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onJoin,
    required this.onSignedIn,
    this.onForgotPassword,
    this.isLoading = false,
    this.errorText,
  });

  final VoidCallback onJoin;
  final Future<void> Function(String email, String password) onSignedIn;
  final Future<void> Function(String email)? onForgotPassword;
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

  void _showForgotPasswordDialog(BuildContext context) {
    final reset = widget.onForgotPassword;
    if (reset == null) return;
    final controller = TextEditingController(text: _emailController.text.trim());
    showDialog<void>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(emailController: controller, onSend: reset),
    ).then((_) => controller.dispose());
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
              Text(
                'Sign in to the Founders Circle',
                style: TextStyle(color: context.colors.muted, fontSize: 13),
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
                  onPressed: widget.onForgotPassword != null
                      ? () => _showForgotPasswordDialog(context)
                      : null,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(color: context.colors.gold, fontSize: 12),
                  ),
                ),
              ),
              if (_localErrorText != null) ErrorMessage(_localErrorText!),
              if (widget.errorText != null) ErrorMessage(widget.errorText!),
              PrimaryButton(
                label: widget.isLoading ? 'Signing in...' : 'Sign In',
                onPressed: widget.isLoading ? () {} : _signIn,
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onJoin,
                child: Text.rich(
                  TextSpan(
                    text: 'No account? ',
                    style: TextStyle(color: context.colors.muted),
                    children: [
                      TextSpan(
                        text: 'Join the Circle',
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

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({
    required this.emailController,
    required this.onSend,
  });

  final TextEditingController emailController;
  final Future<void> Function(String email) onSend;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  var _isSending = false;
  String? _message;

  Future<void> _send() async {
    final email = widget.emailController.text.trim().toLowerCase();
    if (!email.contains('@')) {
      setState(() => _message = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _isSending = true;
      _message = null;
    });
    try {
      await widget.onSend(email);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSending = false;
          _message = 'Could not send reset email. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter your email address to receive a password reset link.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(
              _message!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSending ? null : _send,
          child: Text(_isSending ? 'Sending...' : 'Send Reset Link'),
        ),
      ],
    );
  }
}
