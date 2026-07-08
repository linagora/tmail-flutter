import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/twp_warning/twp_warning.dart';
import 'package:model/email/twp_warning/twp_warning_level.dart';
import 'package:tmail_ui_user/features/email/presentation/model/twp_warning_code.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import 'twp_warning_code_resolver_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AppLocalizations>()])
void main() {
  late MockAppLocalizations l10n;

  TwpWarning warning({String? code, String fallbackText = 'server fallback'}) =>
      TwpWarning(
        level: TwpWarningLevel.warn,
        code: code,
        fallbackText: fallbackText,
        index: 0,
      );

  setUp(() {
    l10n = MockAppLocalizations();
    when(l10n.twpWarningSuspiciousSender).thenReturn('localized suspicious');
    when(l10n.twpWarningVirus).thenReturn('localized virus');
    when(l10n.twpWarningVirusRemoved).thenReturn('localized virus removed');
  });

  group('TwpWarningCodeResolver.resolveMessage', () {
    test('returns the localized message for known codes', () {
      expect(
        TwpWarningCodeResolver.resolveMessage(
          warning(code: 'suspicious-sender'),
          l10n,
        ),
        'localized suspicious',
      );
      expect(
        TwpWarningCodeResolver.resolveMessage(warning(code: 'virus'), l10n),
        'localized virus',
      );
      expect(
        TwpWarningCodeResolver.resolveMessage(
          warning(code: 'virus-removed'),
          l10n,
        ),
        'localized virus removed',
      );
    });

    test('falls back to server text for an unknown code', () {
      expect(
        TwpWarningCodeResolver.resolveMessage(
          warning(code: 'unknown', fallbackText: 'raw text'),
          l10n,
        ),
        'raw text',
      );
    });

    test('falls back to server text when there is no code', () {
      expect(
        TwpWarningCodeResolver.resolveMessage(
          warning(code: null, fallbackText: 'raw text'),
          l10n,
        ),
        'raw text',
      );
    });

    test('falls back to server text when the localized string is empty', () {
      when(l10n.twpWarningVirus).thenReturn('');
      expect(
        TwpWarningCodeResolver.resolveMessage(
          warning(code: 'virus', fallbackText: 'raw text'),
          l10n,
        ),
        'raw text',
      );
    });
  });
}
