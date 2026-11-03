import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/models/founder_profile.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<FounderProfile?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) {
      if (user == null) {
        return null;
      }
      return _loadProfile(user.uid);
    });
  }

  @override
  Future<FounderProfile?> currentProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return _loadProfile(user.uid);
  }

  @override
  Future<FounderProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
    required FounderProfile profile,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const AuthFailure('Registration did not return a Firebase user.');
    }

    final profileForUser = FounderProfile(
      uid: user.uid,
      email: profile.email,
      displayName: profile.displayName,
      businessName: profile.businessName,
      industry: profile.industry,
      businessStage: profile.businessStage,
      needs: profile.needs,
      bio: profile.bio,
      website: profile.website,
      city: profile.city,
    );

    try {
      await user.updateDisplayName(profile.displayName);
      await _users.doc(user.uid).set(profileForUser.toCreateFirestore());
    } on FirebaseException catch (error) {
      await _deletePartiallyCreatedUser(user);
      throw AuthFailure(
        'Account created, but profile setup failed: ${error.code}. Please try again.',
        code: error.code,
      );
    } catch (error) {
      await _deletePartiallyCreatedUser(user);
      throw AuthFailure(
        'Account created, but profile setup failed. Please try again.',
        cause: error,
      );
    }

    return profileForUser;
  }

  @override
  Future<FounderProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const AuthFailure('Login did not return a Firebase user.');
    }

    await _users.doc(user.uid).set({
      'lastSeenAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return _loadProfile(user.uid);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure('No signed-in user.');
    await user.delete();
  }

  @override
  Future<FounderProfile> updateProfile(FounderProfile profile) async {
    await _users
        .doc(profile.uid)
        .set(profile.toUpdateFirestore(), SetOptions(merge: true));
    await _auth.currentUser?.updateDisplayName(profile.displayName);
    return _loadProfile(profile.uid);
  }

  Future<FounderProfile> _loadProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure('No signed-in Firebase user.');
      }

      final profile = FounderProfile(
        uid: uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        businessName: '',
        industry: 'Other',
        businessStage: 'Idea Stage',
        needs: const ['Networking'],
      );
      await _users.doc(uid).set(profile.toCreateFirestore());
      return profile;
    }
    return FounderProfile.fromFirestore(doc);
  }

  Future<void> _deletePartiallyCreatedUser(User user) async {
    try {
      await user.delete();
    } on FirebaseAuthException {
      await _auth.signOut();
    }
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    if (code != null) {
      return '$message ($code)';
    }
    if (cause != null) {
      return '$message ($cause)';
    }
    return message;
  }
}
