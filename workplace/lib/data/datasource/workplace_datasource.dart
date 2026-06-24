import '../../domain/entity/workplace_intent.dart';

abstract class WorkplaceDataSource {
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required String accessToken, 
    required String addAsLink,
    required String addAsAttachment,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
