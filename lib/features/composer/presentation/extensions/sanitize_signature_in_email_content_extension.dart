
import 'package:html/parser.dart';
import 'package:rich_text_composer/views/commons/logger.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SanitizeSignatureInEmailContentExtension on ComposerController {

  Future<void> restoreCollapsibleSignatureButton(String? emailContent) async {
    try {
      if (emailContent == null) return;

      final emailDocument = parse(emailContent);
      final existedSignatureButton = emailDocument.querySelector('button.tmail-signature-button');
      if (existedSignatureButton != null) return;

      final signature = emailDocument.querySelector('div.tmail-signature');
      if (signature == null) return;

      restoringSignatureButton = true;
      await applySignature(signature.innerHtml);
    } catch (e) {
      logError('SanitizeSignatureInEmailContentExtension::restoreCollapsibleSignatureButton:Exception = $e');
    }
  }

  void synchronizeInitEmailDraftHash(String? emailContent) {
    try {
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
}