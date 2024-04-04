import 'package:core/data/model/print_attachment.dart';
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/print_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/email/data/datasource/print_file_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class PrintFileDataSourceImpl extends PrintFileDataSource {

  final PrintUtils _printUtils;
  final ImagePaths _imagePaths;
  final FileUtils _fileUtils;
  final ExceptionThrower _exceptionThrower;

  PrintFileDataSourceImpl(
    this._printUtils,
    this._imagePaths,
    this._fileUtils,
    this._exceptionThrower
  );

  @override
  Future<void> printEmail(EmailPrint emailPrint) {
    return Future.sync(() async {
      final sender = emailPrint.emailInformation.from?.isNotEmpty == true
        ? emailPrint.emailInformation.from!.first
        : null;
      final receiveTime = emailPrint.emailInformation.getReceivedAt(
        newLocale: emailPrint.locale,
        pattern: emailPrint.emailInformation.receivedAt?.value.toLocal().toPatternForPrinting(emailPrint.locale)
      );

      final List<PrintAttachment> listPrintAttachment = [];

      if (emailPrint.attachments?.isNotEmpty == true) {
        await Future.forEach<Attachment>(emailPrint.attachments ?? [], (attachment) async {
          final iconBase64Data = await _fileUtils.convertImageAssetToBase64(attachment.getIcon(_imagePaths));
          final printAttachment = PrintAttachment(
            iconBase64Data: iconBase64Data,
            name: attachment.name ?? '',
            size: filesize(attachment.size?.value)
          );
          listPrintAttachment.add(printAttachment);
        });
      }

      return await _printUtils.printEmail(
        appName: emailPrint.appName,
        userName: emailPrint.userName,
        subject: emailPrint.emailInformation.subject ?? '',
        emailContent: emailPrint.emailContent,
        senderName: sender?.name ?? '',
        senderEmailAddress: sender?.email ?? '',
        dateTime: receiveTime,
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
}