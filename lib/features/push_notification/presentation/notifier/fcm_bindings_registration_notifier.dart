import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fcm_bindings_registration_notifier.g.dart';

/// Counts the FCM interactor registrations, so work that needs them retries once they exist.
@Riverpod(keepAlive: true)
class FcmBindingsRegistrationNotifier extends _$FcmBindingsRegistrationNotifier {
  @override
  int build() => 0;

  void registered() => state++;
}
