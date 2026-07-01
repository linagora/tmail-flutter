import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Resolves the displayed message for a [TwpWarning]: the localized string for a
/// known [TwpWarning.code], else the server-provided `fallbackText`.
///
/// New codes only need an entry in [_registry] plus a localized getter.
class TwpWarningCodeResolver {
  TwpWarningCodeResolver._();

  static final Map<String, String Function(AppLocalizations)> _registry = {
    'suspicious-sender': (l10n) => l10n.twpWarningSuspiciousSender,
    'virus': (l10n) => l10n.twpWarningVirus,
    'virus-removed': (l10n) => l10n.twpWarningVirusRemoved,
  };

  static String resolveMessage(
    TwpWarning warning,
    AppLocalizations appLocalizations,
  ) {
    final code = warning.code;
    final localizedMessage = code != null
        ? _registry[code]?.call(appLocalizations)
        : null;
    if (localizedMessage != null && localizedMessage.isNotEmpty) {
      return localizedMessage;
    }
    return warning.fallbackText;
  }
}
