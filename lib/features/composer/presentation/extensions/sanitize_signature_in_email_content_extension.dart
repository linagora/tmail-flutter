import 'package:core/utils/app_logger.dart';
import 'package:html/parser.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension SanitizeSignatureInEmailContentExtension on ComposerController {

  Future<void> restoreCollapsibleSignatureButton(String? emailContent) async {
    try {
      if (emailContent == null) return;

      final emailDocument = parse(emailContent);
      final existedSignatureButton = emailDocument.querySelector('.tmail-signature-button');
      if (existedSignatureButton != null) return;

      // A top-level signature is already expanded: re-applying it would consume
      // the one-shot draft hash synchronization meant for the identity signature.
      final expandedSignature = emailDocument.querySelector('body > .tmail-signature');
      if (expandedSignature != null) return;

      final signature = emailDocument.querySelector('.tmail-signature');
      if (signature == null) return;

      restoringSignatureButton = true;
      await applySignature(signature.innerHtml);
    } catch (e) {
      logWarning('SanitizeSignatureInEmailContentExtension::restoreCollapsibleSignatureButton:Exception = $e');
    }
  }

  void synchronizeInitEmailDraftHash(String? emailContent) {
    try {
      final emailDocument = parse(emailContent);
      // The editor inserts the identity signature as a top-level `.tmail-signature`
      // (no collapsible button since signatures are always expanded). Signatures
      // nested in quoted content must not trigger the synchronization.
      final insertedSignature = emailDocument.querySelector('body > .tmail-signature');
      if (insertedSignature == null) return;

      restoringSignatureButton = false;
      synchronizeInitDraftHash = true;
      initEmailDraftHash();
    } catch (e) {
      logWarning('SanitizeSignatureInEmailContentExtension::synchronizeInitEmailDraftHash:Exception = $e');
    }
  }
}