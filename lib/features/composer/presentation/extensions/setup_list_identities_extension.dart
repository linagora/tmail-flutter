
import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';

extension SetupListIdentitiesExtension on ComposerController {

  Future<void> setupListIdentities(ComposerArguments arguments) async {
    final identities = arguments.identities ?? [];
    log('SetupListIdentitiesExtension::setupListIdentities:identities_Size = ${identities.length}');
    if (identities.isEmpty) {
      await getAllIdentitiesAsSynchronize();
    } else {
      listFromIdentities.value = identities;
    }
  }

  Future<void> getAllIdentitiesAsSynchronize() async {
    log('SetupListIdentitiesExtension::getAllIdentitiesAsSynchronize:');
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId == null || session == null) return;

    final resultState = await getAllIdentitiesInteractor.execute(
      session,
      accountId,
    ).last;

    resultState.foldSuccess<GetAllIdentitiesSuccess>(
      onFailure: (failure) => failure != null
        ? consumeState(Stream.value(Left(failure)))
        : null,
      onSuccess: (success) {
        final identitiesMayDeleted = success.identities?.toListMayDeleted() ?? [];
        if (identitiesMayDeleted.isNotEmpty) {
          listFromIdentities.value = identitiesMayDeleted;
        }
      },
    );
  }
}