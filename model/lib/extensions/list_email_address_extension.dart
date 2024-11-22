import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/extensions/email_address_extension.dart';

extension SetEmailAddressExtension on Set<EmailAddress>? {

  List<String>? getListAddress() => this?.map((emailAddress) => emailAddress.emailAddress).toList();

  List<EmailAddress> asList() => this != null ? this!.toList() : List.empty();

  Set<EmailAddress> asSet() => this ?? {};

  List<String> emailAddressToListString({ExpandMode expandMode = ExpandMode.EXPAND, int limitAddress = 1, bool isFullEmailAddress = false}) {
    if (this != null) {
      if (expandMode == ExpandMode.EXPAND) {
        return this!.map((emailAddress) => isFullEmailAddress ? emailAddress.asFullString() : emailAddress.asString()).toList();
      } else {
        final address = this!.map((emailAddress) => isFullEmailAddress ? emailAddress.asFullString() : emailAddress.asString()).toList();
        return address.length > limitAddress ? address.sublist(0, limitAddress) : address;
      }
    }
    return [];
  }

  String listEmailAddressToString({ExpandMode expandMode = ExpandMode.EXPAND, int limitAddress = 1, bool isFullEmailAddress = false}) {
    final listEmail = emailAddressToListString(expandMode: expandMode, limitAddress: limitAddress, isFullEmailAddress: isFullEmailAddress);
    return listEmail.isNotEmpty ? listEmail.join(', ') : '';
  }

  int numberEmailAddress() => this != null ? this!.length : 0;

  List<EmailAddress> filterEmailAddress(String emailAddressNotExist) {
    return this != null
      ? this!.where((emailAddress) => emailAddress.email != emailAddressNotExist).toList()
      : List.empty();
  }
}

extension ListEmailAddressExtension on List<EmailAddress> {
  Set<String> asSetAddress() => map((emailAddress) => emailAddress.emailAddress).toSet();

  List<EmailAddress> removeInvalidEmails(String username) {
    final Set<String> seenEmails = {};
    return where((email) {
      if (email.emailAddress.isEmpty) return false;
      if (email.emailAddress == username) return false;
      return seenEmails.add(email.emailAddress);
    }).toList();
  }
}