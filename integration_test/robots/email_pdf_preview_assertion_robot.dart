import 'package:core/presentation/views/dialog/edit_text_dialog_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:twake_previewer_flutter/twake_pdf_previewer/widgets/pdf_pagination_widget.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_email_pdf_preview_assertion_robot.dart';

class EmailPdfPreviewAssertionRobot extends CoreRobot
    implements AbstractEmailPdfPreviewAssertionRobot {
  EmailPdfPreviewAssertionRobot(super.$);

  @override
  Future<void> expectPasswordPrompt({
    required bool showsIncorrectPassword,
  }) async {
    // A retry prompt replaces the previous one, so wait for the expected
    // error state instead of only for a prompt to exist.
    final incorrectPassword =
        $(EditTextDialogBuilder).$(AppLocalizations().incorrectPdfPassword);
    await waitForCondition(() async {
      await $.pump();
      return $(EditTextDialogBuilder).exists &&
          incorrectPassword.exists == showsIncorrectPassword;
    });
    expect($(EditTextDialogBuilder), findsOneWidget);
  }

  @override
  Future<void> expectPdfOpened() async {
    await waitForCondition(() async {
      await $.pump();
      return $(PdfPaginationWidget).exists;
    });
    expect($(EditTextDialogBuilder), findsNothing);
    expect($(AppLocalizations().cannotPreviewPdf), findsNothing);
  }

  @override
  Future<void> expectPasswordProtectedMessage() async {
    await waitForCondition(() async {
      await $.pump();
      return $(AppLocalizations().pdfPasswordNotProvided).exists;
    });
    expect($(EditTextDialogBuilder), findsNothing);
  }
}
