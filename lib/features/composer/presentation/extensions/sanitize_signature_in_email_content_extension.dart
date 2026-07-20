import 'package:core/utils/app_logger.dart';
import 'package:html/parser.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SanitizeSignatureInEmailContentExtension on ComposerController {

  void synchronizeInitEmailDraftHash(String? emailContent) {
    try {
      final emailDocument = parse(emailContent);
      final signatureButton = emailDocument.querySelector('.tmail-signature-button');
      if (signatureButton == null) return;

      restoringSignatureButton = false;
      synchronizeInitDraftHash = true;
      initEmailDraftHash();
    } catch (e) {
      logWarning('SanitizeSignatureInEmailContentExtension::synchronizeInitEmailDraftHash:Exception = $e');
    }
  }
}