
import 'dart:async';

import 'package:core/data/model/print_attachment.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class PrintUtils {
  Element? _createUserInformationElement({
    required String appName,
    required String userName,
  }) {
    try {
      return Element.html('''
      <table width="100%" cellpadding="0" cellspacing="0" border="0">
        <tbody>
          <tr height="14px">
            <td align="right" style="color: #777;">
              <b>$userName</b>
            </td>
          </tr>
        </tbody>
      </table>
    ''');
    } catch (e) {
      logError('PrintUtils::_createUserInformationElement: Exception = $e');
      return null;
    }
  }

  Element? get dividerElement {
    try {
      return Element.html('<hr />');
    } catch (e) {
      logError('PrintUtils::dividerElement: Exception = $e');
      return null;
    }
  }

  Element? _createSubjectElement(String subject) {
    try {
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
    } catch (e) {
      logError('PrintUtils::_createSubjectElement: Exception = $e');
      return null;
    }
  }

  Element? _createSenderElement({
    required String fromPrefix,
    required String senderName,
    required String senderEmailAddress,
    required String dateTime,
  }) {
    try {
      return Element.html('''
      <tr>
        <td>
          <font size="-1">$fromPrefix: <b>$senderName </b>&lt;$senderEmailAddress&gt;</font>
        </td>
        <td align="right"><font size="-1">$dateTime</font></td>
      </tr>
    ''');
    } catch (e) {
      logError('PrintUtils::_createSenderElement: Exception = $e');
      return null;
    }
  }

  String? _createRecipientHtmlTag(String prefix, String emailAddress) {
    try {
      Element element = Element.html('<div class="${prefix.toLowerCase()}"></div>');
      element.text = '$prefix: $emailAddress';
      return element.outerHtml;
    } catch (e) {
      logError('PrintUtils::_createRecipientHtmlTag: Exception = $e');
      return '';
    }
  }

  Element? _createRecipientsElement({
    required String toPrefix,
    required String ccPrefix,
    required String bccPrefix,
    required String replyToPrefix,
    String? toAddress,
    String? ccAddress,
    String? bccAddress,
    String? replyToAddress,
  }) {
    try {
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
    } catch (e) {
      logError('PrintUtils::_createRecipientsElement: Exception = $e');
      return null;
    }
  }

  Element? _createEmailContentElement(String emailContent) {
    try {
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
    } catch (e) {
      logError('PrintUtils::_createEmailContentElement: Exception = $e');
      return null;
    }
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

  Element? _createAttachmentsElement({
    required String titleAttachment,
    required List<PrintAttachment> listAttachment
  }) {
    try {
      return Element.html('''
      <table class="attachments" cellspacing="0" cellpadding="5" border="0">
        <tbody>
          ${_createTitleAttachmentHtmlTag(countAttachments: listAttachment.length, titleAttachment: titleAttachment)}
          ${listAttachment.map((printAttachment) => _createAttachmentHtmlTag(printAttachment)).toList().join('')}
        </tbody>
      </table>
    ''');
    } catch (e) {
      logError('PrintUtils::_createAttachmentsElement: Exception = $e');
      return null;
    }
  }

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
    Document document = parse(HtmlUtils.createTemplateHtmlDocument(title: '$appName - $subject'));

    Element bodyContainerElement = Element.html('<div class="body-container"></div>');
    Element mainContentElement = Element.html('<div class="main-content"></div>');
    Element messageElement = Element.html('<table width="100%" cellpadding="0" cellspacing="0" border="0" class="message"></table>');
    Element messageBodyElement = Element.html('<tbody></tbody>');

    Element? userInfoElement = _createUserInformationElement(
      appName: appName,
      userName: userName);

    Element? subjectElement = _createSubjectElement(subject);

    Element? senderElement = _createSenderElement(
      fromPrefix: fromPrefix,
      senderName: senderName,
      senderEmailAddress: senderEmailAddress,
      dateTime: dateTime);

    Element? recipientsElement = _createRecipientsElement(
      toPrefix: toPrefix,
      ccPrefix: ccPrefix,
      bccPrefix: bccPrefix,
      replyToPrefix: replyToPrefix,
      toAddress: toAddress,
      ccAddress: ccAddress,
      bccAddress: bccAddress,
      replyToAddress: replyToAddress,
    );

    Element? emailContentElement = _createEmailContentElement(emailContent);

    if (senderElement != null) {
      messageBodyElement.append(senderElement);
    }
    if (recipientsElement != null) {
      messageBodyElement.append(recipientsElement);
    }
    if (emailContentElement != null) {
      messageBodyElement.append(emailContentElement);
    }
    messageElement.append(messageBodyElement);

    if (subjectElement != null) {
      mainContentElement.append(subjectElement);
    }
    if (dividerElement != null) {
      mainContentElement.append(dividerElement!);
    }
    mainContentElement.append(messageElement);

    if (listAttachment?.isNotEmpty == true) {
      final attachmentsElement = _createAttachmentsElement(
        titleAttachment: titleAttachment,
        listAttachment: listAttachment!);

      if (dividerElement != null) {
        mainContentElement.append(dividerElement!);
      }
      if (attachmentsElement != null) {
        mainContentElement.append(attachmentsElement);
      }
    }

    if (userInfoElement != null) {
      bodyContainerElement.append(userInfoElement);
    }
    if (dividerElement != null) {
      bodyContainerElement.append(dividerElement!);
    }
    bodyContainerElement.append(mainContentElement);

    Element styleElement = Element.html(HtmlTemplate.printDocumentCssStyle);
    document.head?.append(styleElement);

    document.body?.append(bodyContainerElement);

    Element scriptElement = Element.html(HtmlInteraction.scriptHandleInvokePrinterOnBrowser);
    document.body?.append(scriptElement);

    final htmlDocument = document.outerHtml;

    HtmlUtils.openNewTabHtmlDocument(htmlDocument);
  }
}
