import 'package:cozy/cozy_config_manager/cozy_config_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inside_cozy_provider.g.dart';

/// Whether the app runs embedded in Cozy; resolved once per process.
@Riverpod(keepAlive: true)
FutureOr<bool> insideCozy(Ref ref) => CozyConfigManager().isInsideCozy;
