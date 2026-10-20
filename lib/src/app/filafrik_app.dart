import 'package:flutter/material.dart';

import '../core/app_colors.dart';
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

class FilAfrikApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilAfrik Founders Circle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          brightness: Brightness.dark,
        ),
        fontFamily: 'DM Sans',
      ),
      home: AppFlow(
        authRepository: authRepository ?? FirebaseAuthRepository(),
        dashboardRepository:
            dashboardRepository ?? FirebaseDashboardRepository(),
        directoryRepository:
            directoryRepository ?? FirebaseDirectoryRepository(),
        communityRepository:
            communityRepository ?? FirebaseCommunityRepository(),
        resourceRepository:
            resourceRepository ?? FirebaseResourceRepository(),
        adminRepository:
            adminRepository ?? FirebaseAdminRepository(),
      ),
    );
  }
}
