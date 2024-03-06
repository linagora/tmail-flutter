
import 'dart:async';

import 'package:core/data/model/print_attachment.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class PrintUtils {
  final ImagePaths _imagePaths;
  final FileUtils _fileUtils;

  PrintUtils(this._imagePaths, this._fileUtils);

  Future<Element> _createUserInformationElement({
    required String appName,
    required String userName,
  }) async {
    final logoBase64Data = await _fileUtils.convertImageAssetToBase64(_imagePaths.icTMailLogo);

    return Element.html('''
      <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tbody>
          <tr height="14px">
            <td width="40"><img src="${HtmlUtils.generateSVGImageData(logoBase64Data)}" width="40" height="40" class="logo" /></td>
            <td style="padding-left: 10px;font-size: 20px;color: #000;"><b>$appName</b></td>
            <td align="right" style="color: #777;">
              <b>$userName</b>
            </td>
          </tr>
        </tbody>
      </table>
    ''');
  }

  Element get dividerElement => Element.html('<hr />');

  Element _createSubjectElement(String subject) {
    return Element.html('''
      <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tbody>
          <tr>
            <td>
              <font size="+1"><b>$subject</b></font><br />
            </td>
          </tr>
        </tbody>
      </table>
    ''');
  }

  Element _createSenderElement({
    required String senderName,
    required String senderEmailAddress,
    required String dateTime,
  }) {
    return Element.html('''
      <tr>
        <td>
          <font size="-1"><b>$senderName </b>&lt;$senderEmailAddress&gt;</font>
        </td>
        <td align="right"><font size="-1">$dateTime</font></td>
      </tr>
    ''');
  }

  String _createRecipientHtmlTag(String prefix, String emailAddress) {
    Element element = Element.html('<div class="${prefix.toLowerCase()}"></div>');
    element.text = '$prefix: $emailAddress';
    return element.outerHtml;
  }

  Element _createRecipientsElement({
    required String toPrefix,
    required String ccPrefix,
    required String bccPrefix,
    required String replyToPrefix,
    String? toAddress,
    String? ccAddress,
    String? bccAddress,
    String? replyToAddress,
  }) {
    return Element.html('''
      <tr>
        <td colspan="2" style="padding-bottom: 4px;" class="recipient">
          ${replyToAddress?.isNotEmpty == true ? _createRecipientHtmlTag(replyToPrefix, replyToAddress!) : ''}
          ${toAddress?.isNotEmpty == true ? _createRecipientHtmlTag(toPrefix, toAddress!) : ''}
          ${ccAddress?.isNotEmpty == true ? _createRecipientHtmlTag(ccPrefix, ccAddress!) : ''}
          ${bccAddress?.isNotEmpty == true ? _createRecipientHtmlTag(bccPrefix, bccAddress!) : ''}
        </td>
      </tr>
    ''');
  }

  Element _createEmailContentElement(String emailContent) {
    return Element.html('''
      <tr>
        <td colspan="2">
          <table width="100%" cellpadding="12" cellspacing="0" border="0">
            <tbody>
              <tr>
                <td>$emailContent</td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
    ''');
  }

  String _createTitleAttachmentHtmlTag({
    required int countAttachments,
    required String titleAttachment
  }) {
    return '<tr><td colspan="2"><b style="padding-left:3">$countAttachments $titleAttachment</b></td></tr>';
  }

  String _createAttachmentHtmlTag(PrintAttachment printAttachment) {
    return '''
      <tr>
        <td>
          <table cellspacing="0" cellpadding="0">
            <tbody>
              <tr>
                <td>
                  <a target="_blank" href="">
                    <img width="16" height="16" src="${HtmlUtils.generateSVGImageData(printAttachment.iconBase64Data)}" />
                  </a>
                </td>
                <td width="7"></td>
                <td>
                  <b>${printAttachment.name}</b><br />
                  ${printAttachment.size}
                </td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
    ''';
  }

  Element _createAttachmentsElement({
    required String titleAttachment,
    required List<PrintAttachment> listAttachment
  }) {
    return Element.html('''
      <table class="attachments" cellspacing="0" cellpadding="5" border="0">
        <tbody>
          ${_createTitleAttachmentHtmlTag(countAttachments: listAttachment.length, titleAttachment: titleAttachment)}
          ${listAttachment.map((printAttachment) => _createAttachmentHtmlTag(printAttachment)).toList().join('')}
        </tbody>
      </table>
    ''');
  }

  Future<void> printEmail({
    required String appName,
    required String userName,
    required String subject,
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
    Document document = parse(HtmlUtils.createTemplateHtmlDocument(title: '$appName - $subject'));

    Element bodyContainerElement = Element.html('<div class="body-container"></div>');
    Element mainContentElement = Element.html('<div class="main-content"></div>');
    Element messageElement = Element.html('<table width="100%" cellpadding="0" cellspacing="0" border="0" class="message"></table>');
    Element messageBodyElement = Element.html('<tbody></tbody>');

    Element userInfoElement = await _createUserInformationElement(
      appName: appName,
      userName: userName);

    Element subjectElement = _createSubjectElement(subject);

    Element senderElement = _createSenderElement(
      senderName: senderName,
      senderEmailAddress: senderEmailAddress,
      dateTime: dateTime);

    Element recipientsElement = _createRecipientsElement(
      toPrefix: toPrefix,
      ccPrefix: ccPrefix,
      bccPrefix: bccPrefix,
      replyToPrefix: replyToPrefix,
      toAddress: toAddress,
      ccAddress: ccAddress,
      bccAddress: bccAddress,
      replyToAddress: replyToAddress,
    );

    Element emailContentElement = _createEmailContentElement(emailContent);

    bodyContainerElement.append(userInfoElement);
    bodyContainerElement.append(dividerElement);

    mainContentElement.append(subjectElement);
    mainContentElement.append(dividerElement);

    messageBodyElement.append(senderElement);
    messageBodyElement.append(recipientsElement);
    messageBodyElement.append(emailContentElement);

    messageElement.append(messageBodyElement);

    mainContentElement.append(messageElement);

    if (listAttachment?.isNotEmpty == true) {
      Element attachmentsElement = _createAttachmentsElement(
          titleAttachment: titleAttachment,
          listAttachment: listAttachment!);
      mainContentElement.append(dividerElement);
      mainContentElement.append(attachmentsElement);
    }

    bodyContainerElement.append(mainContentElement);

    document.body?.append(bodyContainerElement);

    Element scriptElement = Element.html(HtmlInteraction.scriptHandleInvokePrinterOnBrowser);
    document.body?.append(scriptElement);

    Element styleElement = Element.html(HtmlTemplate.printDocumentCssStyle);
    document.head?.append(styleElement);

    final htmlDocument = document.outerHtml;

    HtmlUtils.openNewTabHtmlDocument(htmlDocument);
  }
}
