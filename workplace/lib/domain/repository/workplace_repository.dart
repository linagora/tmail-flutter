import '../entity/workplace_intent.dart';
import '../entity/workplace_intent_access_mode.dart';
import '../entity/workplace_intent_config.dart';

abstract class WorkplaceRepository {
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceIntentAccessMode accessMode,
    required WorkplaceIntentConfig config,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
