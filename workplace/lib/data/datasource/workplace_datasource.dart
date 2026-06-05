import '../../domain/entity/workplace_intent.dart';

abstract class WorkplaceDataSource {
  Future<WorkplaceIntent> createIntent(Uri platformUrl, String accessToken);
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
