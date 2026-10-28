import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shown_account_input_block_notifier.g.dart';

/// Auto-disposed with its view, so a session ended mid-switch never leaves the next dashboard blocked.
@riverpod
class ShownAccountInputBlockNotifier extends _$ShownAccountInputBlockNotifier {
  @override
  bool build() => false;

  void block() => state = true;

  void unblock() => state = false;
}
