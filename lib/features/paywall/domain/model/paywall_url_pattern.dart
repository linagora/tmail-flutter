import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';

class PaywallUrlPattern with EquatableMixin {
  final String pattern;

  PaywallUrlPattern(this.pattern);

  String getQualifiedUrl({required String ownerEmail, String? domainName}) {
    final mailAddress = EmailUtils.getMailAddress(ownerEmail: ownerEmail);
    return PaywallUtils.buildPaywallUrlFromTemplate(
      template: pattern,
      localPart: mailAddress?.localPart,
      domainName: domainName ?? mailAddress?.domain.domainName,
    );
  }

  @override
  List<Object> get props => [pattern];
}
