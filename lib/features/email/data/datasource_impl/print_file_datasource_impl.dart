import 'package:core/data/model/print_attachment.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/print_utils.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/services.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/utc_date_extension.dart';
import 'package:tmail_ui_user/features/email/data/datasource/print_file_datasource.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class PrintFileDataSourceImpl extends PrintFileDataSource {

  final PrintUtils _printUtils;
  final ImagePaths _imagePaths;
  final ExceptionThrower _exceptionThrower;

  PrintFileDataSourceImpl(
    this._printUtils,
    this._imagePaths,
    this._exceptionThrower
  );

  @override
  Future<void> printEmailToPDF(EmailPrint emailPrint) {
    return Future.sync(() async {
      final sender = emailPrint.emailInformation.from?.isNotEmpty == true
        ? emailPrint.emailInformation.from!.first
        : null;
      final receiveTime = emailPrint.emailInformation.receivedAt?.formatDateToLocal(
        pattern: 'E, MMM d, yyyy \'at\' h:mm a',
        locale: emailPrint.locale);

      final List<PrintAttachment> listPrintAttachment = [];

      if (emailPrint.attachments?.isNotEmpty == true) {
        await Future.forEach<Attachment>(emailPrint.attachments ?? [], (attachment) async {
          final iconSvg = await rootBundle.loadString(attachment.getIcon(_imagePaths));
          final printAttachment = PrintAttachment(
            iconSvg: iconSvg,
            name: attachment.name ?? '',
            size: filesize(attachment.size?.value)
          );
          listPrintAttachment.add(printAttachment);
        });
      }

      final result = await _printUtils.printEmailToPDF(
        appName: emailPrint.appName,
        userName: emailPrint.userName,
        locale: emailPrint.locale,
        title: emailPrint.emailInformation.subject ?? '',
        emailContent: emailPrint.emailContent,
        senderName: sender?.name ?? '',
        senderEmailAddress: sender?.email ?? '',
        dateTime: receiveTime ?? '',
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
      log('PrintFileDataSourceImpl::printEmailToPDF: RESULT = $result');
      return result;
    }).catchError(_exceptionThrower.throwException);
  }
}