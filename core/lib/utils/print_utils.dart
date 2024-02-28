
import 'dart:async';

import 'package:core/data/model/print_attachment.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class PrintUtils {
  final pw.HTMLToPdf _htmlToPdf;
  final ImagePaths _imagePaths;

  PrintUtils(this._htmlToPdf, this._imagePaths);

  Future<pw.Widget> _createEmailContentWidget(String htmlDocument) async {
    try {
      final List<pw.Widget> bodyWidgets = await _htmlToPdf.convert(htmlDocument);

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          ...bodyWidgets
        ]
      );
    } catch (e) {
      logError('PrintUtils::_createEmailContentWidget: Exception: $e');
      return pw.Text(htmlDocument);
    }
  }

  List<pw.Widget> _createBodyWidgets({
    required pw.Context context,
    required String logoAppSvg,
    required String appName,
    required String userName,
    required String title,
    required String htmlDocument,
    required String senderName,
    required String senderEmailAddress,
    required String dateTime,
    required String toPrefix,
    required String ccPrefix,
    required String bccPrefix,
    required String replyToPrefix,
    required String titleAttachment,
    required pw.Widget contentWidget,
    String? toAddress,
    String? ccAddress,
    String? bccAddress,
    String? replyToAddress,
    List<PrintAttachment>? listAttachment,
  }) {
    return [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 32),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _createUserInformationRow(
              context: context,
              logoAppSvg: logoAppSvg,
              appName: appName,
              userName: userName
            ),
            _createPageDivider(),
            if (title.isNotEmpty)
              ...[
                _createTitleRow(
                  context: context,
                  title: title
                ),
                _createPageDivider(),
              ],
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _createSenderWidget(
                    context: context,
                    name: senderName,
                    emailAddress: senderEmailAddress
                  )
                ),
                _createDateTimeWidget(
                  context: context,
                  dateTime: dateTime
                )
              ]
            ),
            if (replyToAddress?.isNotEmpty == true)
              _createRecipientRow(
                prefix: replyToPrefix,
                emailAddress: replyToAddress!
              ),
            if (toAddress?.isNotEmpty == true)
              _createRecipientRow(
                prefix: toPrefix,
                emailAddress: toAddress!
              ),
            if (ccAddress?.isNotEmpty == true)
              _createRecipientRow(
                prefix: ccPrefix,
                emailAddress: ccAddress!
              ),
            if (bccAddress?.isNotEmpty == true)
              _createRecipientRow(
                prefix: bccPrefix,
                emailAddress: bccAddress!
              ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 24),
              child: contentWidget
            ),
            if (listAttachment?.isNotEmpty == true)
              ...[
                _createPageDivider(),
                pw.SizedBox(height: 12),
                _createAttachmentTitle(
                  context: context,
                  title: titleAttachment,
                  totalAttachments: listAttachment!.length
                ),
                pw.SizedBox(height: 4),
                ...listAttachment.map((attachment) => _createAttachmentRow(
                      context: context,
                      attachment: attachment
                    ))
              ]
          ]
        )
      )
    ];
  }

  pw.Widget _createPageDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Divider()
    );
  }

  pw.Widget _createPageHeader({
    required pw.Context context,
    required String appName,
    required String title,
    required String locale,
  }) {
    final currentTime = DateFormat('MM/dd/yyyy, h:mm a', locale).format(DateTime.now());
    return pw.Padding(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Row(
        children: [
          pw.Text(
            currentTime,
            style: pw.Theme.of(context).defaultTextStyle.copyWith(
              fontSize: 8,
              color: pw.PdfColor.fromInt(AppColor.colorTextBody.value)
            )
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Text(
              '$appName - $title',
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                fontSize: 8,
                color: pw.PdfColor.fromInt(AppColor.colorTextBody.value)
              )
            )
          ),
        ]
      )
    );
  }

  pw.Widget _createUserInformationRow({
    required pw.Context context,
    required String logoAppSvg,
    required String appName,
    required String userName,
  }) {
    return pw.Row(
      children: [
        pw.SvgImage(
          svg: logoAppSvg,
          width: 32,
          height: 32
        ),
        pw.SizedBox(width: 12),
        pw.Text(
          appName,
          style: pw.Theme.of(context).header0
        ),
        pw.Spacer(),
        pw.SizedBox(width: 12),
        pw.Text(
          userName,
          style: pw.Theme.of(context).header4
        )
      ]
    );
  }

  pw.Widget _createTitleRow({
    required pw.Context context,
    required String title,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Text(
        title,
        style: pw.Theme.of(context).header3
      )
    );
  }

  pw.Widget _createSenderWidget({
    required pw.Context context,
    required String name,
    required String emailAddress,
  }) {
    return pw.Row(
      children: [
        if (name.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsetsDirectional.only(end: 4),
            child: pw.Text(
              name,
              style: pw.Theme.of(context).header4
            )
          ),
        pw.Text('<$emailAddress>')
      ]
    );
  }

  pw.Widget _createDateTimeWidget({
    required pw.Context context,
    required String dateTime,
  }) {
    return pw.Text(
      dateTime,
      style: pw.Theme.of(context).defaultTextStyle.copyWith(
        fontSize: 10,
        color: pw.PdfColor.fromInt(AppColor.colorTextBody.value)
      )
    );
  }

  pw.Widget _createRecipientRow({
     required String prefix,
     required String emailAddress,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$prefix:'),
        pw.SizedBox(width: 4),
        pw.Expanded(child: pw.Text(emailAddress))
      ]
    );
  }

  pw.Widget _createAttachmentTitle({
    required pw.Context context,
    required String title,
    required int totalAttachments,
  }) {
    return pw.Text(
      '$totalAttachments $title',
      style: pw.Theme.of(context).header4
    );
  }

  pw.Widget _createAttachmentRow({
    required pw.Context context,
    required PrintAttachment attachment,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        children: [
          pw.SvgImage(
            svg: attachment.iconSvg,
            width: 24,
            height: 24
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  attachment.name,
                  style: pw.Theme.of(context).header4
                ),
                pw.Text(attachment.size)
              ]
            )
          ),
        ]
      )
    );
  }

  Future<bool> printEmailToPDF({
    required String appName,
    required String userName,
    required String title,
    required String emailContent,
    required String senderName,
    required String senderEmailAddress,
    required String locale,
    required String dateTime,
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
    return await Printing.layoutPdf(onLayout: (pw.PdfPageFormat format) async {
      final googleInterRegularFont = await PdfGoogleFonts.interRegular();
      final googleInterBoldFont = await PdfGoogleFonts.interBold();
      final logoAppSvg = await rootBundle.loadString(_imagePaths.icTMailLogo);
      final contentWidget = await _createEmailContentWidget(emailContent);

      final pdfDocument = pw.Document();

      pdfDocument.addPage(
        pw.MultiPage(
          pageFormat: pw.PdfPageFormat.standard,
          orientation: pw.PageOrientation.portrait,
          theme: pw.ThemeData(
            defaultTextStyle: pw.TextStyle(
              font: googleInterRegularFont,
              fontSize: 12,
              color: pw.PdfColors.black
            ),
            header3: pw.TextStyle(
              font: googleInterBoldFont,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: pw.PdfColors.black
            ),
            header4: pw.TextStyle(
              font: googleInterBoldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: pw.PdfColors.black
            ),
          ),
          margin: pw.EdgeInsets.zero,
          build: (context) => _createBodyWidgets(
            context: context,
            contentWidget: contentWidget,
            logoAppSvg: logoAppSvg,
            appName: appName,
            userName: userName,
            title: title,
            htmlDocument: emailContent,
            senderName: senderName,
            senderEmailAddress: senderEmailAddress,
            dateTime: dateTime,
            toPrefix: toPrefix,
            ccPrefix: ccPrefix,
            bccPrefix: toPrefix,
            replyToPrefix: replyToPrefix,
            toAddress: toAddress,
            ccAddress: ccAddress,
            bccAddress: bccAddress,
            replyToAddress: replyToAddress,
            titleAttachment: titleAttachment,
            listAttachment: listAttachment
          ),
          header: (context) => _createPageHeader(
            context: context,
            appName: appName,
            title: title,
            locale: locale,
          ),
        )
     );
      return await pdfDocument.save();
    });
  }
}
