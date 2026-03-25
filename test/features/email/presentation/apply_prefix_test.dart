import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  group('EmailUtils::applyPrefix', () {
    group('Reply prefix', () {
      test('should add Re: prefix when subject has no prefix', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'Hello',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('Re: Hello'),
        );
      });

      test('should not add Re: prefix when subject already has Re:', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'Re: Hello',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('Re: Hello'),
        );
      });

      test('should not add prefix when subject has Re: case-insensitively', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'RE: Hello',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('RE: Hello'),
        );
      });

      test('should not add prefix when subject has re: lowercase', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 're: Hello',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('re: Hello'),
        );
      });
    });

    group('Forward prefix', () {
      test('should add Fwd: prefix when subject has no prefix', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'Hello',
            defaultPrefix: EmailUtils.defaultForwardPrefix,
          ),
          equals('Fwd: Hello'),
        );
      });

      test('should not add Fwd: prefix when subject already has Fwd:', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'Fwd: Hello',
            defaultPrefix: EmailUtils.defaultForwardPrefix,
          ),
          equals('Fwd: Hello'),
        );
      });

      test('should not add prefix when subject has FWD: uppercase', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'FWD: Hello',
            defaultPrefix: EmailUtils.defaultForwardPrefix,
          ),
          equals('FWD: Hello'),
        );
      });
    });

    group('Localized prefix', () {
      test('should use localized prefix when provided', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'Hello',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
            localizedPrefix: 'Rép:',
          ),
          equals('Rép: Hello'),
        );
      });

      test(
        'should not add prefix when subject already has localized prefix',
        () {
          expect(
            EmailUtils.applyPrefix(
              subject: 'Rép: Hello',
              defaultPrefix: EmailUtils.defaultReplyPrefix,
              localizedPrefix: 'Rép:',
            ),
            equals('Rép: Hello'),
          );
        },
      );

      test(
        'should not add prefix when subject has localized prefix '
        'case-insensitively',
        () {
          expect(
            EmailUtils.applyPrefix(
              subject: 'rép: Hello',
              defaultPrefix: EmailUtils.defaultReplyPrefix,
              localizedPrefix: 'Rép:',
            ),
            equals('rép: Hello'),
          );
        },
      );

      test(
        'should not add prefix when subject has default prefix '
        'even with localized prefix provided',
        () {
          expect(
            EmailUtils.applyPrefix(
              subject: 'Re: Hello',
              defaultPrefix: EmailUtils.defaultReplyPrefix,
              localizedPrefix: 'Rép:',
            ),
            equals('Re: Hello'),
          );
        },
      );
    });

    group('Edge cases', () {
      test('should handle empty subject', () {
        expect(
          EmailUtils.applyPrefix(
            subject: '',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('Re: '),
        );
      });

      test('should handle subject with only spaces', () {
        expect(
          EmailUtils.applyPrefix(
            subject: '   ',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('Re:    '),
        );
      });

      test('should preserve original subject when prefix already exists', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'Re:   Hello  ',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('Re:   Hello  '),
        );
      });

      test('should handle subject that contains prefix in middle', () {
        expect(
          EmailUtils.applyPrefix(
            subject: 'Hello Re: World',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('Re: Hello Re: World'),
        );
      });

      test('should handle subject with leading spaces before prefix', () {
        expect(
          EmailUtils.applyPrefix(
            subject: '  Re: Hello',
            defaultPrefix: EmailUtils.defaultReplyPrefix,
          ),
          equals('  Re: Hello'),
        );
      });
    });
  });
}
