import '../entity/workplace_intent.dart';

abstract class WorkplaceRepository {
  Future<WorkplaceIntent> createIntent(
    Uri platformUrl,
    String accessToken, {
    required String sharingLink,
    required String downloadLink,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
