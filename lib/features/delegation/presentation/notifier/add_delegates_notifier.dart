import 'package:get/get_utils/get_utils.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/add_delegates_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/add_delegates_form.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

part 'add_delegates_notifier.g.dart';

/// The add delegates dialog: pick addresses, then one `Delegate/set`. See ADR-0115.
@riverpod
class AddDelegatesNotifier extends _$AddDelegatesNotifier with InteractorConsumer {
  @override
  AddDelegatesForm build() => const AddDelegatesForm();

  /// Adds [emailAddress] as a chip, or returns why it is refused.
  DelegateAddressRefusal? pick(
    EmailAddress emailAddress, {
    required String ownUsername,
    required Set<String> delegateUsernames,
  }) {
    final username = emailAddress.emailAddress.trim().toLowerCase();
    if (!GetUtils.isEmail(username) && !AppUtils.isEmailLocalhost(username)) {
      return DelegateAddressRefusal.invalid;
    }
    if (username == ownUsername.toLowerCase()) return DelegateAddressRefusal.yourself;
    if (delegateUsernames.any((delegate) => delegate.toLowerCase() == username)) {
      return DelegateAddressRefusal.alreadyDelegate;
    }
    if (state.candidates.any((candidate) => candidate.username.toLowerCase() == username)) {
      return DelegateAddressRefusal.alreadyPicked;
    }
    final candidate = DelegateCandidate(EmailAddress(emailAddress.name, emailAddress.emailAddress.trim()));
    state = state.copyWith(candidates: [...state.candidates, candidate]);
    return null;
  }

  void unpick(DelegateCandidate candidate) {
    if (state.isSubmitting) return;
    state = state.copyWith(candidates: state.candidates.where((item) => item != candidate).toList());
  }

  void typeAddress(String text) {
    if (text != state.pendingAddress) state = state.copyWith(pendingAddress: text);
  }

  bool get _hasChipsToSend => state.candidates.isNotEmpty && state.canAdd;

  /// Sends one `Delegate/set` for every chip.
  Future<AddDelegatesSubmission> submit(Session session) async {
    if (state.isSubmitting || !_hasChipsToSend) return const AddDelegatesIgnored();
    final usernames = state.candidates.map((candidate) => candidate.username).toSet();
    final interactor = ref.read(addDelegatesInteractorProvider);
    state = state.copyWith(isSubmitting: true);

    AddDelegatesResult? result;
    await consumeInteractor(InteractorConsumeRequest(
      run: () => interactor.execute(session, usernames).last,
      // The dialog cannot close while this runs, and a created delegate must reach the caller anyway.
      isStale: () => false,
      onSuccess: (success) {
        if (success is AddDelegatesSuccess) result = success.result;
      },
      onFailure: (_, __) {},
    ));
    final added = result;
    if (ref.mounted) state = _formAfter(added);
    return added == null ? const AddDelegatesFailed() : AddDelegatesSucceeded(added);
  }

  AddDelegatesForm _formAfter(AddDelegatesResult? result) {
    if (result == null) return state.copyWith(isSubmitting: false);
    final rejected = state.candidates
        .where((candidate) => result.rejectedUsernames.containsKey(candidate.username))
        .map((candidate) => DelegateCandidate(candidate.emailAddress, isRejected: true))
        .toList();
    // Nothing rejected closes the dialog, so the chips stay while it fades out.
    if (rejected.isEmpty) return state.copyWith(isSubmitting: false);
    return AddDelegatesForm(candidates: rejected);
  }
}
