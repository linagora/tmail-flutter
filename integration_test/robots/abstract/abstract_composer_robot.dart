import 'dart:io';
import 'dart:typed_data';

import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

abstract class AbstractComposerRobot {
  Future<void> expectComposerViewVisible();
  Future<void> grantContactPermission();
  Future<void> addRecipient(PrefixEmailAddress prefix, String email);
  Future<void> addSubject(String subject);
  Future<void> addContent(String content);
  Future<void> send();
  Future<void> focusEditorAboveReplyBody();
  Future<void> addInlineAtCursorPosition(File file);
  Future<void> waitForSignatureToLoad();
  Future<void> tapCloseComposer();
  Future<void> tapSaveButtonOnSaveDraftConfirmDialog(AppLocalizations appLocalizations);
  // Use bytes instead of File so these methods work on web (no dart:io / path_provider).
  Future<void> addAttachmentFromBytes(Uint8List bytes, String fileName);
  Future<void> addInlineFromBytes(Uint8List bytes, String fileName);
  Future<void> tapSaveAsDraftButton();
  Future<void> tapSaveAsTemplateButton();
  Future<void> tapDiscardChanges();
  /// Returns the active [ComposerController] for the currently visible composer.
  /// Platform implementations must resolve the correct GetX tag (web uses a
  /// per-instance composerId; mobile uses the default null tag).
  ComposerController? findComposerController();
}
