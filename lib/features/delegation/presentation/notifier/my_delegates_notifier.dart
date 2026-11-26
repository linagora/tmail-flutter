import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/get_delegates_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';

part 'my_delegates_notifier.g.dart';

/// The people who can use my mailbox, listed in Settings › Delegation. See ADR-0115.
@riverpod
class MyDelegatesNotifier extends _$MyDelegatesNotifier with InteractorConsumer {
  int _latestLoadId = 0;

  @override
  AsyncValue<List<Delegate>> build() => const AsyncLoading();

  Future<void> load(Session session) async {
    final loadId = ++_latestLoadId;
    // A reload keeps the current list on screen instead of a spinner.
    if (!state.hasValue) state = const AsyncLoading();
    final interactor = ref.read(getDelegatesInteractorProvider);
    await consumeInteractor(InteractorConsumeRequest(
      run: () => interactor.execute(session).last,
      // A slow earlier read must not overwrite a newer list.
      isStale: () => !ref.mounted || loadId != _latestLoadId,
      onSuccess: (success) {
        if (success is GetDelegatesSuccess) {
          state = AsyncData(success.delegates);
        }
      },
      onFailure: (error, stackTrace) => state = AsyncError(error, stackTrace),
    ));
  }
}
