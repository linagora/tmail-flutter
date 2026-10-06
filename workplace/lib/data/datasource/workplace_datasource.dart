import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_access_mode.dart';
import '../../domain/entity/workplace_intent_config.dart';

abstract class WorkplaceDataSource {
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
