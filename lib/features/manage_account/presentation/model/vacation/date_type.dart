
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum DateType {
  start,
  end;

  String getTitle(BuildContext context) {
    switch(this) {
      case DateType.start:
        return AppLocalizations.of(context).startDate;
      case DateType.end:
        return AppLocalizations.of(context).endDate;
    }
  }
}