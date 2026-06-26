import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Resolves the message displayed for a [TwpWarning].
///
/// The backend ships a fallback text inside the `X-TWP-Message` header together
/// with a [TwpWarning.code]. When the code is known to the frontend we favour
/// the localized message; otherwise (unknown code or no localization) we fall
/// back to the server provided text.
///
/// New codes only require a new entry in [_registry] and its localized getter.
class TwpWarningCodeResolver {
  TwpWarningCodeResolver._();

  static final Map<String, String Function(AppLocalizations)> _registry = {
    'suspicious-sender': (l10n) => l10n.twpWarningSuspiciousSender,
    'virus': (l10n) => l10n.twpWarningVirus,
    'virus-removed': (l10n) => l10n.twpWarningVirusRemoved,
  };

  static String resolveMessage(TwpWarning warning, AppLocalizations appLocalizations) {
    final code = warning.code;
    final localizedMessage = code != null ? _registry[code]?.call(appLocalizations) : null;
    if (localizedMessage != null && localizedMessage.isNotEmpty) {
      return localizedMessage;
    }
    return warning.fallbackText;
  }
}
