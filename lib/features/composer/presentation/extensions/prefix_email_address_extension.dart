
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension PrefixEmailAddressExtension on PrefixEmailAddress {

  String asName(BuildContext context) {
    switch(this) {
      case PrefixEmailAddress.to:
        return AppLocalizations.of(context).to_email_address_prefix;
      case PrefixEmailAddress.cc:
        return AppLocalizations.of(context).cc_email_address_prefix;
      case PrefixEmailAddress.bcc:
        return AppLocalizations.of(context).bcc_email_address_prefix;
      case PrefixEmailAddress.replyTo:
        return AppLocalizations.of(context).reply_to_email_address_prefix;
      case PrefixEmailAddress.from:
        return AppLocalizations.of(context).from_email_address_prefix;
    }
  }

  List<EmailAddress> listEmailAddress(PresentationEmail email) {
    switch(this) {
      case PrefixEmailAddress.to:
        return email.to?.toList() ?? List.empty();
      case PrefixEmailAddress.cc:
        return email.cc?.toList() ?? List.empty();
      case PrefixEmailAddress.bcc:
        return email.bcc?.toList() ?? List.empty();
      case PrefixEmailAddress.replyTo:
        return email.replyTo?.toList() ?? List.empty();
      case PrefixEmailAddress.from:
        return email.from?.toList() ?? List.empty();
    }
  }
}