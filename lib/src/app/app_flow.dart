import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/auth/application/registration_draft.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/models/founder_profile.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/community/domain/repositories/community_repository.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/presentation/dashboard_screens.dart';
import '../features/directory/domain/repositories/directory_repository.dart';

class AppFlow extends StatefulWidget {
  const AppFlow({
    super.key,
    required this.authRepository,
    required this.dashboardRepository,
    required this.directoryRepository,
    required this.communityRepository,
  });

  final AuthRepository authRepository;
  final DashboardRepository dashboardRepository;
  final DirectoryRepository directoryRepository;
  final CommunityRepository communityRepository;

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  AppScreen _screen = AppScreen.splash;
  int _dashboardTab = 0;
  final RegistrationDraft _registrationDraft = RegistrationDraft();
  FounderProfile? _currentProfile;
  var _isAuthLoading = false;
  String? _authError;

  void _go(AppScreen screen) {
    if (_currentProfile != null && screen != AppScreen.dashboard) {
      _enterDashboard(_dashboardTab);
      return;
    }

    setState(() {
      _screen = screen;
    });
  }

  void _enterDashboard([int tab = 0]) {
    setState(() {
      _dashboardTab = tab;
      _screen = AppScreen.dashboard;
      _authError = null;
    });
  }

  Future<void> _finishSplash() async {
    final profile = await widget.authRepository.currentProfile();
    if (!mounted) {
      return;
    }
    if (profile == null) {
      _go(AppScreen.onboarding);
      return;
    }
    setState(() => _currentProfile = profile);
    _enterDashboard();
  }

  Future<void> _register() async {
    setState(() {
      _isAuthLoading = true;
      _authError = null;
    });

    try {
      final draftProfile = _registrationDraft.toFounderProfile(uid: '');
      final profile = await widget.authRepository.registerWithEmailAndPassword(
        email: _registrationDraft.email,
        password: _registrationDraft.password,
        profile: draftProfile,
      );
      _currentProfile = profile;
      _enterDashboard();
    } catch (error) {
      debugPrint('Registration failed: $error');
      setState(() => _authError = _friendlyAuthError(error));
    } finally {
      if (mounted) {
        setState(() => _isAuthLoading = false);
      }
    }
  }

  Future<void> _signIn(String email, String password) async {
    setState(() {
      _isAuthLoading = true;
      _authError = null;
    });

    try {
      final profile = await widget.authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentProfile = profile;
      _enterDashboard();
    } catch (error) {
      debugPrint('Sign in failed: $error');
      setState(() => _authError = _friendlyAuthError(error));
    } finally {
      if (mounted) {
        setState(() => _isAuthLoading = false);
      }
    }
  }

  Future<void> _updateProfile(FounderProfile profile) async {
    final updatedProfile = await widget.authRepository.updateProfile(profile);
    if (!mounted) {
      return;
    }
    setState(() => _currentProfile = updatedProfile);
  }

  Future<void> _signOut() async {
    await widget.authRepository.signOut();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentProfile = null;
      _dashboardTab = 0;
      _screen = AppScreen.login;
      _authError = null;
    });
  }

  String _friendlyAuthError(Object error) {
    if (error is AuthFailure) {
      return error.message;
    }

    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' =>
          'That email is already registered. Sign in instead.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Use a stronger password.',
        'wrong-password' ||
        'invalid-credential' ||
        'user-not-found' => 'Email or password is incorrect.',
        'operation-not-allowed' =>
          'Email/password sign-in is not enabled in Firebase Authentication.',
        'network-request-failed' =>
          'Network connection failed. Check your connection and try again.',
        'too-many-requests' =>
          'Too many attempts. Wait a moment and try again.',
        _ => error.message ?? 'Firebase Auth error: ${error.code}.',
      };
    }

    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' =>
          'Firestore denied profile creation. Deploy the latest Firestore rules.',
        'unavailable' =>
          'Firestore is unavailable. Check your connection and try again.',
        'not-found' => 'Firestore is not ready for this Firebase project yet.',
        _ => error.message ?? 'Firebase error: ${error.code}.',
      };
    }

    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      AppScreen.splash => SplashScreen(onFinished: _finishSplash),
      AppScreen.onboarding => OnboardingScreen(
        onGetStarted: () => _go(AppScreen.registerAccount),
        onSignIn: () => _go(AppScreen.login),
      ),
      AppScreen.login => LoginScreen(
        onJoin: () => _go(AppScreen.registerAccount),
        onSignedIn: _signIn,
        isLoading: _isAuthLoading,
        errorText: _authError,
      ),
      AppScreen.registerAccount => RegisterAccountScreen(
        draft: _registrationDraft,
        onNext: () => _go(AppScreen.registerProfile),
        onSignIn: () => _go(AppScreen.login),
      ),
      AppScreen.registerProfile => RegisterProfileScreen(
        draft: _registrationDraft,
        onBack: () => _go(AppScreen.registerAccount),
        onNext: () => _go(AppScreen.registerIndustry),
      ),
      AppScreen.registerIndustry => RegisterIndustryScreen(
        draft: _registrationDraft,
        onBack: () => _go(AppScreen.registerProfile),
        onNext: () => _go(AppScreen.registerNeeds),
      ),
      AppScreen.registerNeeds => RegisterNeedsScreen(
        draft: _registrationDraft,
        onBack: () => _go(AppScreen.registerIndustry),
        onDone: _register,
        isLoading: _isAuthLoading,
        errorText: _authError,
      ),
      AppScreen.dashboard => DashboardShell(
        profile: _currentProfile,
        dashboardRepository: widget.dashboardRepository,
        directoryRepository: widget.directoryRepository,
        communityRepository: widget.communityRepository,
        selectedIndex: _dashboardTab,
        onSaveProfile: _updateProfile,
        onSignOut: _signOut,
        onTabSelected: (index) => setState(() => _dashboardTab = index),
      ),
    };
  }
}

enum AppScreen {
  splash,
  onboarding,
  login,
  registerAccount,
  registerProfile,
  registerIndustry,
  registerNeeds,
  dashboard,
}
