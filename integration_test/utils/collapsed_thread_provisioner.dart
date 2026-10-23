import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/method.dart';
import 'package:jmap_dart_client/jmap/core/method/method_response.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

import '../models/provisioning_threads.dart';

class CollapsedThreadProvisioner {
  MailboxDashBoardController get _dashboard =>
      Get.find<MailboxDashBoardController>();

  Future<CreatedThreads> provision(ProvisioningThreads threads) async {
    final setEmailMethod = SetEmailMethod(_dashboard.accountId.value!);
    _addCreates(setEmailMethod, threads);
    final response = await _executeSetEmail(setEmailMethod);
    final created = response?.created ?? {};
    final expectedCount =
        threads.threadNumbers.length * threads.repliesPerThread;
    if (created.length != expectedCount) {
      throw StateError('provisioning failed: ${response?.notCreated}');
    }
    if (created.values.map((email) => email.threadId).toSet().length !=
        threads.threadNumbers.length) {
      throw StateError('precondition: one thread per number');
    }
    return (
      emailIds: _createdEmailIds(created, threads),
      state: response?.newState,
    );
  }

  void _addCreates(SetEmailMethod setEmailMethod, ProvisioningThreads threads) {
    final inboxId = _inboxId;
    final runId = DateTime.now().microsecondsSinceEpoch;
    for (var index = 0; index < threads.threadNumbers.length; index++) {
      final thread = threads.threadNumbers[index];
      for (var reply = 0; reply < threads.repliesPerThread; reply++) {
        setEmailMethod.addCreate(
          Id('thread-$thread-$reply'),
          _threadEmail(
            (
              inboxId: inboxId,
              messageIdPrefix: 'thread-$runId-$thread',
              seen: threads.seen,
              starred: threads.starred,
              subjectPrefix: threads.subjectPrefix,
            ),
            thread: thread,
            reply: reply,
            receivedAt: UTCDate(
              threads.newest.subtract(
                Duration(
                  hours: threads.repliesPerThread - 1 - reply,
                  minutes: index,
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  Map<int, List<EmailId>> _createdEmailIds(
    Map<Id, Email> created,
    ProvisioningThreads threads,
  ) {
    return {
      for (final thread in threads.threadNumbers)
        thread: [
          for (var reply = 0; reply < threads.repliesPerThread; reply++)
            created[Id('thread-$thread-$reply')]!.id!,
        ],
    };
  }

  Future<State?> destroyEmails(Iterable<EmailId> emailIds) async {
    final method = SetEmailMethod(_dashboard.accountId.value!)
      ..addDestroy(emailIds.map((emailId) => emailId.id).toSet());
    return (await _executeSetEmail(method))?.newState;
  }

  Future<int> countEmailsWithKeyword(String keyword) async {
    final queried = await _execute(
      QueryEmailMethod(_dashboard.accountId.value!)
        ..addFilters(EmailFilterCondition(hasKeyword: keyword))
        ..addLimit(UnsignedInt(1)),
      QueryEmailResponse.deserialize,
    );
    return queried?.ids.length ?? 0;
  }

  Future<State?> markEmailsAsRead(Iterable<EmailId> emailIds) async {
    final method = SetEmailMethod(_dashboard.accountId.value!)
      ..addUpdates({
        for (final emailId in emailIds)
          emailId.id: PatchObject({
            '${PatchObject.keywordsProperty}/${KeyWordIdentifier.emailSeen.value}':
                true,
          }),
      });
    return (await _executeSetEmail(method))?.newState;
  }

  Future<void> deleteProvisionedThreads(String prefix) async {
    final accountId = _dashboard.accountId.value!;
    final maxObjectsInGet = _maxObjectsInGet;
    final ownEmailIds = <EmailId>{};
    var position = 0;

    while (true) {
      final queried = await _execute(
        QueryEmailMethod(accountId)
          ..addFilters(
            EmailFilterCondition(inMailbox: _inboxId, subject: prefix),
          )
          ..addLimit(UnsignedInt(maxObjectsInGet))
          ..addPosition(position),
        QueryEmailResponse.deserialize,
      );
      final ids = queried?.ids.toList() ?? [];
      if (ids.isEmpty) break;

      final emails = await _execute(
        GetEmailMethod(accountId)
          ..addIds(ids.toSet())
          ..addProperties(Properties({'subject'})),
        GetEmailResponse.deserialize,
      );
      ownEmailIds.addAll(
        (emails?.list ?? [])
            .where((email) => _isProvisionedSubject(email.subject, prefix))
            .map((email) => email.id!)
            .whereType<EmailId>(),
      );

      if (ids.length < maxObjectsInGet) break;
      position += ids.length;
    }

    if (ownEmailIds.isNotEmpty) await destroyEmails(ownEmailIds);
  }

  bool _isProvisionedSubject(String? subject, String prefix) {
    if (subject == null) return false;
    return RegExp('^(Re: )?${RegExp.escape(prefix)} \\d+\$').hasMatch(subject);
  }

  int get _maxObjectsInGet {
    final session = _dashboard.sessionCurrent;
    final accountId = _dashboard.accountId.value;
    if (session == null || accountId == null) {
      return CapabilityIdentifierExtension.defaultMaxObjectsInGet;
    }
    return session.getMaxObjectsInGet(accountId)?.value.toInt() ??
        CapabilityIdentifierExtension.defaultMaxObjectsInGet;
  }

  MailboxId get _inboxId =>
      _dashboard.mapDefaultMailboxIdByRole[PresentationMailbox.roleInbox]!;

  Email _threadEmail(
    ({
      MailboxId inboxId,
      String messageIdPrefix,
      bool seen,
      bool starred,
      String subjectPrefix,
    })
    target, {
    required int thread,
    required int reply,
    required UTCDate receivedAt,
  }) {
    final partId = PartId('1');
    final rootMessageId = MessageIdsHeaderValue({
      '${target.messageIdPrefix}-0@example.com',
    });
    final isReply = reply > 0;
    final subject = '${target.subjectPrefix} $thread';
    return Email(
      mailboxIds: {target.inboxId: true},
      keywords: _keywords(seen: target.seen, starred: target.starred),
      from: {EmailAddress('thread', 'thread@example.com')},
      subject: isReply ? 'Re: $subject' : subject,
      messageId: MessageIdsHeaderValue({
        '${target.messageIdPrefix}-$reply@example.com',
      }),
      inReplyTo: isReply ? rootMessageId : null,
      references: isReply ? rootMessageId : null,
      receivedAt: receivedAt,
      textBody: {
        EmailBodyPart(partId: partId, type: MediaType('text', 'plain')),
      },
      bodyValues: {
        partId: EmailBodyValue(
          value: 'thread body $thread-$reply',
          isEncodingProblem: false,
          isTruncated: false,
        ),
      },
    );
  }

  Map<KeyWordIdentifier, bool>? _keywords({
    required bool seen,
    required bool starred,
  }) {
    final keywords = <KeyWordIdentifier, bool>{
      if (seen) KeyWordIdentifier.emailSeen: true,
      if (starred) KeyWordIdentifier.emailFlagged: true,
    };
    return keywords.isEmpty ? null : keywords;
  }

  Future<SetEmailResponse?> _executeSetEmail(SetEmailMethod method) =>
      _execute(method, SetEmailResponse.deserialize);

  Future<T?> _execute<T extends MethodResponse>(
    Method method,
    T Function(Map<String, dynamic>) deserialize,
  ) async {
    final session = _dashboard.sessionCurrent!;
    final accountId = _dashboard.accountId.value!;
    final requestBuilder = JmapRequestBuilder(
      Get.find<HttpClient>(),
      ProcessingInvocation(),
    );
    final invocation = requestBuilder.invocation(method);
    final response =
        await (requestBuilder..usings(
              method.requiredCapabilities.toCapabilitiesSupportTeamMailboxes(
                session,
                accountId,
              ),
            ))
            .build()
            .execute();
    return response.parse<T>(invocation.methodCallId, deserialize);
  }
}
