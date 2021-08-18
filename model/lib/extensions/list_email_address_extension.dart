import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/extensions/email_address_extension.dart';

extension ListEmailAddressExtension on Set<EmailAddress>? {

  List<String> getListEmailAddress({ExpandMode expandMode = ExpandMode.EXPAND, int limitAddress = 1}) {
    if (this != null) {
      if (expandMode == ExpandMode.EXPAND) {
        return this!.map((emailAddress) => emailAddress.asString()).toList();
      } else {
        final address = this!.map((emailAddress) => emailAddress.asString()).toList();
        return address.length > limitAddress ? address.sublist(0, limitAddress) : address;
      }
    }
    return [];
  }

  String listEmailAddressToString({ExpandMode expandMode = ExpandMode.EXPAND, int limitAddress = 1}) {
    return getListEmailAddress(expandMode: expandMode, limitAddress: limitAddress).join(', ');
  }

  int numberEmailAddress() => this != null ? this!.length : 0;
}