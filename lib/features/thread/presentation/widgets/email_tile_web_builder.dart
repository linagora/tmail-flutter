import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/widget/labels/ai_action_tag_widget.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_widget.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/desktop_list_email_action_hover_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/web_tablet_body_email_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailTileBuilder extends StatefulWidget {

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

  const EmailTileBuilder({
    super.key,
    required this.presentationEmail,
    required this.selectAllMode,
    required this.isShowingEmailContent,
    this.labels,
    this.searchQuery,
    this.isSearchEmailRunning = false,
    this.isSenderImportantFlagEnabled = true,
    this.autoWrapTagsByMaxWidth = false,
    this.isLabelMailboxOpened = false,
    this.mailboxContain,
    this.padding,
    this.isDrag = false,
    this.isAINeedsActionEnabled = false,
    this.emailActionClick,
    this.onMoreActionClick,
  });

  @override
  State<EmailTileBuilder> createState() => _EmailTileBuilderState();
}

class _EmailTileBuilderState extends State<EmailTileBuilder>  with BaseEmailItemTile {
  final ValueNotifier<bool> _hoverNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final isEmailSelected = widget.presentationEmail.isSelected;
    final isEmailStarred = widget.presentationEmail.hasStarred;

    return ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => widget.emailActionClick?.call(
            EmailActionType.preview,
            widget.presentationEmail
          ),
          onLongPress: () => widget.emailActionClick?.call(
            EmailActionType.selection,
            widget.presentationEmail
          ),
          hoverColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          child: Container(
            padding: widget.padding ?? _getPaddingItem(context),
            decoration: _getDecorationItem(),
            alignment: Alignment.center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => widget.emailActionClick?.call(
                      widget.selectAllMode == SelectMode.ACTIVE
                        ? EmailActionType.selection
                        : EmailActionType.preview,
                      widget.presentationEmail
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(top: 8, end: 12),
                      child: _buildAvatarIcon(context: context),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        if (!widget.presentationEmail.hasRead)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 5),
                            child: buildIconUnreadStatus(),
                          ),
                        Expanded(
                          child: buildInformationSender(
                            context,
                            widget.presentationEmail,
                            widget.mailboxContain,
                            widget.isSearchEmailRunning,
                            widget.searchQuery
                          )
                        ),
                        buildIconAnsweredOrForwarded(
                          width: 16,
                          height: 16,
                          presentationEmail: widget.presentationEmail
                        ),
                        if (widget.presentationEmail.hasAttachment == true)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 8),
                            child: buildIconAttachment(),
                          ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: 4,
                            start: 8
                          ),
                          child: buildDateTime(context, widget.presentationEmail)
                        ),
                        buildIconChevron()
                      ]),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.presentationEmail.hasCalendarEvent)
                            buildCalendarEventIcon(
                              context: context,
                              presentationEmail: widget.presentationEmail
                            ),
                          if (widget.presentationEmail.isMarkAsImportant && widget.isSenderImportantFlagEnabled)
                            buildMarkAsImportantIcon(context),
                          Expanded(
                            child: buildEmailTitle(
                              context,
                              widget.presentationEmail,
                              widget.isSearchEmailRunning,
                              widget.searchQuery
                            )
                          ),
                          buildMailboxContain(
                            context,
                            widget.isSearchEmailRunning,
                            widget.isLabelMailboxOpened,
                            widget.presentationEmail
                          ),
                          if (widget.presentationEmail.hasStarred)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 8),
                              child: buildIconStar(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      _buildPartialContentMobile(context),
                    ],
                  ),
                )
              ]
            ),
          )
        ),
      ),
      tablet: WebTabletBodyEmailItemWidget(
        presentationEmail: widget.presentationEmail,
        selectAllMode: widget.selectAllMode,
        canDeletePermanently: canDeletePermanently,
        isSearchEmailRunning: widget.isSearchEmailRunning,
        isLabelMailboxOpened: widget.isLabelMailboxOpened,
        isShowingEmailContent: widget.isShowingEmailContent,
        isDrag: widget.isDrag,
        isSenderImportantFlagEnabled: widget.isSenderImportantFlagEnabled,
        shouldShowAIAction: _shouldShowAIAction,
        autoWrapTagsByMaxWidth: widget.autoWrapTagsByMaxWidth,
        labels: widget.labels,
        padding: widget.padding,
        searchQuery: widget.searchQuery,
        mailboxContain: widget.mailboxContain,
        emailActionClick: widget.emailActionClick,
        onMoreActionClick: widget.onMoreActionClick,
      ),
      desktop: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 2,
          start: 3,
          end: 3,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => widget.emailActionClick?.call(
              EmailActionType.preview,
              widget.presentationEmail
            ),
            onHover: (value) => _hoverNotifier.value = value,
            hoverColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            child: Container(
              padding: widget.padding ?? _getPaddingItem(context),
              decoration: _getDecorationItem(),
              alignment: Alignment.center,
              child: Row(children: [
                ValueListenableBuilder(
                  valueListenable: _hoverNotifier,
                  builder: (_, isHovered, __) {
                    return TMailButtonWidget.fromIcon(
                      icon: isEmailSelected
                          ? imagePaths.icCheckboxSelected
                          : imagePaths.icCheckboxUnselected,
                      iconColor: isHovered || isEmailSelected
                          ? AppColor.primaryColor
                          : AppColor.colorEmailTileCheckboxUnhover,
                      iconSize: 20,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsetsDirectional.only(start: 4),
                      backgroundColor: Colors.transparent,
                      tooltipMessage: isEmailSelected
                          ? AppLocalizations.of(context).selected
                          : AppLocalizations.of(context).notSelected,
                      onTapActionCallback: () {
                        widget.emailActionClick?.call(
                            EmailActionType.selection,
                            widget.presentationEmail
                        );
                      },
                    );
                  },
                ),
                TMailButtonWidget.fromIcon(
                  icon: isEmailStarred
                      ? imagePaths.icStar
                      : imagePaths.icUnStar,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: isEmailStarred
                      ? AppLocalizations.of(context).not_starred
                      : AppLocalizations.of(context).mark_as_starred,
                  onTapActionCallback: () {
                    widget.emailActionClick?.call(
                      isEmailStarred
                          ? EmailActionType.unMarkAsStarred
                          : EmailActionType.markAsStarred,
                      widget.presentationEmail,
                    );
                  },
                ),
                buildIconWeb(
                  icon: buildIconAnsweredOrForwarded(presentationEmail: widget.presentationEmail),
                  tooltip: messageToolTipForAnsweredOrForwarded(context, widget.presentationEmail),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  iconPadding: EdgeInsets.zero,
                  minSize: 28,
                  splashRadius: 1
                ),
                buildIconWeb(
                  icon: widget.presentationEmail.hasRead
                    ? const SizedBox(width: 20, height: 20)
                    : Container(
                        alignment: Alignment.center,
                        width: 20,
                        height: 20,
                        child: buildIconUnreadStatus(),
                      ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  iconPadding: EdgeInsets.zero,
                  minSize: 28,
                  tooltip: widget.presentationEmail.hasRead
                    ? null
                    : AppLocalizations.of(context).mark_as_read,
                  onTap: widget.presentationEmail.hasRead ? null : () {
                    widget.emailActionClick?.call(
                      EmailActionType.markAsRead,
                      widget.presentationEmail
                    );
                  },
                ),
                buildIconAvatarText(
                  widget.presentationEmail,
                  iconSize: 32,
                  textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 160,
                  child: buildInformationSender(
                    context,
                    widget.presentationEmail,
                    widget.mailboxContain,
                    widget.isSearchEmailRunning,
                    widget.searchQuery
                  )
                ),
                const SizedBox(width: 24),
                Expanded(child: _buildSubjectAndContent(context)),
                const SizedBox(width: 16),
                ValueListenableBuilder(
                  valueListenable: _hoverNotifier,
                  builder: (_, value, __) {
                    return DesktopListEmailActionHoverWidget(
                      presentationEmail: widget.presentationEmail,
                      isHovered: value,
                      canDeletePermanently: canDeletePermanently,
                      isSearchEmailRunning: widget.isSearchEmailRunning,
                      isLabelMailboxOpened: widget.isLabelMailboxOpened,
                      mailboxContain: widget.mailboxContain,
                      emailActionClick: widget.emailActionClick,
                      onMoreActionClick: widget.onMoreActionClick,
                    );
                  }
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsetsGeometry _getPaddingItem(BuildContext context) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsets.symmetric(vertical: 2);
    } else if (responsiveUtils.isTablet(context)) {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 24);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 12);
    }
  }

  BoxDecoration? _getDecorationItem() {
    if (((widget.selectAllMode == SelectMode.ACTIVE && widget.presentationEmail.selectMode == SelectMode.ACTIVE) || widget.isDrag) &&
        responsiveUtils.isDesktop(context)
    ) {
      return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: AppColor.blue100,
      );
    } else if (widget.isShowingEmailContent && responsiveUtils.isTabletLarge(context)) {
      return const BoxDecoration(color: AppColor.blue100);
    } else {
      return null;
    }
  }

  bool get canDeletePermanently {
    return widget.mailboxContain?.isTrash == true || widget.mailboxContain?.isDrafts == true || widget.mailboxContain?.isSpam == true;
  }

  Widget _buildSubjectAndContent(BuildContext context) {
    final emailTitle = widget.presentationEmail.getEmailTitle();
    final emailPartialContent = widget.presentationEmail.getPartialContent();

    return Row(
      children: [
        if (widget.presentationEmail.hasCalendarEvent)
          buildCalendarEventIcon(
            context: context,
            presentationEmail: widget.presentationEmail,
          ),
        if (widget.presentationEmail.isMarkAsImportant &&
            widget.isSenderImportantFlagEnabled)
          buildMarkAsImportantIcon(context),
        if (_shouldShowAIAction)
          const AiActionTagWidget(margin: EdgeInsetsDirectional.only(end: 12)),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              const horizontalPadding = 12.0;

              final maxWidth = constraints.maxWidth;
              final maxWidthNoPadding = maxWidth - horizontalPadding * 2;

              final hasLabels = widget.labels?.isNotEmpty == true;
              final isAutoWrap = widget.autoWrapTagsByMaxWidth;
              final hasTitle = emailTitle.isNotEmpty;
              final hasContent = emailPartialContent.isNotEmpty;

              final labelTagsMaxWidth =
                  hasTitle ? maxWidthNoPadding * 0.4 : maxWidthNoPadding * 0.5;

              final emailTitleMaxWidth =
                  hasLabels ? maxWidthNoPadding * 0.4 : maxWidthNoPadding * 0.5;

              return Row(
                children: [
                  if (hasLabels)
                    _buildLabelsDesktop(
                      context: context,
                      maxWidth: labelTagsMaxWidth,
                      horizontalPadding: horizontalPadding,
                      isAutoWrap: isAutoWrap,
                    ),
                  if (hasTitle)
                    _buildTitleDesktop(
                      context: context,
                      maxWidth: emailTitleMaxWidth,
                      horizontalPadding: horizontalPadding,
                      hasContent: hasContent,
                    ),
                  if (hasContent)
                    _buildPartialContentDesktop(context),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLabelsDesktop({
    required BuildContext context,
    required double maxWidth,
    required double horizontalPadding,
    required bool isAutoWrap,
  }) {
    final labels = widget.labels;
    if (labels == null || labels.isEmpty) return const SizedBox.shrink();

    final child = LabelTagListWidget(
      tags: labels,
      autoWrapTagsByMaxWidth: widget.autoWrapTagsByMaxWidth,
      isDesktop: responsiveUtils.isDesktop(context),
    );

    if (isAutoWrap) {
      return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsetsDirectional.only(end: horizontalPadding),
        child: child,
      );
    }

    return Padding(
      padding: EdgeInsetsDirectional.only(end: horizontalPadding),
      child: child,
    );
  }

  Widget _buildTitleDesktop({
    required BuildContext context,
    required double maxWidth,
    required double horizontalPadding,
    bool hasContent = false,
  }) {
    if (hasContent) {
      return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsetsDirectional.only(end: horizontalPadding),
        child: buildEmailTitle(
          context,
          widget.presentationEmail,
          widget.isSearchEmailRunning,
          widget.searchQuery,
        ),
      );
    } else {
      return Expanded(
        child: Padding(
          padding: EdgeInsetsDirectional.only(end: horizontalPadding),
          child: buildEmailTitle(
            context,
            widget.presentationEmail,
            widget.isSearchEmailRunning,
            widget.searchQuery,
          ),
        ),
      );
    }
  }

  Widget _buildPartialContentDesktop(BuildContext context) {
    return Expanded(
      child: buildEmailPartialContent(
        context,
        widget.presentationEmail,
        widget.isSearchEmailRunning,
        widget.searchQuery,
      ),
    );
  }

  Widget _buildPartialContentMobile(BuildContext context) {
    final labels = widget.labels;
    final hasLabels = labels?.isNotEmpty == true;
    final hasContent = widget.presentationEmail.getPartialContent().isNotEmpty;
    final isAutoWrap = widget.autoWrapTagsByMaxWidth;
    final isDesktop = responsiveUtils.isDesktop(context);

    final partialContent = buildEmailPartialContent(
      context,
      widget.presentationEmail,
      widget.isSearchEmailRunning,
      widget.searchQuery,
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

  Widget _buildAvatarIcon({
    required BuildContext context,
    bool isHovered = false,
    double? iconSize,
    TextStyle? textStyle
  }) {
    if (widget.presentationEmail.isSelected ||
        (responsiveUtils.isScreenWithShortestSide(context) && widget.selectAllMode == SelectMode.ACTIVE) ||
        isHovered
    ) {
      return buildIconAvatarSelection(
        context,
        widget.presentationEmail,
        iconSize: iconSize ?? 48,
        textStyle: textStyle
      );
    } else {
      return buildIconAvatarText(
        widget.presentationEmail,
        iconSize: iconSize ?? 48,
        textStyle: textStyle
      );
    }
  }

  bool get _shouldShowAIAction =>
      widget.isAINeedsActionEnabled && widget.presentationEmail.hasNeedAction;

  @override
  void dispose() {
    _hoverNotifier.dispose();
    super.dispose();
  }
}