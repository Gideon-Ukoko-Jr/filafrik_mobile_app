import '../../../auth/domain/models/founder_profile.dart';

abstract class DirectoryRepository {
  Stream<List<FounderProfile>> watchFounderProfiles();
}
