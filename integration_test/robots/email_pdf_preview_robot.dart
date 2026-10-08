import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_email_pdf_preview_assertion_robot.dart';
import 'abstract/abstract_email_pdf_preview_robot.dart';
import 'email_pdf_preview_assertion_robot.dart';

class EmailPdfPreviewRobot extends CoreRobot
    implements AbstractEmailPdfPreviewRobot {
  EmailPdfPreviewRobot(super.$, {AbstractEmailPdfPreviewAssertionRobot? assertion})
      : assertion = assertion ?? EmailPdfPreviewAssertionRobot($);

  @override
  final AbstractEmailPdfPreviewAssertionRobot assertion;

  @override
  Future<void> openAttachment() async {
    await $(AttachmentItemWidget).$(InkWell).tap();
  }

  @override
  Future<void> submitPassword(String password) async {
    await $(EditTextDialogBuilder).$(TextField).enterText(password);
    await $(EditTextDialogBuilder).$(AppLocalizations().open).tap();
  }

  @override
  Future<void> cancelPasswordPrompt() async {
    await $(EditTextDialogBuilder).$(AppLocalizations().cancel).tap();
  }
}
