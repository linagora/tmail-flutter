import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uuid/uuid.dart';

import '../models/provisioning_twp_warning_email.dart';
import '../utils/wait_for_mailbox_ready.dart';

/// Provisions an Inbox email that already carries a backend-positioned
/// `X-TWP-Message` warning header.
///
/// The standard send flow cannot set arbitrary headers, so this creates the
/// message directly via JMAP `Email/set` create. Headers on create must be set
/// through `header:Name:form` properties (`individualHeaders`), like MDN /
/// User-Agent — the `headers` set is not settable on create.
///
/// Kept out of `ScenarioUtilsMixin` so provisioning concerns don't accumulate on
/// that mixin (SRP); new server-state helpers should follow the same pattern.
class TwpWarningEmailProvisioner {
  const TwpWarningEmailProvisioner();

  Future<void> provision(ProvisioningTwpWarningEmail request) async {
    await waitForMailboxReady();
    final context = _resolveInboxContext();
    await _createEmailWithWarningHeader(context, request);
    await Get.find<ThreadController>().refreshAllEmail();
  }

  _InboxProvisioningContext _resolveInboxContext() {
    final dashboard = Get.find<MailboxDashBoardController>();
    return _InboxProvisioningContext(
      session: _required(dashboard.sessionCurrent, 'session'),
      accountId: _required(dashboard.accountId.value, 'accountId'),
      inboxId: _required(
        dashboard.mapDefaultMailboxIdByRole[PresentationMailbox.roleInbox],
        'inbox mailbox',
      ),
      ownEmail: dashboard.ownEmailAddress.value,
    );
  }

  Future<void> _createEmailWithWarningHeader(
    _InboxProvisioningContext context,
    ProvisioningTwpWarningEmail request,
  ) async {
    final requestBuilder = JmapRequestBuilder(
      Get.find<HttpClient>(),
      ProcessingInvocation(),
    );
    final setEmailMethod = SetEmailMethod(context.accountId)
      ..addCreate(
        Id(const Uuid().v1()),
        Email(
          mailboxIds: {context.inboxId: true},
          from: {EmailAddress(null, context.ownEmail)},
          to: {EmailAddress(null, context.ownEmail)},
          subject: request.subject,
          individualHeaders: {
            IndividualHeaderIdentifier(
              'header:${EmailProperty.headerTwpMessageKey}:asText',
            ): TextHeaderValue(
              request.headerValue,
            ),
          },
        ),
      );
    final invocation = requestBuilder.invocation(setEmailMethod);
    final response =
        await (requestBuilder..usings(
              setEmailMethod.requiredCapabilities
                  .toCapabilitiesSupportTeamMailboxes(
                    context.session,
                    context.accountId,
                  ),
            ))
            .build()
            .execute();
    final created = response
        .parse<SetEmailResponse>(
          invocation.methodCallId,
          SetEmailResponse.deserialize,
        )
        ?.created;
    if (created == null || created.isEmpty) {
      throw StateError('TwpWarningEmailProvisioner: email creation failed');
    }
  }

  /// Returns [value] or throws a descriptive [StateError] — avoids a multi-term
  /// null-check conditional in the caller.
  T _required<T>(T? value, String name) =>
      value ??
      (throw StateError('TwpWarningEmailProvisioner: $name is unavailable'));
}

class _InboxProvisioningContext {
  final Session session;
  final AccountId accountId;
  final MailboxId inboxId;
  final String ownEmail;

  const _InboxProvisioningContext({
    required this.session,
    required this.accountId,
    required this.inboxId,
    required this.ownEmail,
  });
}
