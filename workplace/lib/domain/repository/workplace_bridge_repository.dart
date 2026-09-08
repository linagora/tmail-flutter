import '../entity/workplace_intent.dart';
import '../entity/workplace_intent_config.dart';

abstract class WorkplaceBridgeRepository {
  bool get isAvailable;
  Future<WorkplaceIntent> createIntent(WorkplaceIntentConfig config);
}
