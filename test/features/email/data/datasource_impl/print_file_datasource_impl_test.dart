import 'package:core/data/model/print_attachment.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/print_file_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class _CapturingPrintUtils extends PrintUtils {
  String? subject;
  String? senderName;
  List<PrintAttachment>? listAttachment;

  @override
  Future<void> printEmail({
    required String appName,
    required String userName,
    required String subject,
    required String emailContent,
    required String senderName,
    required String senderEmailAddress,
    required String dateTime,
    required String fromPrefix,
    required String toPrefix,
    required String ccPrefix,
    required String bccPrefix,
    required String replyToPrefix,
    required String titleAttachment,
    String? toAddress,
    String? ccAddress,
    String? bccAddress,
    String? replyToAddress,
    List<PrintAttachment>? listAttachment,
  }) async {
    this.subject = subject;
    this.senderName = senderName;
    this.listAttachment = listAttachment;
  }
}

class _FakeFileUtils extends Fake implements FileUtils {
  @override
  Future<String> convertImageAssetToBase64(String assetImage) async => '';
}

class _FakeHtmlAnalyzer extends Fake implements HtmlAnalyzer {}

class _FakeExceptionThrower extends Fake implements ExceptionThrower {}

void main() {
  group('PrintFileDataSourceImpl.printEmail', () {
    test('SHOULD pass the subject, sender name and attachment name unescaped to PrintUtils', () async {
      const subject = 'Q&A <b>today</b>';
      const senderName = 'Bob <Admin> & Co';
      const attachmentName = 'a<b>&c.pdf';
      final printUtils = _CapturingPrintUtils();
      final dataSource = PrintFileDataSourceImpl(
        printUtils,
        ImagePaths(),
        _FakeFileUtils(),
        _FakeHtmlAnalyzer(),
        _FakeExceptionThrower(),
      );

      await dataSource.printEmail(EmailPrint(
        appName: 'Twake Mail',
        userName: 'alice@example.com',
        emailContent: '',
        fromPrefix: 'From',
        toPrefix: 'To',
        ccPrefix: 'Cc',
        bccPrefix: 'Bcc',
        replyToPrefix: 'Reply to',
        titleAttachment: 'attachment',
        receiveTime: 'today',
        subject: subject,
        sender: EmailAddress(senderName, 'bob@example.com'),
        attachments: [
          Attachment(
            blobId: Id('blobId'),
            name: attachmentName,
            size: UnsignedInt(1024),
            type: MediaType.parse('application/pdf'),
          ),
        ],
      ));

      expect(printUtils.subject, subject);
      expect(printUtils.senderName, senderName);
      expect(printUtils.listAttachment!.single.name, attachmentName);
    });
  });
}
