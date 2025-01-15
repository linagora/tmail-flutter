import 'package:core/data/model/print_attachment.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/data/datasource/print_file_datasource.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class PrintFileDataSourceImpl extends PrintFileDataSource {

  final PrintUtils _printUtils;
  final ImagePaths _imagePaths;
  final FileUtils _fileUtils;
  final HtmlAnalyzer _htmlAnalyzer;
  final ExceptionThrower _exceptionThrower;

  PrintFileDataSourceImpl(
    this._printUtils,
    this._imagePaths,
    this._fileUtils,
    this._htmlAnalyzer,
    this._exceptionThrower
  );

  @override
  Future<void> printEmail(EmailPrint emailPrint) {
    return Future.sync(() async {
      final emailContentEscaped = await _transformHtmlEmailContent(
          emailPrint.emailContent);

      final List<PrintAttachment> listPrintAttachment = [];

      if (emailPrint.attachments?.isNotEmpty == true) {
        await Future.forEach<Attachment>(emailPrint.attachments ?? [], (attachment) async {
          final iconBase64Data = await _fileUtils.convertImageAssetToBase64(attachment.getIcon(_imagePaths));
          final printAttachment = PrintAttachment(
            iconBase64Data: iconBase64Data,
            name: attachment.name.escapeLtGtHtmlString(),
            size: filesize(attachment.size?.value)
          );
          listPrintAttachment.add(printAttachment);
        });
      }

      return await _printUtils.printEmail(
        appName: emailPrint.appName,
        userName: emailPrint.userName,
        subject: emailPrint.subject?.escapeLtGtHtmlString() ?? '',
        emailContent: emailContentEscaped,
        senderName: emailPrint.sender?.name.escapeLtGtHtmlString() ?? '',
        senderEmailAddress: emailPrint.sender?.email ?? '',
        dateTime: emailPrint.receiveTime,
        fromPrefix: emailPrint.fromPrefix,
        toPrefix: emailPrint.toPrefix,
        ccPrefix: emailPrint.ccPrefix,
        bccPrefix: emailPrint.bccPrefix,
        replyToPrefix: emailPrint.replyToPrefix,
        toAddress: emailPrint.toAddress,
        ccAddress: emailPrint.ccAddress,
        bccAddress: emailPrint.bccAddress,
        replyToAddress: emailPrint.replyToAddress,
        titleAttachment: emailPrint.titleAttachment,
        listAttachment: listPrintAttachment
      );
    }).catchError(_exceptionThrower.throwException);
  }

  Future<String> _transformHtmlEmailContent(String emailContent) async {
    try {
      final htmlContentTransformed = await _htmlAnalyzer.transformHtmlEmailContent(
        emailContent,
        TransformConfiguration.forPrintEmail(),
      );
      return htmlContentTransformed;
    } catch (e) {
      logError('PrintFileDataSourceImpl::_transformHtmlEmailContent: Exception: $e');
      return emailContent;
    }
  }
}