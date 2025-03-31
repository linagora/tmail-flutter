import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

abstract class ComposerRepository {
  Future<Email> generateEmail(
    CreateEmailRequest createEmailRequest,
    {
      bool withIdentityHeader = false,
      bool isDraft = false,
    });

  Future<UploadAttachment> uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken});

  Future<String?> downloadImageAsBase64(String url, String cid, FileInfo fileInfo, {double? maxWidth, bool? compress});

  Future<String> removeCollapsedExpandedSignatureEffect({required String emailContent});
}