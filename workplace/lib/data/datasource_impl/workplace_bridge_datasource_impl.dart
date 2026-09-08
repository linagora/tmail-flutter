import '../bridge/cozy_bridge.dart';
import '../datasource/workplace_bridge_datasource.dart';
import '../mapper/workplace_intent_mapper.dart';
import '../../domain/entity/workplace_intent.dart';
import '../../domain/entity/workplace_intent_config.dart';

/// Bridge route: the container app proxies the call with its own stack session.
class WorkplaceBridgeDataSourceImpl implements WorkplaceBridgeDataSource {
  WorkplaceBridgeDataSourceImpl();

  @override
  bool get isAvailable => CozyBridge.isSupported && CozyBridge.isAvailable;

  @override
  Future<WorkplaceIntent> createIntent(WorkplaceIntentConfig config) async {
    final data = await CozyBridge.fetchJson(
      method: 'POST',
      path: '/intents',
      body: buildIntentRequestBody(config),
    );
    return parseIntentResponse(data);
  }
}
