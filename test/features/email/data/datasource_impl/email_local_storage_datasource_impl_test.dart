import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/caching/utils/local_storage_manager.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/email_local_storage_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/domain/model/view_entire_message_request.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class _FakeFileUtils extends Fake implements FileUtils {
  @override
  Future<String> convertImageAssetToBase64(String assetImage) async => '';
}

class _FakeLocalStorageManager extends Fake implements LocalStorageManager {}

class _FakeExceptionThrower extends Fake implements ExceptionThrower {}

void main() {
  setUp(() {
    Get.put<ImagePaths>(ImagePaths());
    Get.put<FileUtils>(_FakeFileUtils());
  });

  tearDown(Get.reset);

  group('EmailLocalStorageDataSourceImpl.generateEntireMessageAsDocument', () {
    test('SHOULD show the subject, sender name and attachment name exactly once escaped', () async {
      const subject = 'Q&A <b>today</b>';
      const senderName = 'Bob <Admin> & Co';
      const attachmentName = 'a<b>&c.pdf';
      final appLocalizations = AppLocalizations();
      final dataSource = EmailLocalStorageDataSourceImpl(
        _FakeLocalStorageManager(),
        PreviewEmlFileUtils(),
        _FakeExceptionThrower(),
      );

      final html = await dataSource.generateEntireMessageAsDocument(ViewEntireMessageRequest(
        ownEmailAddress: 'alice@example.com',
        presentationEmail: PresentationEmail(
          id: EmailId(Id('emailId')),
          subject: subject,
          from: {EmailAddress(senderName, 'bob@example.com')},
        ),
        attachments: [
          Attachment(
            blobId: Id('blobId'),
            name: attachmentName,
            size: UnsignedInt(1024),
            type: MediaType.parse('application/pdf'),
          ),
        ],
        emailContent: '<p>Body</p>',
        locale: const Locale('en'),
        appLocalizations: appLocalizations,
      ));

      final document = parse(html);
      expect(document.querySelector('.email-subject')!.text, '${appLocalizations.subject}: $subject');
      expect(document.querySelector('.sender')!.text.trim(), '$senderName <bob@example.com>');
      expect(document.querySelector('.file-name')!.text, attachmentName);
    });
  });
}
