
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/editor_view_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/web_editor_widget.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/transform_html_email_content_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class WebEditorView extends StatelessWidget with EditorViewMixin {

  final HtmlEditorController editorController;
  final ComposerArguments? arguments;
  final Either<Failure, Success>? contentViewState;
  final String? currentWebContent;
  final OnInitialContentEditorAction? onInitial;
  final OnChangeContentEditorAction? onChangeContent;
  final VoidCallback? onFocus;
  final VoidCallback? onUnFocus;
  final OnMouseDownEditorAction? onMouseDown;
  final OnEditorSettingsChange? onEditorSettings;
  final OnEditorTextSizeChanged? onEditorTextSizeChanged;
  final double? width;
  final double? height;
  final VoidCallback? onDragEnter;

  const WebEditorView({
    super.key,
    required this.editorController,
    this.arguments,
    this.contentViewState,
    this.currentWebContent,
    this.onInitial,
    this.onChangeContent,
    this.onFocus,
    this.onUnFocus,
    this.onMouseDown,
    this.onEditorSettings,
    this.onEditorTextSizeChanged,
    this.width,
    this.height,
    this.onDragEnter,
  });

  @override
  Widget build(BuildContext context) {
    if (arguments == null) {
      return const SizedBox.shrink();
    }

    switch(arguments!.emailActionType) {
      case EmailActionType.compose:
      case EmailActionType.composeFromEmailAddress:
      case EmailActionType.composeFromFileShared:
        return WebEditorWidget(
          editorController: editorController,
          content: currentWebContent ?? HtmlExtension.editorStartTags,
          direction: AppUtils.getCurrentDirection(context),
          onInitial: onInitial,
          onChangeContent: onChangeContent,
          onFocus: onFocus,
          onUnFocus: onUnFocus,
          onMouseDown: onMouseDown,
          onEditorSettings: onEditorSettings,
          onEditorTextSizeChanged: onEditorTextSizeChanged,
          width: width,
          height: height,
          onDragEnter: onDragEnter,
        );
      case EmailActionType.editDraft:
      case EmailActionType.editSendingEmail:
      case EmailActionType.composeFromContentShared:
      case EmailActionType.reopenComposerBrowser:
      case EmailActionType.composeFromUnsubscribeMailtoLink:
      case EmailActionType.composeFromMailtoUri:
        if (contentViewState == null) {
          return const SizedBox.shrink();
        }
        return contentViewState!.fold(
          (failure) => WebEditorWidget(
            editorController: editorController,
            content: currentWebContent ?? HtmlExtension.editorStartTags,
            direction: AppUtils.getCurrentDirection(context),
            onInitial: onInitial,
            onChangeContent: onChangeContent,
            onFocus: onFocus,
            onUnFocus: onUnFocus,
            onMouseDown: onMouseDown,
            onEditorSettings: onEditorSettings,
            onEditorTextSizeChanged: onEditorTextSizeChanged,
            width: width,
            height: height,
            onDragEnter: onDragEnter,
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
              return WebEditorWidget(
                editorController: editorController,
                content: currentWebContent ?? newContent,
                direction: AppUtils.getCurrentDirection(context),
                onInitial: onInitial,
                onChangeContent: onChangeContent,
                onFocus: onFocus,
                onUnFocus: onUnFocus,
                onMouseDown: onMouseDown,
                onEditorSettings: onEditorSettings,
                onEditorTextSizeChanged: onEditorTextSizeChanged,
                width: width,
                height: height,
                onDragEnter: onDragEnter,
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
            return WebEditorWidget(
              editorController: editorController,
              content: currentWebContent ?? emailContentQuoted,
              direction: AppUtils.getCurrentDirection(context),
              onInitial: onInitial,
              onChangeContent: onChangeContent,
              onFocus: onFocus,
              onUnFocus: onUnFocus,
              onMouseDown: onMouseDown,
              onEditorSettings: onEditorSettings,
              onEditorTextSizeChanged: onEditorTextSizeChanged,
              width: width,
              height: height,
              onDragEnter: onDragEnter,
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
              return WebEditorWidget(
                editorController: editorController,
                content: currentWebContent ?? emailContentQuoted,
                direction: AppUtils.getCurrentDirection(context),
                onInitial: onInitial,
                onChangeContent: onChangeContent,
                onFocus: onFocus,
                onUnFocus: onUnFocus,
                onMouseDown: onMouseDown,
                onEditorSettings: onEditorSettings,
                onEditorTextSizeChanged: onEditorTextSizeChanged,
                width: width,
                height: height,
                onDragEnter: onDragEnter,
              );
            }
          }
        );
      default:
        return WebEditorWidget(
          editorController: editorController,
          content: currentWebContent ?? HtmlExtension.editorStartTags,
          direction: AppUtils.getCurrentDirection(context),
          onInitial: onInitial,
          onChangeContent: onChangeContent,
          onFocus: onFocus,
          onUnFocus: onUnFocus,
          onMouseDown: onMouseDown,
          onEditorSettings: onEditorSettings,
          onEditorTextSizeChanged: onEditorTextSizeChanged,
          width: width,
          height: height,
          onDragEnter: onDragEnter,
        );
    }
  }
}