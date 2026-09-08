import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_intent_config.dart';

abstract class WorkplaceBridgeDataSource {
  bool get isAvailable;
  Future<WorkplaceIntent> createIntent(WorkplaceIntentConfig config);
}
