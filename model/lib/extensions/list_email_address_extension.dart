import 'package:core/presentation/extensions/html_extension.dart';
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

  String toEscapeHtmlString(String separator) {
    if (this?.isNotEmpty != true) return '';

    final listEmail = this
      !.map((emailAddress) => emailAddress.asFullStringWithLtGtCharacter().escapeLtGtHtmlString())
      .toList();

    return listEmail.isNotEmpty ? listEmail.join(separator) : '';
  }

  String toEscapeHtmlStringUseCommaSeparator() => toEscapeHtmlString(', ');

  int numberEmailAddress() => this != null ? this!.length : 0;

  List<EmailAddress> filterEmailAddress(String emailAddressNotExist) {
    return this != null
      ? this!.where((emailAddress) => emailAddress.email != emailAddressNotExist).toList()
      : List.empty();
  }

  Set<EmailAddress> withoutMe(String userName) {
    return filterEmailAddress(userName).toSet();
  }

  List<EmailAddress> removeDuplicateEmails() {
    final seenEmails = <String>{};
    return this?.where((emailAddress) {
      if (emailAddress.emailAddress.isEmpty ||
          seenEmails.contains(emailAddress.emailAddress)) {
        return false;
      } else {
        seenEmails.add(emailAddress.emailAddress);
        return true;
      }
    }).toList() ?? [];
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

  List<EmailAddress> withoutMe(String? userName) {
    if (userName == null) return this;

    return where((emailAddress) => emailAddress.emailAddress != userName).toList();
  }

  List<EmailAddress> removeDuplicateEmails() {
    final seenEmails = <String>{};
    return where((emailAddress) {
      if (emailAddress.emailAddress.isEmpty ||
          seenEmails.contains(emailAddress.emailAddress)) {
        return false;
      } else {
        seenEmails.add(emailAddress.emailAddress);
        return true;
      }
    }).toList();
  }
}