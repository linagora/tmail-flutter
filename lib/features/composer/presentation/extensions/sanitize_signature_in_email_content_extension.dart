
import 'package:html/parser.dart';
import 'package:rich_text_composer/views/commons/logger.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SanitizeSignatureInEmailContentExtension on ComposerController {

  Future<void> restoreCollapsibleSignatureButton(String? emailContent) async {
    try {
      if (emailContent == null) return;
      log('SanitizeSignatureInEmailContentExtension::restoreCollapsibleSignatureButton:emailContent = $emailContent');
      final emailDocument = parse(emailContent);
      final existedSignatureButton = emailDocument.querySelector('button.tmail-signature-button');
      if (existedSignatureButton != null) return;

      final signature = emailDocument.querySelector('div.tmail-signature');
      if (signature == null) return;

      restoringSignatureButton = true;
      await applySignature(signature.innerHtml);
      log('SanitizeSignatureInEmailContentExtension::restoreCollapsibleSignatureButton:DONE');
    } catch (e) {
      logError('SanitizeSignatureInEmailContentExtension::restoreCollapsibleSignatureButton:Exception = $e');
    }
  }

  void synchronizeInitEmailDraftHash(String? emailContent) {
    try {
      log('SanitizeSignatureInEmailContentExtension::synchronizeInitEmailDraftHash:emailContent = $emailContent');
      final emailDocument = parse(emailContent);
      final signatureButton = emailDocument.querySelector('button.tmail-signature-button');
      if (signatureButton == null) return;

      restoringSignatureButton = false;
      synchronizeInitDraftHash = true;
      initEmailDraftHash();
    } catch (e) {
      logError('SanitizeSignatureInEmailContentExtension::synchronizeInitEmailDraftHash:Exception = $e');
    }
  }

  Future<String> removeCollapsibleSignatureButton(String emailContent) async {
    try {
      log('SanitizeSignatureInEmailContentExtension::removeCollapsibleSignatureButton:');
      final emailDocument = parse(emailContent);
      final signatureElements = emailDocument.querySelectorAll('div.tmail-signature');
      await Future.wait(signatureElements.map((signatureTag) async {
        final signatureChildren = signatureTag.children;
        for (var child in signatureChildren) {
          if (child.attributes['class']?.contains('tmail-signature-button') == true) {
            child.remove();
          } else if (child.attributes['class']?.contains('tmail-signature-content') == true) {
            signatureTag.innerHtml = child.innerHtml;
          }
        }

        if (signatureTag.attributes['style']?.contains('display: none;') == true) {
          signatureTag.attributes.remove('style');
        }
      }));
      return emailDocument.body?.innerHtml ?? emailContent;
    } catch (e) {
      logError('SanitizeSignatureInEmailContentExtension::removeCollapsibleSignatureButton:Exception = $e');
      return emailContent;
    }
  }
}