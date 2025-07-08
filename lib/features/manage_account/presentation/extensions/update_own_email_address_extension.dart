
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';

extension UpdateOwnEmailAddressExtension on ManageAccountDashBoardController {

  void synchronizeOwnEmailAddress(String emailAddress) {
    log('UpdateOwnEmailAddressExtension::synchronizeOwnEmailAddress:OwnEmailAddress = ${ownEmailAddress.value}, NewEmailAddress = $emailAddress');
    if (ownEmailAddress.value.isNotEmpty || emailAddress.isEmpty) return;
    ownEmailAddress.value = emailAddress;
  }

  void updateOwnEmailAddressFromIdentities(List<Identity> listIdentities) {
    final identityEmailAddress = listIdentities.firstOrNull?.email ?? '';

    if (identityEmailAddress.isNotEmpty) {
      synchronizeOwnEmailAddress(identityEmailAddress);
    } else {
      synchronizeOwnEmailAddress(sessionCurrent?.getUserDisplayName() ?? '');
    }
  }
}