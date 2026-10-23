import '../../../auth/domain/models/founder_profile.dart';
import '../models/resource_item.dart';

abstract class ResourceRepository {
  Future<ResourcesResult> getResources(FounderProfile profile);

  Future<ResourcesResult> refreshResources(FounderProfile profile);
}
