import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mdn_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/submission_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/vacation_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/collation_identifier.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/error/request_error.dart';

void main() {
  group('capability_validator_test', () {
    test('when session missing one capability exception should throw', () {
      final session = Session(
          {
            CapabilityIdentifier.jmapSubmission:
                SubmissionCapability(UnsignedInt(0), {}),
            CapabilityIdentifier.jmapMail: MailCapability(
                UnsignedInt(10000000),
                null,
                UnsignedInt(200),
                UnsignedInt(20000000),
                {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                true),
            CapabilityIdentifier.jmapWebSocket:
                WebSocketCapability(true, Uri.parse('ws://domain.com/jmap/ws')),
            CapabilityIdentifier(
                    Uri.parse('urn:apache:james:params:jmap:mail:quota')):
                DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier(
                    Uri.parse('urn:apache:james:params:jmap:mail:shares')):
                DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
            CapabilityIdentifier.jmapMdn: MdnCapability()
          },
          {
            AccountId(Id(
                    '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')):
                Account(AccountName('bob@domain.tld'), true, false, {
              CapabilityIdentifier.jmapSubmission:
                  SubmissionCapability(UnsignedInt(0), {}),
              CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
                  true, Uri.parse('ws://domain.com/jmap/ws')),
              CapabilityIdentifier.jmapMail: MailCapability(
                  UnsignedInt(10000000),
                  null,
                  UnsignedInt(200),
                  UnsignedInt(20000000),
                  {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                  true),
              CapabilityIdentifier(
                      Uri.parse('urn:apache:james:params:jmap:mail:quota')):
                  DefaultCapability(<String, dynamic>{}),
              CapabilityIdentifier(
                      Uri.parse('urn:apache:james:params:jmap:mail:shares')):
                  DefaultCapability(<String, dynamic>{}),
              CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
              CapabilityIdentifier.jmapMdn: MdnCapability()
            })
          },
          {
            CapabilityIdentifier.jmapSubmission: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapWebSocket: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapCore: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMail: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:quota')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:shares')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapVacationResponse: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMdn: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
          },
          UserName('bob@domain.tld'),
          Uri.parse('http://domain.com/jmap'),
          Uri.parse(
              'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
          Uri.parse('http://domain.com/upload/{accountId}'),
          Uri.parse(
              'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
          State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'));
      expect(
        () => requireCapability(
            session,
            AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            [CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail]),
        throwsA(const TypeMatcher<SessionMissingCapability>()));
    });

    test('when account capabilities is empty exception should throw', () {
      final session = Session(
          {
            CapabilityIdentifier.jmapSubmission:
            SubmissionCapability(UnsignedInt(0), {}),
            CapabilityIdentifier.jmapMail: MailCapability(
                UnsignedInt(10000000),
                null,
                UnsignedInt(200),
                UnsignedInt(20000000),
                {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                true),
            CapabilityIdentifier.jmapWebSocket:
            WebSocketCapability(true, Uri.parse('ws://domain.com/jmap/ws')),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:quota')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:shares')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
            CapabilityIdentifier.jmapMdn: MdnCapability()
          },
          {
            AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')):
            Account(AccountName('bob@domain.tld'), true, false, <CapabilityIdentifier, CapabilityProperties>{})
          },
          {
            CapabilityIdentifier.jmapSubmission: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapWebSocket: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapCore: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMail: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:quota')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:shares')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapVacationResponse: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMdn: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
          },
          UserName('bob@domain.tld'),
          Uri.parse('http://domain.com/jmap'),
          Uri.parse(
              'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
          Uri.parse('http://domain.com/upload/{accountId}'),
          Uri.parse(
              'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
          State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'));
      expect(
        () => requireCapability(
            session,
            AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            [CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail]),
        throwsA(const TypeMatcher<SessionMissingCapability>()));
    });

    test('when accounts not have account with invalid accountId capability should throw', () {
      final invalidId = Id("29883977c13473ae7cb7678ef767cbffabfc8a44a6e463d971d23a65c1dc4af6");
      final session = Session(
          {
            CapabilityIdentifier.jmapSubmission:
            SubmissionCapability(UnsignedInt(0), {}),
            CapabilityIdentifier.jmapMail: MailCapability(
                UnsignedInt(10000000),
                null,
                UnsignedInt(200),
                UnsignedInt(20000000),
                {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                true),
            CapabilityIdentifier.jmapWebSocket:
            WebSocketCapability(true, Uri.parse('ws://domain.com/jmap/ws')),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:quota')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:shares')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
            CapabilityIdentifier.jmapMdn: MdnCapability()
          },
          {
            AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')):
            Account(AccountName('bob@domain.tld'), true, false, {
              CapabilityIdentifier.jmapSubmission:
              SubmissionCapability(UnsignedInt(0), {}),
              CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
                  true, Uri.parse('ws://domain.com/jmap/ws')),
              CapabilityIdentifier.jmapMail: MailCapability(
                  UnsignedInt(10000000),
                  null,
                  UnsignedInt(200),
                  UnsignedInt(20000000),
                  {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                  true),
              CapabilityIdentifier(
                  Uri.parse('urn:apache:james:params:jmap:mail:quota')):
              DefaultCapability(<String, dynamic>{}),
              CapabilityIdentifier(
                  Uri.parse('urn:apache:james:params:jmap:mail:shares')):
              DefaultCapability(<String, dynamic>{}),
              CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
              CapabilityIdentifier.jmapMdn: MdnCapability()
            })
          },
          {
            CapabilityIdentifier.jmapSubmission: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapWebSocket: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapCore: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMail: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:quota')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:shares')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapVacationResponse: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMdn: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
          },
          UserName('bob@domain.tld'),
          Uri.parse('http://domain.com/jmap'),
          Uri.parse(
              'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
          Uri.parse('http://domain.com/upload/{accountId}'),
          Uri.parse(
              'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
          State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'));
      expect(
        () => requireCapability(
            session,
            AccountId(invalidId),
            [CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail]),
        throwsA(const TypeMatcher<InvalidCapability>()));
    });

    test('when accounts empty should throw exception', () {
      final session = Session(
          {
            CapabilityIdentifier.jmapSubmission:
            SubmissionCapability(UnsignedInt(0), {}),
            CapabilityIdentifier.jmapMail: MailCapability(
                UnsignedInt(10000000),
                null,
                UnsignedInt(200),
                UnsignedInt(20000000),
                {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                true),
            CapabilityIdentifier.jmapWebSocket:
            WebSocketCapability(true, Uri.parse('ws://domain.com/jmap/ws')),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:quota')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:shares')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
            CapabilityIdentifier.jmapMdn: MdnCapability()
          },
          {},
          {
            CapabilityIdentifier.jmapSubmission: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapWebSocket: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapCore: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMail: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:quota')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:shares')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapVacationResponse: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMdn: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
          },
          UserName('bob@domain.tld'),
          Uri.parse('http://domain.com/jmap'),
          Uri.parse(
              'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
          Uri.parse('http://domain.com/upload/{accountId}'),
          Uri.parse(
              'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
          State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'));
      expect(
        () => requireCapability(
            session,
            AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            [CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail]),
        throwsA(const TypeMatcher<InvalidCapability>()));
    });

    test('when session have all required capabilities exception should not throw', () {
      final session = Session(
          {
            CapabilityIdentifier.jmapSubmission:
            SubmissionCapability(UnsignedInt(0), {}),
            CapabilityIdentifier.jmapCore: CoreCapability(
                UnsignedInt(20971520),
                UnsignedInt(4),
                UnsignedInt(10000000),
                UnsignedInt(4),
                UnsignedInt(16),
                UnsignedInt(500),
                UnsignedInt(500),
                {CollationIdentifier("i;unicode-casemap")}
            ),
            CapabilityIdentifier.jmapMail: MailCapability(
                UnsignedInt(10000000),
                null,
                UnsignedInt(200),
                UnsignedInt(20000000),
                {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                true),
            CapabilityIdentifier.jmapWebSocket:
            WebSocketCapability(true, Uri.parse('ws://domain.com/jmap/ws')),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:quota')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier(
                Uri.parse('urn:apache:james:params:jmap:mail:shares')):
            DefaultCapability(<String, dynamic>{}),
            CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
            CapabilityIdentifier.jmapMdn: MdnCapability()
          },
          {
            AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')):
            Account(AccountName('bob@domain.tld'), true, false, {
              CapabilityIdentifier.jmapSubmission:
              SubmissionCapability(UnsignedInt(0), {}),
              CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
                  true, Uri.parse('ws://domain.com/jmap/ws')),
              CapabilityIdentifier.jmapCore: CoreCapability(
                  UnsignedInt(20971520),
                  UnsignedInt(4),
                  UnsignedInt(10000000),
                  UnsignedInt(4),
                  UnsignedInt(16),
                  UnsignedInt(500),
                  UnsignedInt(500),
                  {CollationIdentifier("i;unicode-casemap")}),
              CapabilityIdentifier.jmapMail: MailCapability(
                  UnsignedInt(10000000),
                  null,
                  UnsignedInt(200),
                  UnsignedInt(20000000),
                  {"receivedAt", "sentAt", "size", "from", "to", "subject"},
                  true),
              CapabilityIdentifier(
                  Uri.parse('urn:apache:james:params:jmap:mail:quota')):
              DefaultCapability(<String, dynamic>{}),
              CapabilityIdentifier(
                  Uri.parse('urn:apache:james:params:jmap:mail:shares')):
              DefaultCapability(<String, dynamic>{}),
              CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
              CapabilityIdentifier.jmapMdn: MdnCapability()
            })
          },
          {
            CapabilityIdentifier.jmapSubmission: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapWebSocket: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapCore: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMail: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:quota')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier(
                Uri.parse(
                    'urn:apache:james:params:jmap:mail:shares')): AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapVacationResponse: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            CapabilityIdentifier.jmapMdn: AccountId(Id(
                '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
          },
          UserName('bob@domain.tld'),
          Uri.parse('http://domain.com/jmap'),
          Uri.parse(
              'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
          Uri.parse('http://domain.com/upload/{accountId}'),
          Uri.parse(
              'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
          State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
      );

      expect(
        () => requireCapability(
            session,
            AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
            [CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail]),
        returnsNormally);
    });
  });
}