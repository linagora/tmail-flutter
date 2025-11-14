import 'package:core/utils/mail/domain.dart';
import 'package:core/utils/mail/mail_address.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';

class PaywallUrlPattern with EquatableMixin {
  final String pattern;

  PaywallUrlPattern(this.pattern);

  String getQualifiedUrl({required String ownerEmail, String? domainName}) {
    final mailAddress = _getMailAddress(ownerEmail: ownerEmail);
    return PaywallUtils.buildPaywallUrlFromTemplate(
      template: pattern,
      localPart: mailAddress?.localPart.replaceAll('.', ''),
      domainName: domainName ?? mailAddress?.domain.domainName,
    );
  }

  MailAddress? _getMailAddress({required String ownerEmail}) {
    try {
      return MailAddress.validateAddress(ownerEmail);
    } catch (e) {
      if (GetUtils.isEmail(ownerEmail)) {
        final listPart = ownerEmail.split('@');
        if (listPart.length == 2) {
          return MailAddress(
            localPart: listPart.first,
            domain: Domain.of((listPart.last)),
          );
        }
      }
      return null;
    }
  }

  @override
  List<Object> get props => [pattern];
}
