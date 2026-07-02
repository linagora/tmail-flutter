import 'package:model/email/twp_warning.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class TwpWarningMessages {
  const TwpWarningMessages._();

  static String resolve(AppLocalizations l10n, TwpWarning warning) {
    switch (warning.code) {
      case 'suspicious-sender':
        return l10n.twpWarningSuspiciousSender;
      case 'virus-detected':
        return l10n.twpWarningVirusDetected;
      default:
        return warning.fallbackText;
    }
  }
}
