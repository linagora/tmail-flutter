
import 'package:core/data/model/preview_attachment.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/html/html_template.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class PreviewEmlFileUtils {
  Element? _createEmailElement({
    required String subjectPrefix,
    required String fromPrefix,
    required String toPrefix,
    required String ccPrefix,
    required String bccPrefix,
    required String replyToPrefix,
    required String titleAttachment,
    String? subject,
    String? senderName,
    String? senderEmailAddress,
    String? toAddress,
    String? ccAddress,
    String? bccAddress,
    String? replyToAddress,
    String? dateTime,
    String? attachmentIcon,
    String? emailContent,
    List<PreviewAttachment>? listAttachment,
  }) {
    try {
      return Element.html('''
        <div class="email-container">
          <!-- Email Subject -->
          <div class="email-subject">$subjectPrefix: $subject</div>
      
          <!-- Email Header -->
          <div class="email-header">
            <!-- Placeholder icon -->
            <div class="circle">${(senderName ?? senderEmailAddress ?? '?').firstLetterToUpperCase}</div>
      
            <!-- Email information -->
            <div class="email-info">
              <div class="sender">
                 ${senderName ?? ''} <span class="sender-email">&lt;${senderEmailAddress ?? ''}&gt;</span>
              </div>
               ${replyToAddress?.isNotEmpty == true ? _createRecipientHtmlTag(replyToPrefix, replyToAddress!) : ''}
               ${toAddress?.isNotEmpty == true ? _createRecipientHtmlTag(toPrefix, toAddress!) : ''}
               ${ccAddress?.isNotEmpty == true ? _createRecipientHtmlTag(ccPrefix, ccAddress!) : ''}
               ${bccAddress?.isNotEmpty == true ? _createRecipientHtmlTag(bccPrefix, bccAddress!) : ''}
            </div>
      
            <!-- Email metadata -->
            <div class="email-meta">
              ${attachmentIcon?.isNotEmpty == true ? '<img width="16" height="16" src="${HtmlUtils.generateSVGImageData(attachmentIcon!)}" alt="Attachment Icon" class="attachment-icon">' : ''}
              ${dateTime?.isNotEmpty == true ? '<div class="email-date">$dateTime</div>' : ''}
            </div>
          </div>
      
          <!-- Email Body -->
          <div class="email-body">
            <p>$emailContent</p>
          </div>
      
          ${listAttachment?.isNotEmpty == true ? _createAttachmentsElement(listAttachment: listAttachment ?? [], titleAttachment: titleAttachment) : ''}
      ''');
    } catch (e) {
      logError('PreviewEmlFileUtils::_createEmailElement: Exception = $e');
      return null;
    }
  }

  String _createRecipientHtmlTag(String prefix, String emailAddress) {
    try {
      return '''
        <div class="recipients">
          $prefix: $emailAddress
        </div>
      ''';
    } catch (e) {
      logError('PreviewEmlFileUtils::_createRecipientHtmlTag: Exception = $e');
      return '';
    }
  }

  String _createAttachmentHtmlTag(PreviewAttachment previewAttachment) {
    return '''
      ${previewAttachment.link?.isNotEmpty == true
          ? '''
              <a href="${previewAttachment.link}" class="attachment-item">
                <div class="icon">
                  <img width="16" height="16" src="${HtmlUtils.generateSVGImageData(previewAttachment.iconBase64Data)}"  alt="attachment-icon"/>
                </div>
                <div class="file-details">
                  <div class="file-name">${previewAttachment.name}</div>
                  <div class="file-size">${previewAttachment.size}</div>
                </div>
              </a>
            '''
          : '''
              <div class="attachment-item">
                <div class="icon">
                  <img width="16" height="16" src="${HtmlUtils.generateSVGImageData(previewAttachment.iconBase64Data)}"  alt="attachment-icon"/>
                </div>
                <div class="file-details">
                  <div class="file-name">${previewAttachment.name}</div>
                  <div class="file-size">${previewAttachment.size}</div>
                </div>
              </div>
            '''}
      
    ''';
  }

  String _createAttachmentsElement({
    required String titleAttachment,
    required List<PreviewAttachment> listAttachment
  }) {
    try {
      return '''
        <div class="attachments">
          <!-- Attachment Title -->
          <div class="attachment-title">${listAttachment.length} $titleAttachment</div>
    
          <!-- Attachment Items -->
          ${listAttachment.map((attachment) => _createAttachmentHtmlTag(attachment)).toList().join('\n')}
        </div>
      ''';
    } catch (e) {
      logError('PreviewEmlFileUtils::_createAttachmentsElement: Exception = $e');
      return '';
    }
  }

  String generatePreviewEml({
    required String appName,
    required String ownEmailAddress,
    required String subjectPrefix,
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
    required String attachmentIcon,
    String? toAddress,
    String? ccAddress,
    String? bccAddress,
    String? replyToAddress,
    List<PreviewAttachment>? listAttachment,
  }) {
    Document document = parse(HtmlUtils.createTemplateHtmlDocument(title: '$subject - $ownEmailAddress'));

    Element? emailElement = _createEmailElement(
      subjectPrefix: subjectPrefix,
      fromPrefix: fromPrefix,
      toPrefix: toPrefix,
      ccPrefix: ccPrefix,
      bccPrefix: bccPrefix,
      replyToPrefix: replyToPrefix,
      subject: subject,
      toAddress: toAddress,
      ccAddress: ccAddress,
      bccAddress: bccAddress,
      replyToAddress: replyToAddress,
      senderName: senderName,
      senderEmailAddress: senderEmailAddress,
      dateTime: dateTime,
      emailContent: emailContent,
      attachmentIcon: attachmentIcon,
      titleAttachment: titleAttachment,
      listAttachment: listAttachment,
    );

    Element linkFontElement = Element.html(HtmlTemplate.fontLink);
    document.head?.append(linkFontElement);

    Element styleElement = Element.html(HtmlTemplate.previewEMLFileCssStyle);
    document.head?.append(styleElement);

    if (emailElement != null) {
      document.body?.append(emailElement);
    }

    final htmlDocument = document.outerHtml;

    return htmlDocument;
  }
}
