import '../../../auth/domain/models/founder_profile.dart';
import '../models/community_message.dart';
import '../models/community_room.dart';

abstract class CommunityRepository {
  Stream<List<CommunityMessage>> watchRoomMessages(CommunityRoom room);

  Future<void> addRoomMessage({
    required CommunityRoom room,
    required FounderProfile author,
    required String content,
  });
}
