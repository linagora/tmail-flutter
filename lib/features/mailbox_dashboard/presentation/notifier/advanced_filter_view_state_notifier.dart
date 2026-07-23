import 'package:model/mailbox/expand_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/advanced_filter_view_state.dart';

part 'advanced_filter_view_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class AdvancedFilterViewStateNotifier
    extends _$AdvancedFilterViewStateNotifier {
  @override
  AdvancedFilterViewState build() => AdvancedFilterViewState.initial();

  void setFromAddressExpandMode(ExpandMode mode) {
    state = state.copyWith(fromAddressExpandMode: mode);
  }

  void setToAddressExpandMode(ExpandMode mode) {
    state = state.copyWith(toAddressExpandMode: mode);
  }

  void reset() {
    state = AdvancedFilterViewState.initial();
  }
}
