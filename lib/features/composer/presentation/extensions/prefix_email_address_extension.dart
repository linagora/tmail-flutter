
import 'package:flutter/cupertino.dart';
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
    }
  }
}