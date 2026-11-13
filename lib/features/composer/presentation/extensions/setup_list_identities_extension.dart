
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';

extension SetupListIdentitiesExtension on ComposerController {

  Future<void> setupListIdentities(ComposerArguments arguments) async {
    final identities = arguments.identities ?? [];
    if (identities.isEmpty) {
      await getAllIdentitiesAsSynchronize();
    } else {
      listFromIdentities.value = identities;
    }
  }

  Future<void> getAllIdentitiesAsSynchronize() async {
    final accountId = mailboxDashBoardController.activeAccountId;
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
      keepServerDefaults: mailboxDashBoardController.shownAccountCapabilities.offersServerDefaultIdentities,
    );
    if (fromList.isNotEmpty) {
      listFromIdentities.value = fromList;
    }
  }
}