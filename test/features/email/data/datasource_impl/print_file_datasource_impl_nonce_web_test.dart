@TestOn('chrome')

import 'package:core/data/model/print_attachment.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/data/datasource_impl/print_file_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

import 'print_file_datasource_impl_nonce_probe_web.dart';

class _CapturingPrintUtils extends PrintUtils {
  String? scriptNonce;

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
    String? scriptNonce,
  }) async {
    this.scriptNonce = scriptNonce;
  }
}

class _FakeFileUtils extends Fake implements FileUtils {
  @override
  Future<String> convertImageAssetToBase64(String assetImage) async => '';
}

class _FakeHtmlAnalyzer extends Fake implements HtmlAnalyzer {}

class _FakeExceptionThrower extends Fake implements ExceptionThrower {}

void main() {
  test('SHOULD pass the host script nonce to PrintUtils', () async {
    final script = insertHostNonceScript('n1');
    addTearDown(script.remove);

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
      subject: 'Nonce',
      sender: EmailAddress('Bob', 'bob@example.com'),
    ));

    expect(script.getAttribute('nonce'), '');
    expect(printUtils.scriptNonce, 'n1');
  });
}
