import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/models/founder_profile.dart';
import '../domain/repositories/directory_repository.dart';

class FirebaseDirectoryRepository implements DirectoryRepository {
  FirebaseDirectoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<FounderProfile>> watchFounderProfiles() {
    return _firestore
        .collection('users')
        .orderBy('businessName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(FounderProfile.fromFirestore)
              .where((profile) => profile.businessName.trim().isNotEmpty)
              .toList(),
        );
  }
}
