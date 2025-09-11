import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

mixin OwnEmailAddressMixin {
  static const String emptyOwnEmailAddress = '';

  final RxString ownEmailAddress = RxString('');
  Session? sessionCurrent;

  void synchronizeOwnEmailAddress(String emailAddress) {
    log('$runtimeType::synchronizeOwnEmailAddress:OwnEmailAddress = ${ownEmailAddress.value}, NewEmailAddress = $emailAddress');
    if (ownEmailAddress.value.trim().isNotEmpty) return;
    ownEmailAddress.value = emailAddress;
  }

  void updateOwnEmailAddressFromIdentities(List<Identity> listIdentities) {
    if (ownEmailAddress.value.trim().isNotEmpty) return;

    if (listIdentities.isEmpty) {
      synchronizeOwnEmailAddress(emptyOwnEmailAddress);
      ownEmailAddress.refresh();
      return;
    }

    final identityEmailAddress = listIdentities.firstOrNull?.email ?? '';
    final domain = EmailUtils.getDomainByEmailAddress(identityEmailAddress);
    final userEmailAddress =
        sessionCurrent?.generateOwnEmailAddressFromDomain(domain) ?? '';
    log('$runtimeType::updateOwnEmailAddressFromIdentities: UserEmailAddress = $userEmailAddress');

    if (userEmailAddress.isNotEmpty) {
      synchronizeOwnEmailAddress(userEmailAddress);
    } else {
      synchronizeOwnEmailAddress(emptyOwnEmailAddress);
      ownEmailAddress.refresh();
    }
  }
}
