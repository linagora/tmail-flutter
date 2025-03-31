import 'package:core/data/constants/constant.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';
import 'package:uuid/uuid.dart';

class ComposerRepositoryImpl extends ComposerRepository {

  final AttachmentUploadDataSource _attachmentUploadDataSource;
  final ComposerDataSource _composerDataSource;
  final HtmlDataSource _htmlDataSource;
  final ApplicationManager _applicationManager;
  final Uuid _uuid;

  ComposerRepositoryImpl(
    this._attachmentUploadDataSource,
    this._composerDataSource,
    this._htmlDataSource,
    this._applicationManager,
    this._uuid,
  );

  @override
  Future<UploadAttachment> uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken}) {
    return _attachmentUploadDataSource.uploadAttachment(fileInfo, uploadUri, cancelToken: cancelToken);
  }

  @override
  Future<String?> downloadImageAsBase64(String url, String cid, FileInfo fileInfo, {double? maxWidth, bool? compress}) {
    return _composerDataSource.downloadImageAsBase64(url, cid, fileInfo, maxWidth: maxWidth, compress: compress);
  }

  @override
  Future<Email> generateEmail(
    CreateEmailRequest createEmailRequest,
    {
      bool withIdentityHeader = false,
      bool isDraft = false,
    }
  ) async {
    String emailContent = createEmailRequest.emailContent;
    Set<EmailBodyPart> emailAttachments = Set.from(createEmailRequest.createAttachments());

    final tupleContentInlineAttachments = await _replaceImageBase64ToImageCID(
      emailContent: emailContent,
      inlineAttachments: createEmailRequest.inlineAttachments ?? {},
      uploadUri: createEmailRequest.uploadUri,
    );

    emailContent = tupleContentInlineAttachments.value1;
    emailAttachments.addAll(tupleContentInlineAttachments.value2);

    emailContent = await removeCollapsedExpandedSignatureEffect(emailContent: emailContent);

    final userAgent = await _applicationManager.generateApplicationUserAgent();
    final emailBodyPartId = PartId(_uuid.v1());

    final emailObject = createEmailRequest.generateEmail(
      newEmailContent: emailContent,
      newEmailAttachments: emailAttachments,
      userAgent: userAgent,
      partId: emailBodyPartId,
      withIdentityHeader: withIdentityHeader,
      isDraft: isDraft,
    );

    return emailObject;
  }

  Future<Tuple2<String, Set<EmailBodyPart>>> _replaceImageBase64ToImageCID({
    required String emailContent,
    required Map<String, Attachment> inlineAttachments,
    required Uri? uploadUri,
  }) {
    try {
      return _htmlDataSource.replaceImageBase64ToImageCID(
        emailContent: emailContent,
        inlineAttachments: inlineAttachments,
        uploadUri: uploadUri,
      );
    } catch (e) {
      logError('ComposerRepositoryImpl::_replaceImageBase64ToImageCID: Exception: $e');
      return Future.value(
        Tuple2(
          emailContent,
          inlineAttachments.isNotEmpty
            ? inlineAttachments.values.toList().toEmailBodyPart(charset: Constant.base64Charset)
            : {},
        )
      );
    }
  }

  @override
  Future<String> removeCollapsedExpandedSignatureEffect({required String emailContent}) {
    try {
      return _htmlDataSource.removeCollapsedExpandedSignatureEffect(emailContent: emailContent);
    } catch (e) {
      logError('ComposerRepositoryImpl::_removeCollapsedExpandedSignatureEffect: Exception: $e');
      return Future.value(emailContent);
    }
  }
}