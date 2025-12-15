import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/email_property.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/smime_signature_status.dart';

void main() {
  group('EmailExtension::sMimeStatus::test', () {
    test(
      'SHOULD returns `SMimeSignatureStatus.goodSignature`\n'
      'WHEN email has sMimeStatusHeader is `Good signature`\n'
      'AND headers is null', () {
      final email = Email(
        sMimeStatusHeader: {
          IndividualHeaderIdentifier.sMimeStatusHeader: 'Good signature'
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.goodSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.goodSignature`\n'
      'WHEN email has headers is `Good signature`\n'
      'AND sMimeStatusHeader is null', () {
      final email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerSMimeStatusKey,
            'Good signature')
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.goodSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.badSignature`\n'
      'WHEN sMimeStatusHeader is `Bad signature`',
    () {
      final email = Email(
        sMimeStatusHeader: {
          IndividualHeaderIdentifier.sMimeStatusHeader: 'Bad signature'
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.badSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.badSignature`\n'
      'WHEN headers is `Bad signature`',
    () {
      final email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerSMimeStatusKey,
            'Bad signature')
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.badSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN sMimeStatusHeader is not `Good signature` or `Bad signature`',
    () {
      final email = Email(
        sMimeStatusHeader: {
          IndividualHeaderIdentifier.sMimeStatusHeader: 'SomeOtherValue'
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headers is not `Good signature` or `Bad signature`',
    () {
      final email = Email(headers: {
        EmailHeader(
          EmailProperty.headerSMimeStatusKey,
          'SomeOtherValue')
      });

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headers is `Good signatures`',
    () {
      final email = Email(headers: {
        EmailHeader(
          EmailProperty.headerSMimeStatusKey,
          'Good signatures')
      });

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headers is `Good Signatures`',
    () {
      final email = Email(headers: {
        EmailHeader(
          EmailProperty.headerSMimeStatusKey,
          'Good Signatures')
      });

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headers is `Bad signatures`',
    () {
      final email = Email(headers: {
        EmailHeader(
          EmailProperty.headerSMimeStatusKey,
          'Bad signatures')
      });

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headers is `Bad Signatures`',
    () {
      final email = Email(headers: {
        EmailHeader(
          EmailProperty.headerSMimeStatusKey,
          'Bad Signatures')
      });

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headers is null AND sMimeStatusHeader is NULL',
    () {
      final email = Email(headers: null, sMimeStatusHeader: null);

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headers is empty AND sMimeStatusHeader is null',
    () {
      final email = Email(headers: {}, sMimeStatusHeader: null);

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.goodSignature`\n'
      'WHEN sMimeStatusHeader is ` Good signature`',
    () {
      final email = Email(
        sMimeStatusHeader: {
          IndividualHeaderIdentifier.sMimeStatusHeader: ' Good signature'
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.goodSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.badSignature`\n'
      'WHEN sMimeStatusHeader is ` Bad signature`',
    () {
      final email = Email(
        sMimeStatusHeader: {
          IndividualHeaderIdentifier.sMimeStatusHeader: '  Bad signature'
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.badSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.goodSignature`\n'
      'WHEN headerSMimeStatusKey has value is ` Good signature`',
    () {
      final email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerSMimeStatusKey,
            ' Good signature'
          )
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.goodSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.badSignature`\n'
      'WHEN headerSMimeStatusKey has value is ` Bad signature`',
    () {
      final email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerSMimeStatusKey,
            ' Bad signature'
          )
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.badSignature);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN sMimeStatusHeader is ` Good signatures`',
    () {
      final email = Email(
        sMimeStatusHeader: {
          IndividualHeaderIdentifier.sMimeStatusHeader: ' Good signatures'
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN sMimeStatusHeader is ` Bad signatures`',
    () {
      final email = Email(
        sMimeStatusHeader: {
          IndividualHeaderIdentifier.sMimeStatusHeader: '  Bad signatures'
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headerSMimeStatusKey has value is ` Good signatures`',
    () {
      final email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerSMimeStatusKey,
            ' Good signatures'
          )
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });

    test(
      'SHOULD returns `SMimeSignatureStatus.notSigned`\n'
      'WHEN headerSMimeStatusKey has value is ` Bad signatures`',
    () {
      final email = Email(
        headers: {
          EmailHeader(
            EmailProperty.headerSMimeStatusKey,
            ' Bad signatures'
          )
        }
      );

      expect(email.sMimeStatus, SMimeSignatureStatus.notSigned);
    });
  });

  group('EmailExtension.toggleKeyword', () {
    final keyword = KeyWordIdentifier.emailSeen;

    test(
      'Email(keywords: null).toggleKeyword(x, false) '
      '=> keywords contains x:true',
      () {
        final email = Email(keywords: null);

        final result = email.toggleKeyword(keyword: keyword, remove: false);

        expect(result.keywords, isNotNull);
        expect(result.keywords!.length, 1);
        expect(result.keywords![keyword], true);
      },
    );

    test(
      'Email(keywords: {x:true}).toggleKeyword(x, true) '
      '=> keywords does not contain x',
      () {
        final email = Email(
          keywords: {
            keyword: true,
          },
        );

        final result = email.toggleKeyword(keyword: keyword, remove: true);

        expect(result.keywords, isNotNull);
        expect(result.keywords!.containsKey(keyword), false);
      },
    );

    test(
      'Idempotency: remove keyword when already absent '
      '=> keywords unchanged',
      () {
        final email = Email(
          keywords: {
            KeyWordIdentifier.emailFlagged: true,
          },
        );

        final result = email.toggleKeyword(keyword: keyword, remove: true);

        expect(result.keywords!.length, 1);
        expect(
          result.keywords!.containsKey(KeyWordIdentifier.emailFlagged),
          true,
        );
        expect(result.keywords!.containsKey(keyword), false);
      },
    );

    test(
      'Idempotency: add keyword when already present '
      '=> keyword remains true, no duplication',
      () {
        final email = Email(
          keywords: {
            keyword: true,
          },
        );

        final result = email.toggleKeyword(keyword: keyword, remove: false);

        expect(result.keywords!.length, 1);
        expect(result.keywords![keyword], true);
      },
    );

    test(
      'toggleKeyword returns new Email instance '
      '(immutability)',
      () {
        final email = Email(
          keywords: {
            keyword: true,
          },
        );

        final result = email.toggleKeyword(keyword: keyword, remove: true);

        expect(identical(email, result), false);
      },
    );
  });
}
