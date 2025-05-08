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
  final OnEditorContentHeightChanged? onEditorContentHeightChanged;

  const MobileEditorView({
    super.key,
    required this.onCreatedEditorAction,
    required this.onLoadCompletedEditorAction,
    this.arguments,
    this.contentViewState,
    this.onEditorContentHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (arguments == null || contentViewState == null) {
      return const SizedBox.shrink();
    }

    final direction = AppUtils.getCurrentDirection(context);
    final locale = Localizations.localeOf(context);
    final appLocalizations = AppLocalizations.of(context);
    final actionType = arguments!.emailActionType;

    if (_isEditOrComposeAction(actionType)) {
      return contentViewState!.fold(
        (_) => buildEditor(direction: direction),
        (success) {
          if (success is GetEmailContentLoading) {
            return const CupertinoLoadingWidget(padding: EdgeInsets.all(16.0));
          }

          String newContent = '';
          if (success is GetEmailContentSuccess) {
            newContent = success.htmlEmailContent;
          } else if (success is GetEmailContentFromCacheSuccess) {
            newContent = success.htmlEmailContent;
          }

          return buildEditor(
            direction: direction,
            content: newContent,
          );
        },
      );
    }

    if (_isReplyOrForwardAction(actionType)) {
      return contentViewState!.fold(
        (_) => buildEditor(
          direction: direction,
          content: _buildQuotedContent(
            appLocalizations: appLocalizations,
            locale: locale,
          ),
        ),
        (success) {
          if (success is GetEmailContentLoading) {
            return const CupertinoLoadingWidget(padding: EdgeInsets.all(16.0));
          }

          return buildEditor(
            direction: direction,
            content: _buildQuotedContent(
              appLocalizations: appLocalizations,
              locale: locale,
              emailContent: success is GetEmailContentSuccess
                ? success.htmlEmailContent
                : '',
            ),
          );
        },
      );
    }

    return contentViewState!.fold(
      (_) => buildEditor(direction: direction),
      (success) {
        if (success is GetEmailContentLoading) {
          return const CupertinoLoadingWidget(padding: EdgeInsets.all(16.0));
        }
        return buildEditor(direction: direction);
      },
    );
  }

  bool _isEditOrComposeAction(EmailActionType type) {
    return {
      EmailActionType.editDraft,
      EmailActionType.editSendingEmail,
      EmailActionType.composeFromContentShared,
      EmailActionType.reopenComposerBrowser,
      EmailActionType.composeFromMailtoUri,
      EmailActionType.composeFromUnsubscribeMailtoLink,
      EmailActionType.editAsNewEmail,
    }.contains(type);
  }

  bool _isReplyOrForwardAction(EmailActionType type) {
    return {
      EmailActionType.reply,
      EmailActionType.replyToList,
      EmailActionType.replyAll,
      EmailActionType.forward,
    }.contains(type);
  }

  String _buildQuotedContent({
    required AppLocalizations appLocalizations,
    required Locale locale,
    String emailContent = '',
  }) {
    return getEmailContentQuotedAsHtml(
      locale: locale,
      appLocalizations: appLocalizations,
      emailContent: emailContent,
      emailActionType: arguments!.emailActionType,
      presentationEmail: arguments!.presentationEmail!,
    );
  }

  Widget buildEditor({
    required TextDirection direction,
    String content = '',
  }) {
    return MobileEditorWidget(
      content: content.isEmpty ? HtmlExtension.editorStartTags : content,
      direction: direction,
      onCreatedEditorAction: onCreatedEditorAction,
      onLoadCompletedEditorAction: onLoadCompletedEditorAction,
      onEditorContentHeightChanged: onEditorContentHeightChanged,
    );
  }
}