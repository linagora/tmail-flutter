import 'package:core/utils/mail/domain.dart';
import 'package:core/utils/mail/mail_address.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';

class PaywallUrlPattern with EquatableMixin {
  final String pattern;

  PaywallUrlPattern(this.pattern);

  String _getQualifiedUrl({required String ownerEmail, String? domainName}) {
    final values = _resolveValues(ownerEmail: ownerEmail, domainName: domainName);
    return PaywallUtils.buildPaywallUrlFromTemplate(
      template: pattern,
      localPart: values.localPart,
      domainName: values.domainName,
    );
  }

  /// Resolves [pattern], or null when a placeholder cannot be filled — a
  /// half-filled URL points at the wrong host.
  String? resolveQualifiedUrl({required String ownerEmail, String? domainName}) {
    final values = _resolveValues(ownerEmail: ownerEmail, domainName: domainName);
    if (_isPlaceholderUnfilled('localPart', values.localPart) ||
        _isPlaceholderUnfilled('domainName', values.domainName)) {
      return null;
    }
    return _getQualifiedUrl(ownerEmail: ownerEmail, domainName: domainName);
  }

  ({String? localPart, String? domainName}) _resolveValues({
    required String ownerEmail,
    String? domainName,
  }) {
    final mailAddress = _getMailAddress(ownerEmail: ownerEmail);
    return (
      localPart: mailAddress?.localPart.replaceAll('.', ''),
      domainName: domainName ?? mailAddress?.domain.domainName,
    );
  }

  bool _isPlaceholderUnfilled(String name, String? value) =>
      PaywallUtils.usesPlaceholder(pattern, name) &&
      (value == null || value.isEmpty);

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
