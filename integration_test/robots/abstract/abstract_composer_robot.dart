import 'dart:io';

import 'package:model/email/prefix_email_address.dart';

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
}
