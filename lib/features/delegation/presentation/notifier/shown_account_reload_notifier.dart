import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shown_account_reload_notifier.g.dart';

/// Reloads the account already shown when a switch attempt ends on it, which no account change does.
@riverpod
class ShownAccountReloadNotifier extends _$ShownAccountReloadNotifier {
  @override
  int? build() => null;

  void request(int switchAttemptId) => state = switchAttemptId;
}
