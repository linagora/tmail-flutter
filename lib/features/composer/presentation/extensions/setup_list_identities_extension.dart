
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';

extension SetupListIdentitiesExtension on ComposerController {

  Future<void> setupListIdentities(ComposerArguments arguments) async {
    final identities = arguments.identities ?? [];
    // The identities given by the dashboard are the shown mailbox's.
    if (identities.isEmpty || isComposingOutsideShownAccount) {
      await getAllIdentitiesAsSynchronize();
    } else {
      listFromIdentities.value = identities;
      fromIdentitiesAccountId = composerAccountId;
    }
  }

  Future<void> getAllIdentitiesAsSynchronize() async {
    final accountId = composerAccountId;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId == null || session == null) return;

    final resultState = await getAllIdentitiesInteractor.execute(
      session,
      accountId,
    ).last;

    final uiState = resultState.fold((failure) => failure, (success) => success);

    if (uiState is GetAllIdentitiesSuccess) {
      applyFromPickerIdentities(uiState.identities);
    } else if (uiState is GetAllIdentitiesFailure) {
      consumeState(Stream.value(Left(uiState)));
    }
  }

  void applyFromPickerIdentities(List<Identity>? identities) {
    final fromList = (identities ?? []).forComposerFromPicker(
      keepServerDefaults: _keepsServerDefaultIdentities,
    );
    if (fromList.isNotEmpty) {
      listFromIdentities.value = fromList;
      fromIdentitiesAccountId = composerAccountId;
    }
  }

  /// Only a delegated mailbox offers its server default identities, whichever mailbox is shown.
  bool get _keepsServerDefaultIdentities => isComposingOutsideShownAccount
      ? composerAccountId != mailboxDashBoardController.accountId.value
      : mailboxDashBoardController.shownAccountCapabilities.offersServerDefaultIdentities;
}