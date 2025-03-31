import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/editor_view_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/mobile_editor_widget.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class MobileEditorView extends StatelessWidget with EditorViewMixin {

  final ComposerArguments? arguments;
  final Either<Failure, Success>? contentViewState;
  final OnCreatedEditorAction onCreatedEditorAction;
  final OnLoadCompletedEditorAction onLoadCompletedEditorAction;

  const MobileEditorView({
    super.key,
    required this.onCreatedEditorAction,
    required this.onLoadCompletedEditorAction,
    this.arguments,
    this.contentViewState,
  });

  @override
  Widget build(BuildContext context) {
    if (arguments == null) {
      return const SizedBox.shrink();
    }

    switch (arguments!.emailActionType) {
      case EmailActionType.compose:
      case EmailActionType.composeFromEmailAddress:
      case EmailActionType.composeFromFileShared:
        return MobileEditorWidget(
          content: HtmlExtension.editorStartTags,
          direction: AppUtils.getCurrentDirection(context),
          onCreatedEditorAction: onCreatedEditorAction,
          onLoadCompletedEditorAction: onLoadCompletedEditorAction
        );
      case EmailActionType.editDraft:
      case EmailActionType.editSendingEmail:
      case EmailActionType.composeFromContentShared:
      case EmailActionType.reopenComposerBrowser:
      case EmailActionType.composeFromMailtoUri:
      case EmailActionType.composeFromUnsubscribeMailtoLink:
      case EmailActionType.editAsNewEmail:
        if (contentViewState == null) {
          return const SizedBox.shrink();
        }
        return contentViewState!.fold(
          (failure) => MobileEditorWidget(
            content: HtmlExtension.editorStartTags,
            direction: AppUtils.getCurrentDirection(context),
            onCreatedEditorAction: onCreatedEditorAction,
            onLoadCompletedEditorAction: onLoadCompletedEditorAction
          ),
          (success) {
            if (success is GetEmailContentLoading) {
              return const CupertinoLoadingWidget(padding: EdgeInsets.all(16.0));
            } else {
              var newContent = HtmlExtension.editorStartTags;
              if (success is GetEmailContentSuccess) {
                newContent = success.htmlEmailContent;
              } else if (success is GetEmailContentFromCacheSuccess) {
                newContent = success.htmlEmailContent;
              }
              if (newContent.isEmpty) {
                newContent = HtmlExtension.editorStartTags;
              }
              return MobileEditorWidget(
                content: newContent,
                direction: AppUtils.getCurrentDirection(context),
                onCreatedEditorAction: onCreatedEditorAction,
                onLoadCompletedEditorAction: onLoadCompletedEditorAction
              );
            }
          }
        );
      case EmailActionType.reply:
      case EmailActionType.replyToList:
      case EmailActionType.replyAll:
      case EmailActionType.forward:
        if (contentViewState == null) {
          return const SizedBox.shrink();
        }
        return contentViewState!.fold(
          (failure) {
            final emailContentQuoted = getEmailContentQuotedAsHtml(
              locale: Localizations.localeOf(context),
              appLocalizations: AppLocalizations.of(context),
              emailContent: '',
              emailActionType: arguments!.emailActionType,
              presentationEmail: arguments!.presentationEmail!
            );
            return MobileEditorWidget(
              content: emailContentQuoted,
              direction: AppUtils.getCurrentDirection(context),
              onCreatedEditorAction: onCreatedEditorAction,
              onLoadCompletedEditorAction: onLoadCompletedEditorAction
            );
          },
          (success) {
            if (success is GetEmailContentLoading) {
              return const CupertinoLoadingWidget(padding: EdgeInsets.all(16.0));
            } else {
              final emailContentQuoted = getEmailContentQuotedAsHtml(
                locale: Localizations.localeOf(context),
                appLocalizations: AppLocalizations.of(context),
                emailContent: success is GetEmailContentSuccess
                  ? success.htmlEmailContent
                  : '',
                emailActionType: arguments!.emailActionType,
                presentationEmail: arguments!.presentationEmail!
              );
              return MobileEditorWidget(
                content: emailContentQuoted,
                direction: AppUtils.getCurrentDirection(context),
                onCreatedEditorAction: onCreatedEditorAction,
                onLoadCompletedEditorAction: onLoadCompletedEditorAction
              );
            }
          }
        );
      default:
        return MobileEditorWidget(
          content: HtmlExtension.editorStartTags,
          direction: AppUtils.getCurrentDirection(context),
          onCreatedEditorAction: onCreatedEditorAction,
          onLoadCompletedEditorAction: onLoadCompletedEditorAction
        );
    }
  }
}