import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/theme_controller.dart';
import '../features/admin/data/firebase_admin_repository.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/community/data/firebase_community_repository.dart';
import '../features/community/domain/repositories/community_repository.dart';
import '../features/dashboard/data/firebase_dashboard_repository.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/directory/data/firebase_directory_repository.dart';
import '../features/directory/domain/repositories/directory_repository.dart';
import '../features/resources/data/firebase_resource_repository.dart';
import '../features/resources/domain/repositories/resource_repository.dart';
import 'app_flow.dart';

class FilAfrikApp extends StatefulWidget {
  const FilAfrikApp({
    super.key,
    this.authRepository,
    this.dashboardRepository,
    this.directoryRepository,
    this.communityRepository,
    this.resourceRepository,
    this.adminRepository,
  });

  final AuthRepository? authRepository;
  final DashboardRepository? dashboardRepository;
  final DirectoryRepository? directoryRepository;
  final CommunityRepository? communityRepository;
  final ResourceRepository? resourceRepository;
  final AdminRepository? adminRepository;

  @override
  State<FilAfrikApp> createState() => _FilAfrikAppState();
}

class _FilAfrikAppState extends State<FilAfrikApp> {
  ThemeController? _themeController;

  @override
  void initState() {
    super.initState();
    ThemeController.load().then((controller) {
      if (!mounted) return;
      setState(() => _themeController = controller);
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _themeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _themeController;
    return MaterialApp(
      title: 'FilAfrik Founders Circle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: controller?.value ?? ThemeMode.system,
      home: AppFlow(
        authRepository: widget.authRepository ?? FirebaseAuthRepository(),
        dashboardRepository:
            widget.dashboardRepository ?? FirebaseDashboardRepository(),
        directoryRepository:
            widget.directoryRepository ?? FirebaseDirectoryRepository(),
        communityRepository:
            widget.communityRepository ?? FirebaseCommunityRepository(),
        resourceRepository:
            widget.resourceRepository ?? FirebaseResourceRepository(),
        adminRepository:
            widget.adminRepository ?? FirebaseAdminRepository(),
        themeMode: controller?.value ?? ThemeMode.system,
        onThemeModeChanged:
            controller != null ? controller.setMode : (_) async {},
      ),
    );
  }
}
