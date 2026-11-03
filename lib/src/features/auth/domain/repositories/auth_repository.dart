import '../models/founder_profile.dart';

abstract class AuthRepository {
  Stream<FounderProfile?> authStateChanges();

  Future<FounderProfile?> currentProfile();

  Future<FounderProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
    required FounderProfile profile,
  });

  Future<FounderProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<FounderProfile> updateProfile(FounderProfile profile);

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);

  Future<void> deleteAccount();
}
