import '../../domain/entity/workplace_intent.dart';

abstract class WorkplaceDataSource {
  Future<WorkplaceIntent> createIntent(
    Uri platformUrl,
    String accessToken, {
    required String sharingLink,
    required String downloadLink,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
