import 'package:core/presentation/utils/app_toast.dart';
import 'package:mockito/mockito.dart';

import '../features/delegation/presentation/session_from_cache_to_dashboard_test.mocks.dart';

/// Captures the error and success toast texts via a generated mock so test
/// files do not hand-write a 5-arg override (CodeScene).
class RecordingAppToast {
  final List<String> errorMessages = [];
  final List<String> successMessages = [];
  final MockAppToast _toast = MockAppToast();

  RecordingAppToast() {
    when(_toast.showToastErrorMessage(any, any)).thenAnswer((invocation) {
      errorMessages.add(invocation.positionalArguments[1] as String);
    });
    when(_toast.showToastSuccessMessage(any, any)).thenAnswer((invocation) {
      successMessages.add(invocation.positionalArguments[1] as String);
    });
  }

  AppToast get toast => _toast;
}
