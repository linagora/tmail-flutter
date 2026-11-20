import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/session_reload_notifier.dart';
import 'package:tmail_ui_user/main/exceptions/remote/method_level_exception.dart';

/// The GetX access to the session re-read a revoked mailbox needs (ADR-0092).
abstract interface class AccountNotFoundReporter {
  void reportAccountNotFound();
}

class RiverpodAccountNotFoundReporter implements AccountNotFoundReporter {
  final ProviderContainer _container;

  const RiverpodAccountNotFoundReporter(this._container);

  @override
  void reportAccountNotFound() {
    _container.read(sessionReloadProvider.notifier).reloadOnAccountNotFound();
  }
}

bool isAccountNotFound(Object? exception) {
  if (exception is MethodLevelErrors) {
    return exception.type == ErrorMethodResponse.accountNotFound;
  }
  return exception is ErrorMethodResponseException &&
      exception.errorResponse is AccountNotFoundMethodResponse;
}
