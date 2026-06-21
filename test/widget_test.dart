import 'dart:async';

import 'package:filafrik_mobile_app/src/app/filafrik_app.dart';
import 'package:filafrik_mobile_app/src/features/auth/domain/models/founder_profile.dart';
import 'package:filafrik_mobile_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:filafrik_mobile_app/src/features/community/domain/models/community_message.dart';
import 'package:filafrik_mobile_app/src/features/community/domain/models/community_room.dart';
import 'package:filafrik_mobile_app/src/features/community/domain/repositories/community_repository.dart';
import 'package:filafrik_mobile_app/src/features/dashboard/domain/models/dashboard_stats_data.dart';
import 'package:filafrik_mobile_app/src/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:filafrik_mobile_app/src/features/directory/domain/repositories/directory_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthRepository authRepository;
  late FakeDashboardRepository dashboardRepository;
  late FakeDirectoryRepository directoryRepository;
  late FakeCommunityRepository communityRepository;

  setUp(() {
    authRepository = FakeAuthRepository();
    dashboardRepository = FakeDashboardRepository();
    directoryRepository = FakeDirectoryRepository();
    communityRepository = FakeCommunityRepository();
  });

  testWidgets('renders FilAfrik splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    expect(find.text('FILAFRIK'), findsOneWidget);
    expect(find.text('FOUNDERS CIRCLE'), findsOneWidget);
  });

  testWidgets('can move from onboarding to dashboard through registration', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pump();
    await tester.tap(find.text('Get Started'));
    await tester.pump();

    await tester.enterText(find.byType(EditableText).at(0), 'amara@kente.co');
    await tester.enterText(find.byType(EditableText).at(1), 'password123');
    await tester.enterText(find.byType(EditableText).at(2), 'password123');
    await tester.tap(find.text('Continue →'));
    await tester.pump();

    await tester.enterText(find.byType(EditableText).at(0), 'Amara Osei');
    await tester.enterText(find.byType(EditableText).at(1), 'Kente Digital');
    await tester.enterText(
      find.byType(EditableText).at(2),
      'Fintech for the African diaspora.',
    );
    await tester.enterText(find.byType(EditableText).at(3), 'kentedigital.com');
    await tester.enterText(find.byType(EditableText).at(4), 'London, ON');
    await tester.tap(find.text('Continue →'));
    await tester.pump();

    await tester.tap(find.text('Continue →'));
    await tester.pump();
    await tester.tap(find.text('Enter the Circle 🌍'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.text('Amara Osei'), findsOneWidget);
    expect(find.text('Kente Digital · Early Stage (0-1 yrs)'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.text('Events'), findsOneWidget);
    expect(authRepository.createdProfile?.businessName, 'Kente Digital');
    expect(authRepository.createdProfile?.website, 'kentedigital.com');
    expect(authRepository.createdProfile?.needs, contains('Funding & Grants'));
  });

  testWidgets('rejects invalid website during registration profile step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pump();
    await tester.tap(find.text('Get Started'));
    await tester.pump();

    await tester.enterText(find.byType(EditableText).at(0), 'amara@kente.co');
    await tester.enterText(find.byType(EditableText).at(1), 'password123');
    await tester.enterText(find.byType(EditableText).at(2), 'password123');
    await tester.tap(find.text('Continue →'));
    await tester.pump();

    await tester.enterText(find.byType(EditableText).at(0), 'Amara Osei');
    await tester.enterText(find.byType(EditableText).at(1), 'Kente Digital');
    await tester.enterText(
      find.byType(EditableText).at(2),
      'Fintech for the African diaspora.',
    );
    await tester.enterText(find.byType(EditableText).at(3), 'not-a-url');
    await tester.enterText(find.byType(EditableText).at(4), 'London, ON');
    await tester.tap(find.text('Continue →'));
    await tester.pump();

    expect(
      find.text('Enter a valid website or leave it blank.'),
      findsOneWidget,
    );
    expect(authRepository.createdProfile, isNull);
  });

  testWidgets('opens a business profile from the directory', (
    WidgetTester tester,
  ) async {
    authRepository.createdProfile = directoryRepository.profiles.first;

    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kente Digital'));
    await tester.pumpAndSettle();

    expect(find.text('Industry'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('London, ON'), findsOneWidget);
    expect(find.text('Founded'), findsOneWidget);
    expect(find.text('Not available'), findsWidgets);
    expect(find.text('Funding & Grants'), findsOneWidget);
    expect(find.text('Mentorship'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(find.text('Connect with Amara Osei'), findsOneWidget);
    expect(find.text('Visit Website'), findsOneWidget);
  });

  testWidgets('searches and filters directory businesses', (
    WidgetTester tester,
  ) async {
    authRepository.createdProfile = directoryRepository.profiles.first;

    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dir'));
    await tester.pumpAndSettle();

    expect(find.text('Kente Digital'), findsOneWidget);
    expect(find.text('Sahel Kitchen'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(find.text('Kente Digital'), findsNothing);
    expect(find.text('Sahel Kitchen'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'kente');
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('Kente Digital'), findsOneWidget);
    expect(find.text('Sahel Kitchen'), findsNothing);
  });

  testWidgets('opens directory from home quick access', (
    WidgetTester tester,
  ) async {
    authRepository.createdProfile = directoryRepository.profiles.first;

    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Directory'));
    await tester.pumpAndSettle();

    expect(find.text('Search businesses...'), findsOneWidget);
    expect(find.text('Kente Digital'), findsOneWidget);
    expect(find.text('Sahel Kitchen'), findsOneWidget);
  });

  testWidgets('opens community room from chat tab', (
    WidgetTester tester,
  ) async {
    authRepository.createdProfile = directoryRepository.profiles.first;

    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Community Rooms'), findsOneWidget);
    expect(find.text('Open Rooms'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Tech & Innovation'), findsOneWidget);
    expect(find.text('Accredited Lounge'), findsOneWidget);

    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();

    expect(find.text('Live room'), findsOneWidget);
    expect(find.text('No posts yet. Start the conversation.'), findsOneWidget);
    expect(find.text('Write a post or question...'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Hello founders');
    await tester.tap(find.text('⇧'));
    await tester.pumpAndSettle();

    expect(
      communityRepository.messagesFor('general').single.content,
      'Hello founders',
    );
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Hello founders'), findsOneWidget);

    await tester.tap(find.text('←'));
    await tester.pumpAndSettle();

    expect(find.text('Community Rooms'), findsOneWidget);
  });

  testWidgets('shows profile details and saves edits from me tab', (
    WidgetTester tester,
  ) async {
    authRepository.createdProfile = directoryRepository.profiles.first;

    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('kentedigital.com'), findsOneWidget);
    expect(find.text('Listed Member'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile_business_field')),
      'Kente Labs',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(authRepository.createdProfile?.businessName, 'Kente Labs');
    expect(find.text('Kente Labs'), findsOneWidget);
  });

  testWidgets('validates profile edits and allows blank website', (
    WidgetTester tester,
  ) async {
    authRepository.createdProfile = directoryRepository.profiles.first;

    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('profile_name_field')),
      '',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name and business name are required.'), findsOneWidget);
    expect(authRepository.createdProfile?.displayName, 'Amara Osei');

    await tester.enterText(
      find.byKey(const ValueKey('profile_name_field')),
      'Amara Osei',
    );
    await tester.drag(
      find.byKey(const ValueKey('profile_edit_list')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile_website_field')),
      'not-a-url',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(authRepository.createdProfile?.website, 'kentedigital.com');

    await tester.enterText(
      find.byKey(const ValueKey('profile_website_field')),
      '',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(authRepository.createdProfile?.website, '');
    expect(find.text('Website not available.'), findsOneWidget);
  });

  testWidgets('signs out from me tab', (WidgetTester tester) async {
    authRepository.createdProfile = directoryRepository.profiles.first;

    await tester.pumpWidget(
      FilAfrikApp(
        authRepository: authRepository,
        dashboardRepository: dashboardRepository,
        directoryRepository: directoryRepository,
        communityRepository: communityRepository,
      ),
    );

    await tester.tap(find.text('FILAFRIK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(authRepository.createdProfile, isNull);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}

class FakeAuthRepository implements AuthRepository {
  FounderProfile? createdProfile;

  @override
  Stream<FounderProfile?> authStateChanges() => Stream.value(createdProfile);

  @override
  Future<FounderProfile?> currentProfile() async => createdProfile;

  @override
  Future<FounderProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
    required FounderProfile profile,
  }) async {
    createdProfile = FounderProfile(
      uid: 'test-uid',
      email: email,
      displayName: profile.displayName,
      businessName: profile.businessName,
      industry: profile.industry,
      businessStage: profile.businessStage,
      needs: profile.needs,
      bio: profile.bio,
      website: profile.website,
      city: profile.city,
    );
    return createdProfile!;
  }

  @override
  Future<FounderProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    createdProfile = FounderProfile(
      uid: 'test-uid',
      email: email,
      displayName: 'Amara Osei',
      businessName: 'Kente Digital',
      industry: 'Technology',
      businessStage: 'Early Stage (0-1 yrs)',
      needs: const ['Funding & Grants'],
      website: 'kentedigital.com',
    );
    return createdProfile!;
  }

  @override
  Future<FounderProfile> updateProfile(FounderProfile profile) async {
    createdProfile = profile;
    return profile;
  }

  @override
  Future<void> signOut() async {
    createdProfile = null;
  }
}

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStatsData> loadHomeStats() async {
    return const DashboardStatsData(
      members: 5,
      listedBusinesses: 12,
      rooms: 6,
      announcements: 2,
    );
  }
}

class FakeDirectoryRepository implements DirectoryRepository {
  final profiles = const [
    FounderProfile(
      uid: 'test-uid',
      email: 'amara@kente.co',
      displayName: 'Amara Osei',
      businessName: 'Kente Digital',
      industry: 'Technology',
      businessStage: 'Early Stage (0-1 yrs)',
      needs: ['Funding & Grants', 'Mentorship'],
      bio: 'Fintech for the African diaspora.',
      website: 'kentedigital.com',
      city: 'London, ON',
    ),
    FounderProfile(
      uid: 'test-uid-2',
      email: 'fatima@sahel.co',
      displayName: 'Fatima Diallo',
      businessName: 'Sahel Kitchen',
      industry: 'Food',
      businessStage: 'Growth Stage',
      needs: ['Partnerships'],
      bio: 'West African cuisine catering.',
      city: 'Toronto, ON',
      isAccredited: true,
    ),
  ];

  @override
  Stream<List<FounderProfile>> watchFounderProfiles() {
    return Stream.value(profiles);
  }
}

class FakeCommunityRepository implements CommunityRepository {
  final Map<String, List<CommunityMessage>> _messagesByRoom = {};
  final Map<String, StreamController<List<CommunityMessage>>> _controllers = {};

  List<CommunityMessage> messagesFor(String roomId) {
    return List.unmodifiable(_messagesByRoom[roomId] ?? const []);
  }

  @override
  Stream<List<CommunityMessage>> watchRoomMessages(CommunityRoom room) async* {
    yield messagesFor(room.id);
    yield* _controllerFor(room.id).stream;
  }

  @override
  Future<void> addRoomMessage({
    required CommunityRoom room,
    required FounderProfile author,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final messages = _messagesByRoom.putIfAbsent(room.id, () => []);
    messages.add(
      CommunityMessage(
        id: 'message-${messages.length + 1}',
        roomId: room.id,
        authorId: author.uid,
        authorName: author.displayName,
        authorInitials: _initials(author.displayName),
        content: trimmed,
        createdAt: DateTime(2026, 6, 21, 9, 22),
      ),
    );
    _controllerFor(room.id).add(List.unmodifiable(messages));
  }

  StreamController<List<CommunityMessage>> _controllerFor(String roomId) {
    return _controllers.putIfAbsent(
      roomId,
      () => StreamController<List<CommunityMessage>>.broadcast(),
    );
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
}
