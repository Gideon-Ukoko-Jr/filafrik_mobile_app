import '../../../auth/domain/models/founder_profile.dart';
import '../../../community/domain/models/community_message.dart';
import '../models/admin_stats.dart';

abstract class AdminRepository {
  Future<AdminStats> loadStats();
  Stream<List<FounderProfile>> watchAllMembers();
  Future<void> setAccreditation(String uid, {required bool isAccredited});
  Future<void> postAnnouncement({
    required String title,
    required String content,
    bool isPinned,
  });
  Stream<List<Map<String, dynamic>>> watchAnnouncements();
  Stream<List<CommunityMessage>> watchRecentPosts();
  Future<void> deletePost(String postId);
}
