import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/widget/labels/ai_action_tag_widget.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/item_email_tile_styles.dart';

class EmailTileBuilder extends StatelessWidget with BaseEmailItemTile {

  final PresentationEmail presentationEmail;
  final SelectMode selectAllMode;
  final PresentationMailbox? mailboxContain;
  final SearchQuery? searchQuery;
  final bool isSearchEmailRunning;
  final EdgeInsetsGeometry? padding;
  final bool isDrag;
  final bool isShowingEmailContent;
  final bool isSenderImportantFlagEnabled;
  final bool isAINeedsActionEnabled;
  final bool autoWrapTagsByMaxWidth;
  final bool isLabelMailboxOpened;
  final List<Label>? labels;
  final OnPressEmailActionClick? emailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  EmailTileBuilder({
    super.key,
    required this.presentationEmail,
    required this.selectAllMode,
    required this.isShowingEmailContent,
    this.labels,
    this.searchQuery,
    this.isSearchEmailRunning = false,
    this.isSenderImportantFlagEnabled = true,
    this.isAINeedsActionEnabled = true,
    this.autoWrapTagsByMaxWidth = false,
    this.isLabelMailboxOpened = false,
    this.mailboxContain,
    this.padding,
    this.isDrag = false,
    this.emailActionClick,
    this.onMoreActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        tileColor: isShowingEmailContent ? AppColor.colorItemEmailSelectedDesktop : null,
        contentPadding: padding ?? ItemEmailTileStyles.getMobilePaddingItemList(context, responsiveUtils),
        onTap: () => emailActionClick?.call(
            EmailActionType.preview,
            presentationEmail),
        onLongPress: () => emailActionClick?.call(
            EmailActionType.selection,
            presentationEmail),
        minLeadingWidth: ItemEmailTileStyles.avatarIconSize,
        horizontalTitleGap: ItemEmailTileStyles.horizontalTitleGap,
        leading: GestureDetector(
          onTap: () => emailActionClick?.call(
              selectAllMode == SelectMode.ACTIVE
                  ? EmailActionType.selection
                  : EmailActionType.preview,
              presentationEmail),
          child: Container(
            width: ItemEmailTileStyles.avatarIconSize,
            height: ItemEmailTileStyles.avatarIconSize,
            alignment: Alignment.center,
            child:  selectAllMode == SelectMode.ACTIVE
              ? buildIconAvatarSelection(context, presentationEmail)
              : buildIconAvatarText(presentationEmail)
          )
        ),
        title: Row(
          children: [
            if (!presentationEmail.hasRead)
              Padding(
                  padding: const EdgeInsetsDirectional.only(end: 5),
                  child: buildIconUnreadStatus(),
              ),
            Expanded(child: buildInformationSender(
              context,
              presentationEmail,
              mailboxContain,
              isSearchEmailRunning,
              searchQuery)),
            buildIconAnsweredOrForwarded(width: 16, height: 16, presentationEmail: presentationEmail),
            if (presentationEmail.hasAttachment == true)
              Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: buildIconAttachment()),
            Padding(
                padding: const EdgeInsetsDirectional.only(end: 4, start: 8),
                child: buildDateTime(context, presentationEmail)),
            buildIconChevron(),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (presentationEmail.hasCalendarEvent)
                      buildCalendarEventIcon(context: context, presentationEmail: presentationEmail),
                    if (presentationEmail.isMarkAsImportant && isSenderImportantFlagEnabled)
                      buildMarkAsImportantIcon(context),
                    Expanded(child: buildEmailTitle(
                      context,
                      presentationEmail,
                      isSearchEmailRunning,
                      searchQuery)),
                    buildMailboxContain(
                      context,
                      isSearchEmailRunning,
                      isLabelMailboxOpened,
                      presentationEmail),
                    if (presentationEmail.hasStarred)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: buildIconStar(),
                      )
                  ],
                )),
            Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: _buildPartialContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialContent(BuildContext context) {
    final hasLabels = labels?.isNotEmpty == true;
    final isDesktop = responsiveUtils.isDesktop(context);
    final isAutoWrap = autoWrapTagsByMaxWidth;

    final hasContent =
        presentationEmail.getPartialContent().isNotEmpty;

    final partialContent = buildEmailPartialContent(
      context,
      presentationEmail,
      isSearchEmailRunning,
      searchQuery,
    );

    if (!hasLabels) {
      return Row(
        children: [
          if (hasContent)
            Flexible(child: partialContent),
          if (_shouldShowAIAction)
            const AiActionTagWidget(
              margin: EdgeInsetsDirectional.only(start: 8),
            ),
        ],
      );
    }

    if (!hasContent) {
      return Row(
        children: [
          if (_shouldShowAIAction)
            const AiActionTagWidget(
              margin: EdgeInsetsDirectional.only(start: 8),
            ),
          Flexible(
            child: LabelTagListWidget(
              tags: labels!,
              autoWrapTagsByMaxWidth: isAutoWrap,
              isDesktop: isDesktop,
            ),
          ),
        ],
      );
    }

    if (!isAutoWrap) {
      return Row(
        children: [
          Flexible(child: partialContent),
          if (_shouldShowAIAction)
            const AiActionTagWidget(
              margin: EdgeInsetsDirectional.only(start: 8),
            ),
          const SizedBox(width: 12),
          LabelTagListWidget(
            tags: labels!,
            autoWrapTagsByMaxWidth: isAutoWrap,
            isDesktop: isDesktop,
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return Row(
          children: [
            Expanded(child: partialContent),
            if (_shouldShowAIAction)
              const AiActionTagWidget(
                margin: EdgeInsetsDirectional.only(start: 8),
              ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
              child: LabelTagListWidget(
                tags: labels!,
                autoWrapTagsByMaxWidth: isAutoWrap,
                isDesktop: isDesktop,
              ),
            ),
          ],
        );
      },
    );
  }

  bool get _shouldShowAIAction =>
      isAINeedsActionEnabled && presentationEmail.hasNeedAction;
}