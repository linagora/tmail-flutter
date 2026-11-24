import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/download/download_client.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:core/data/utils/compress_file_utils.dart';
import 'package:core/utils/file_utils.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/extensions/list_label_extension.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/attachment_extension.dart';
import 'package:model/extensions/email_body_part_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/identity_api.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:uuid/uuid.dart';

import '../../models/provisioning_email.dart';
import 'jmap_test_client.dart';

/// Sends provisioning emails straight through JMAP, without the composer or the dashboard.
class JmapEmailProvisioner {
  Future<void> send(
    List<ProvisioningEmail> emails, {
    bool requestReadReceipt = true,
    Role? folderLocationRole,
  }) async {
    final client = await JmapTestClient.current();
    final sender = _EmailSender(
      client,
      await _identity(client),
      requestReadReceipt: requestReadReceipt,
      folderLocationRole: folderLocationRole,
    );
    // The memory backend stores uploads in a plain HashMap, so keep sends sequential.
    for (final email in emails) {
      await sender.send(email);
    }
  }

  Future<Identity> _identity(JmapTestClient client) async {
    final response =
        await IdentityAPI(client.httpClient).getAllIdentities(client.session, client.accountId);
    return response.identities?.firstOrNull ??
        (throw StateError('Provisioning: no identity for the current account'));
  }
}

Future<Attachment> _upload(JmapTestClient client, FileInfo fileInfo) =>
    FileUploader(client.dioClient, FileUtils()).uploadAttachment(
      UploadTaskId(const Uuid().v4()),
      fileInfo,
      client.uploadUri,
    );

class _EmailSender {
  _EmailSender(
    this._client,
    this._identity, {
    required this.requestReadReceipt,
    this.folderLocationRole,
  });

  final JmapTestClient _client;
  final Identity _identity;
  final bool requestReadReceipt;
  final Role? folderLocationRole;

  Future<void> send(ProvisioningEmail email) async {
    final attachments = <Attachment>[
      for (final fileInfo in email.fileInfos) await _upload(_client, fileInfo),
    ];
    final (content, inline) = await _uploadInline(email);
    final request = CreateEmailRequest(
      session: _client.session,
      accountId: _client.accountId,
      emailActionType: EmailActionType.compose,
      ownEmailAddress: _client.session.getOwnEmailAddressOrEmpty(),
      subject: email.subject,
      emailContent: content,
      toRecipients: {EmailAddress(null, email.toEmail)},
      outboxMailboxId: await _client.outboxMailboxId(),
      sentMailboxId: await _client
          .mailboxIdByRole(folderLocationRole ?? PresentationMailbox.roleSent),
      identity: _identity,
      attachments: attachments,
      inlineAttachments: inline,
      hasRequestReadReceipt: requestReadReceipt,
      keywords: email.labels.keywords,
    );
    await _submit(request, content, inline, email.subject);
  }

  Future<(String, Map<String, Attachment>)> _uploadInline(ProvisioningEmail email) async {
    final inline = <String, Attachment>{};
    var content = email.content;
    for (var i = 0; i < email.inlineFileInfos.length; i++) {
      final uploaded = await _upload(_client, email.inlineFileInfos[i]);
      final cid = '${uploaded.blobId!.value}@tmail-memory';
      inline[cid] = uploaded.toAttachmentWithDisposition(
        disposition: ContentDisposition.inline,
        cid: cid,
      );
      content = content.replaceAll('{{inline$i}}', cid);
    }
    return (content, inline);
  }

  Future<void> _submit(
    CreateEmailRequest request,
    String content,
    Map<String, Attachment> inline,
    String subject,
  ) async {
    final bodyParts = <EmailBodyPart>{
      ...request.createAttachments(),
      for (final part in inline.values)
        part.toEmailBodyPart(charset: Constant.base64Charset),
    }.map((part) => part.onlyUseBlobIdOrPartId()).toSet();
    final emailObject = request.generateEmail(
      newEmailContent: content,
      newEmailAttachments: bodyParts,
      userAgent: 'tmail-integration-test',
      partId: PartId(const Uuid().v1()),
    );
    final args = request.toSendingEmailArguments(emailObject: emailObject);
    try {
      await EmailAPI(
        _client.httpClient,
        DownloadManager(DownloadClient(_client.dioClient, CompressFileUtils())),
        _client.dioClient,
        const Uuid(),
      ).sendEmail(
        args.session,
        args.accountId,
        args.emailRequest,
        mailboxRequest: args.mailboxRequest,
      );
    } catch (e, st) {
      Error.throwWithStackTrace(
        StateError('Provisioning email "$subject" was not sent: $e'),
        st,
      );
    }
  }
}
