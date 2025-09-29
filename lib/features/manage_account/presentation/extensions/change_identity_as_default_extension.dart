import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/null_session_or_accountid_exception.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_default_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identities_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

extension VerifyDefaultIdentitySupportedExtension on IdentitiesController {
  bool get isDefaultIdentitySupported {
    final accountId = accountDashBoardController.accountId.value;
    final session = accountDashBoardController.sessionCurrent;
    if (session != null && accountId != null) {
      return [CapabilityIdentifier.jamesSortOrder].isSupported(
        session,
        accountId,
      );
    } else {
      return false;
    }
  }

  void changeIdentityAsDefault(Identity identity) {
    final accountId = accountDashBoardController.accountId.value;
    final session = accountDashBoardController.sessionCurrent;

    if (session != null && accountId != null && identity.id != null) {
      editIdentityAction(
        session,
        accountId,
        EditIdentityRequest.fromIdentityWithoutPublicAssets(
          identity.asDefault(),
        ),
      );
    } else {
      consumeState(
        Stream.value(
          Left(EditDefaultIdentityFailure(NullSessionOrAccountIdException())),
        ),
      );
    }
  }
}
