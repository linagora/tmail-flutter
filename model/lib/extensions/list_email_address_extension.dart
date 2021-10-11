import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/extensions/email_address_extension.dart';

extension ListEmailAddressExtension on Set<EmailAddress>? {

  List<String>? getListAddress() => this?.map((emailAddress) => emailAddress.emailAddress).toList();

  List<EmailAddress> asList() => this != null ? this!.toList() : List.empty();

  List<String> getListEmailAddress({ExpandMode expandMode = ExpandMode.EXPAND, int limitAddress = 1, bool isFullEmailAddress = false}) {
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
    final listEmail = getListEmailAddress(expandMode: expandMode, limitAddress: limitAddress, isFullEmailAddress: isFullEmailAddress);
    return listEmail.isNotEmpty ? listEmail.join(', ') : '';
  }

  int numberEmailAddress() => this != null ? this!.length : 0;

  List<EmailAddress> filterEmailAddress(EmailAddress emailAddressNotExist) {
    return this != null
      ? this!.where((emailAddress) => emailAddress.email != emailAddressNotExist.email)
             .toList()
      : List.empty();
  }
}