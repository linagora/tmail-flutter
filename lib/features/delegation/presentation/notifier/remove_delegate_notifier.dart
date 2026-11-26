import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/remove_delegate_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/remove_delegate_submission.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';

part 'remove_delegate_notifier.g.dart';

/// The remove delegate dialog: true while its `Delegate/set` runs. See ADR-0115.
@riverpod
class RemoveDelegateNotifier extends _$RemoveDelegateNotifier with InteractorConsumer {
  @override
  bool build() => false;

  Future<RemoveDelegateSubmission> submit(Session session, Delegate delegate) async {
    if (state) return const RemoveDelegateIgnored();
    final interactor = ref.read(removeDelegateInteractorProvider);
    state = true;

    RemoveDelegateResult? result;
    await consumeInteractor(InteractorConsumeRequest(
      run: () => interactor.execute(session, delegate).last,
      // The dialog cannot close while this runs, and a removed delegate must reach the caller anyway.
      isStale: () => false,
      onSuccess: (success) {
        if (success is RemoveDelegateSuccess) result = success.result;
      },
      onFailure: (_, __) {},
    ));
    if (ref.mounted) state = false;
    final removed = result;
    return removed == null ? const RemoveDelegateFailed() : RemoveDelegateSucceeded(removed);
  }
}
