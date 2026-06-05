import '../entity/workplace_intent.dart';

abstract class WorkplaceRepository {
  Future<WorkplaceIntent> createIntent(Uri platformUrl, String accessToken);
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
