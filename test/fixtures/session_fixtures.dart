import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
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

class SessionFixtures {
  static final aliceSession = Session(
    {
      CapabilityIdentifier.jmapSubmission: SubmissionCapability(
        maxDelayedSend: UnsignedInt(0),
        submissionExtensions: {}
      ),
      CapabilityIdentifier.jmapCore: CoreCapability(
        maxSizeUpload: UnsignedInt(20971520),
        maxConcurrentUpload: UnsignedInt(4),
        maxSizeRequest: UnsignedInt(10000000),
        maxConcurrentRequests: UnsignedInt(4),
        maxCallsInRequest: UnsignedInt(16),
        maxObjectsInGet: UnsignedInt(500),
        maxObjectsInSet: UnsignedInt(500),
        collationAlgorithms: {CollationIdentifier("i;unicode-casemap")}
      ),
      CapabilityIdentifier.jmapMail: MailCapability(
        maxMailboxesPerEmail: UnsignedInt(10000000),
        maxSizeAttachmentsPerEmail: UnsignedInt(20000000),
        emailQuerySortOptions: {"receivedAt", "sentAt", "size", "from", "to", "subject"},
        mayCreateTopLevelMailbox: true
      ),
      CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
        supportsPush: true,
        url: Uri.parse('ws://domain.com/jmap/ws')
      ),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): DefaultCapability(<String, dynamic>{}),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): DefaultCapability(<String, dynamic>{}),
      CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
      CapabilityIdentifier.jmapMdn: MdnCapability(),
    },
    {
      AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')): Account(
        AccountName('bob@domain.tld'),
        true,
        false,
        {
          CapabilityIdentifier.jmapSubmission: SubmissionCapability(
            maxDelayedSend: UnsignedInt(0),
            submissionExtensions: {}
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('ws://domain.com/jmap/ws')
          ),
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(20971520),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(500),
            collationAlgorithms: {CollationIdentifier("i;unicode-casemap")}
          ),
          CapabilityIdentifier.jmapMail: MailCapability(
            maxMailboxesPerEmail: UnsignedInt(10000000),
            maxSizeAttachmentsPerEmail: UnsignedInt(20000000),
            emailQuerySortOptions: {"receivedAt", "sentAt", "size", "from", "to", "subject"},
            mayCreateTopLevelMailbox: true
          ),
          CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): DefaultCapability(<String, dynamic>{}),
          CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): DefaultCapability(<String, dynamic>{}),
          CapabilityIdentifier.jmapVacationResponse: VacationCapability(),
          CapabilityIdentifier.jmapMdn: MdnCapability()
        }
      )
    },
    {
      CapabilityIdentifier.jmapSubmission: AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      CapabilityIdentifier.jmapWebSocket: AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      CapabilityIdentifier.jmapCore: AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      CapabilityIdentifier.jmapMail: AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:quota')): AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:mail:shares')): AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      CapabilityIdentifier.jmapVacationResponse: AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
      CapabilityIdentifier.jmapMdn: AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')),
    },
    UserName('bob@domain.tld'),
    Uri.parse('http://domain.com/jmap'),
    Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
    Uri.parse('http://domain.com/upload/{accountId}'),
    Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
    State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
  );
}