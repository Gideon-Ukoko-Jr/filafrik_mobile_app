import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/community/data/firebase_community_repository.dart';
import '../features/community/domain/repositories/community_repository.dart';
import '../features/dashboard/data/firebase_dashboard_repository.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/directory/data/firebase_directory_repository.dart';
import '../features/directory/domain/repositories/directory_repository.dart';
import 'app_flow.dart';

class FilAfrikApp extends StatelessWidget {
  const FilAfrikApp({
    super.key,
    this.authRepository,
    this.dashboardRepository,
    this.directoryRepository,
    this.communityRepository,
  });

  final AuthRepository? authRepository;
  final DashboardRepository? dashboardRepository;
  final DirectoryRepository? directoryRepository;
  final CommunityRepository? communityRepository;

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
      ),
    );
  }
}
