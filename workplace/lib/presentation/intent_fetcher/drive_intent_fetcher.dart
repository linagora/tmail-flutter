import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';

/// One way to obtain a Drive PICK intent. Each implementation owns its own
/// transport, authentication and availability check.
abstract class DriveIntentFetcher {
  bool get isAvailable;

  Future<WorkplaceIntent> fetchIntent(
    Uri platformUrl,
    WorkplaceIntentConfig config,
  );
}
