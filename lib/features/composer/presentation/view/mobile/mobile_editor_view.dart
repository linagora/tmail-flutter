import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/base/widget/cupertino_loading_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/editor_view_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/mobile_editor_widget.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/transform_html_email_content_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class MobileEditorView extends StatelessWidget with EditorViewMixin {

  final ComposerArguments? arguments;
  final Either<Failure, Success>? contentViewState;
  final OnCreatedEditorAction onCreatedEditorAction;

  const MobileEditorView({
    super.key,
    required this.onCreatedEditorAction,
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
          onCreatedEditorAction: onCreatedEditorAction
        );
      case EmailActionType.editDraft:
      case EmailActionType.editSendingEmail:
      case EmailActionType.composeFromContentShared:
      case EmailActionType.reopenComposerBrowser:
        if (contentViewState == null) {
          return const SizedBox.shrink();
        }
        return contentViewState!.fold(
          (failure) => MobileEditorWidget(
            content: HtmlExtension.editorStartTags,
            direction: AppUtils.getCurrentDirection(context),
            onCreatedEditorAction: onCreatedEditorAction
          ),
          (success) {
            if (success is GetEmailContentLoading) {
              return const CupertinoLoadingWidget(padding: EdgeInsets.all(16.0));
            } else {
              var newContent = success is GetEmailContentSuccess
                ? success.htmlEmailContent
                : HtmlExtension.editorStartTags;
              if (newContent.isEmpty) {
                newContent = HtmlExtension.editorStartTags;
              }
              return MobileEditorWidget(
                content: newContent,
                direction: AppUtils.getCurrentDirection(context),
                onCreatedEditorAction: onCreatedEditorAction
              );
            }
          }
        );
      case EmailActionType.reply:
      case EmailActionType.replyAll:
      case EmailActionType.forward:
        if (contentViewState == null) {
          return const SizedBox.shrink();
        }
        return contentViewState!.fold(
          (failure) {
            final emailContentQuoted = getEmailContentQuotedAsHtml(
              context: context,
              emailContent: '',
              emailActionType: arguments!.emailActionType,
              presentationEmail: arguments!.presentationEmail!
            );
            return MobileEditorWidget(
              content: emailContentQuoted,
              direction: AppUtils.getCurrentDirection(context),
              onCreatedEditorAction: onCreatedEditorAction
            );
          },
          (success) {
            if (success is TransformHtmlEmailContentLoading) {
              return const CupertinoLoadingWidget(padding: EdgeInsets.all(16.0));
            } else {
              final emailContentQuoted = getEmailContentQuotedAsHtml(
                context: context,
                emailContent: success is TransformHtmlEmailContentSuccess
                  ? success.htmlContent
                  : '',
                emailActionType: arguments!.emailActionType,
                presentationEmail: arguments!.presentationEmail!
              );
              return MobileEditorWidget(
                content: emailContentQuoted,
                direction: AppUtils.getCurrentDirection(context),
                onCreatedEditorAction: onCreatedEditorAction
              );
            }
          }
        );
      default:
        return MobileEditorWidget(
          content: HtmlExtension.editorStartTags,
          direction: AppUtils.getCurrentDirection(context),
          onCreatedEditorAction: onCreatedEditorAction
        );
    }
  }
}