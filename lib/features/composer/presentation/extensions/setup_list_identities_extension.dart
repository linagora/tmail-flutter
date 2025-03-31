
import 'package:dartz/dartz.dart';
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
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId == null || session == null) return;

    final resultState = await getAllIdentitiesInteractor.execute(
      session,
      accountId,
    ).last;

    final uiState = resultState.fold((failure) => failure, (success) => success);

    if (uiState is GetAllIdentitiesSuccess) {
      final identitiesMayDeleted = uiState.identities?.toListMayDeleted() ?? [];
      if (identitiesMayDeleted.isNotEmpty) {
        listFromIdentities.value = identitiesMayDeleted;
      }
    } else if (uiState is GetAllIdentitiesFailure) {
      consumeState(Stream.value(Left(uiState)));
    }
  }
}