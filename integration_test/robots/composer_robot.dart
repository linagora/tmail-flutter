import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_editor_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/app_bar_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_mobile_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_suggestion_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../extensions/patrol_finder_extension.dart';

class ComposerRobot extends CoreRobot {
  ComposerRobot(super.$);

  Future<void> addRecipientIntoField({
    required PrefixEmailAddress prefixEmailAddress,
    required String email,
  }) async {
    final finder = $(RecipientComposerWidget)
      .which<RecipientComposerWidget>((widget) => widget.prefix == prefixEmailAddress);
    final isTextFieldFocused = finder
      .which<RecipientComposerWidget>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(email);

    await $(RecipientSuggestionItemWidget)
      .which<RecipientSuggestionItemWidget>((widget) => widget.emailAddress.email?.contains(email) ?? false)
      .tap();
  }

  Future<void> addSubject(String subject) async {
    final finder = $(SubjectComposerWidget);
    final isTextFieldFocused = finder
      .which<SubjectComposerWidget>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterTextWithoutTapAction(subject);
  }

  Future<void> addContent(String content) async {
    ComposerController? composerController;
    await $(ComposerView)
      .which<ComposerView>((widget) {
        composerController = widget.controller;
        return true;
      })
      .$(MobileEditorView).$(HtmlEditor).$(InAppWebView).tap();

    await composerController?.htmlEditorApi?.requestFocusLastChild();

    await composerController!.htmlEditorApi!.insertHtml('$content <br><br>'); 
  }

  Future<void> sendEmail(ImagePaths imagePaths) async {
    await $(AppBarComposerWidget)
      .$(TMailButtonWidget)
      .which<TMailButtonWidget>((widget) => widget.icon == imagePaths.icSendMobile)
      .tap();
  }

  Future<void> grantContactPermission() async {
    if (await $.native.isPermissionDialogVisible(timeout: const Duration(seconds: 5))) {
      await $.native.grantPermissionWhenInUse();
    }
  }

  Future<void> tapCloseComposer(ImagePaths imagePaths) async {
    await $(AppBarComposerWidget)
      .$(TMailButtonWidget)
      .which<TMailButtonWidget>((widget) => widget.icon == imagePaths.icCancel)
      .tap();
  }

  Future<void> tapSaveButtonOnSaveDraftConfirmDialog(AppLocalizations appLocalizations) async {
    await $(find.text(appLocalizations.save)).tap();
  }

  Future<void> tapMoreOptionOnAppBar() async {
    await $(#composer_more_button).tap();
  }

  Future<void> tapMarkAsImportantPopupItemOnMenu() async {
    await $(#mark_as_important_popup_item).tap();
  }

  Future<void> tapReadReceiptPopupItemOnMenu() async {
    await $(#read_receipt_popup_item).tap();
  }

  Future<void> tapSaveAsDraftPopupItemOnMenu() async {
    await $(#save_as_draft_popup_item).tap();
  }

  Future<void> tapRecipientExpandButton() async {
    await $(#prefix_to_recipient_expand_button).tap();
  }

  Future<void> tapFromFieldPopupMenu() async {
    await $(FromComposerMobileWidget).$(InkWell).tap();
  }

  Future<void> saveAsTemplate() async {
    await $(AppBarComposerWidget)
      .$(TMailButtonWidget)
      .which<TMailButtonWidget>((widget) => widget.icon == ImagePaths().icMore)
      .tap();
    await $(AppLocalizations().saveAsTemplate).tap();
  }
}