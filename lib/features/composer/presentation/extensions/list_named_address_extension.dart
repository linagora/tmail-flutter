import 'package:core/utils/mail/named_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/named_address_extension.dart';

extension ListNamedAddressExtension on List<NamedAddress> {
  List<EmailAddress> toFilteredEmailAddressList(
    List<EmailAddress> existingEmails,
  ) {
    final existingEmailSet = existingEmails.toNormalizedEmailSet();
    final seen = <String>{};
    return where((named) {
      final normalized = named.normalizedAddress;
      return !existingEmailSet.contains(normalized) && seen.add(normalized);
    }).map((named) => named.validateToEmailAddress()).toList();
  }
}
