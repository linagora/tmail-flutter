import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_executor_service.dart';

part 'search_executor_provider.g.dart';

/// App-lifetime singleton bridging search consumers to the executor.
@Riverpod(keepAlive: true)
SearchExecutorService searchExecutorService(Ref ref) {
  final service = SearchExecutorService(ref.container);
  ref.onDispose(service.dispose);
  return service;
}
