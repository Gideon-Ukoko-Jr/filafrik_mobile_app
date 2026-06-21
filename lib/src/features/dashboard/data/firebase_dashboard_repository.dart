import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/dashboard_stats_data.dart';
import '../domain/repositories/dashboard_repository.dart';

class FirebaseDashboardRepository implements DashboardRepository {
  FirebaseDashboardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<DashboardStatsData> loadHomeStats() async {
    final results = await Future.wait([
      _safeCount(_firestore.collection('users')),
      _safeCount(
        _firestore.collection('businesses').where('isListed', isEqualTo: true),
      ),
      _safeCount(_firestore.collection('rooms')),
      _safeCount(_firestore.collection('announcements')),
    ]);

    return DashboardStatsData(
      members: results[0],
      listedBusinesses: results[1],
      rooms: results[2],
      announcements: results[3],
    );
  }

  Future<int> _safeCount(Query<Map<String, dynamic>> query) async {
    try {
      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } on FirebaseException {
      return 0;
    }
  }
}
