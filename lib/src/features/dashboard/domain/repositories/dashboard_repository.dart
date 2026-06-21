import '../models/dashboard_stats_data.dart';

abstract class DashboardRepository {
  Future<DashboardStatsData> loadHomeStats();
}
