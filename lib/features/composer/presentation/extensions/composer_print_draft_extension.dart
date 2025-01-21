
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/identity_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draft_email_print.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/print_draft_dialog_view.dart';
import 'package:tmail_ui_user/features/email/domain/state/print_email_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension ComposerPrintDraftExtension on ComposerController {

  Future<void> printDraft(BuildContext context) async {
    if (printDraftButtonState == ButtonState.disabled) {
      log('ComposerPrintDraftExtension::printDraft: Printing draft');
      return;
    }
    printDraftButtonState = ButtonState.disabled;

    if (composerArguments.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null) {
      log('ComposerPrintDraftExtension::printDraft: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      printDraftButtonState = ButtonState.enabled;
      return;
    }
    
    final locale = Localizations.localeOf(context);
    final appLocalizations = AppLocalizations.of(context);

    final emailContent = await getContentInEditor();

    final resultState = await _showPrintDraftsDialog(
      appLocalizations: appLocalizations,
      locale: locale,
      emailContent: emailContent,
    );

    if (resultState is PrintEmailFailure) {
      printDraftButtonState = ButtonState.enabled;

      if (context.mounted) {
        appToast.showToastErrorMessage(context, appLocalizations.printingFailed);
      }
    } else if (resultState is PrintEmailSuccess) {
      printDraftButtonState = ButtonState.enabled;
    }
  }

  Future<dynamic> _showPrintDraftsDialog({
    required AppLocalizations appLocalizations,
    required Locale locale,
    required String emailContent,
  }) {
    final presentationEmail = composerArguments.value!.presentationEmail;

    final childWidget = PointerInterceptor(
      child: PrintDraftDialogView(
        emailPrint: DraftEmailPrint(
          appName: appLocalizations.app_name,
          userName: mailboxDashBoardController.userEmail,
          attachments: uploadController.allAttachmentsUploaded,
          emailContent: emailContent,
          locale: locale.toLanguageTag(),
          fromPrefix: appLocalizations.from_email_address_prefix,
          toPrefix: appLocalizations.to_email_address_prefix,
          ccPrefix: appLocalizations.cc_email_address_prefix,
          bccPrefix: appLocalizations.bcc_email_address_prefix,
          replyToPrefix: appLocalizations.replyToEmailAddressPrefix,
          titleAttachment: appLocalizations.attachments.toLowerCase(),
          toAddress: listToEmailAddress.toSet().toEscapeHtmlStringUseCommaSeparator(),
          ccAddress: listCcEmailAddress.toSet().toEscapeHtmlStringUseCommaSeparator(),
          bccAddress: listBccEmailAddress.toSet().toEscapeHtmlStringUseCommaSeparator(),
          sender: identitySelected.value?.toEmailAddress(),
          receiveTime: presentationEmail?.getReceivedAt(
            locale.toLanguageTag(),
            pattern: presentationEmail.receivedAt
              ?.value
              .toLocal()
              .toPatternForPrinting(locale.toLanguageTag()),
          ) ?? '',
          subject: presentationEmail?.subject,
        ),
        printEmailInteractor: printEmailInteractor,
      ),
    );

    return Get.dialog(
      childWidget,
      barrierDismissible: false,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }
}