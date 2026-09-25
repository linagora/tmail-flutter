import 'package:core/domain/exceptions/address_exception.dart';
import 'package:core/utils/mail/domain.dart';
import 'package:core/utils/mail/mail_address.dart';
import 'package:core/utils/url_template.dart';
import 'package:get/get.dart';

abstract final class UserUrlTemplateVariables {
  static const localPart = 'localPart';
  static const domainName = 'domainName';
  static const domainPart = 'domainPart';
  static const domainNames = {domainName, domainPart};
  static const names = {localPart, ...domainNames};
}

/// Adds user identity variables shared by URL templates.
class UserUrlTemplate {
  final UrlTemplate _template;

  UserUrlTemplate(String template) : _template = UrlTemplate(template);

  UserUrlTemplate.fromUrlTemplate(this._template);

  String? resolve({
    String? ownerEmail,
    String? domainName,
    Map<String, String?> variables = const {},
    Set<String> caseInsensitiveVariables = const {},
  }) {
    final needsMailAddress = _usesPlaceholder(
          UserUrlTemplateVariables.localPart,
          caseInsensitiveVariables,
        ) ||
        domainName == null &&
            UserUrlTemplateVariables.domainNames.any(
              (name) => _usesPlaceholder(name, caseInsensitiveVariables),
            );
    final mailAddress = needsMailAddress
        ? _getMailAddress(ownerEmail?.trim() ?? '')
        : null;
    final resolvedDomain = domainName ?? mailAddress?.domain.domainName;
    final domainValue =
        resolvedDomain?.isEmpty == true ? null : resolvedDomain;
    return _template.resolve(
      variables: {
        UserUrlTemplateVariables.localPart:
            mailAddress?.localPart.replaceAll('.', ''),
        UserUrlTemplateVariables.domainName: domainValue,
        UserUrlTemplateVariables.domainPart: domainValue,
        ...variables,
      },
      caseInsensitiveVariables: caseInsensitiveVariables,
    );
  }

  bool _usesPlaceholder(
    String name,
    Set<String> caseInsensitiveVariables,
  ) => _template.usesPlaceholder(
    name,
    caseSensitive: !caseInsensitiveVariables.contains(name),
  );
}

MailAddress? _getMailAddress(String ownerEmail) {
  try {
    return MailAddress.validateAddress(ownerEmail);
  } on AddressException {
    if (!GetUtils.isEmail(ownerEmail)) return null;

    final parts = ownerEmail.split('@');
    if (parts.length != 2) return null;
    return MailAddress(
      localPart: parts.first,
      domain: Domain.of(parts.last),
    );
  }
}
