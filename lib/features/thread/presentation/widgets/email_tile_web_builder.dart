
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
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
  final OnPressEmailActionClick? emailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  const EmailTileBuilder({
    super.key,
    required this.presentationEmail,
    required this.selectAllMode,
    required this.isShowingEmailContent,
    this.searchQuery,
    this.isSearchEmailRunning = false,
    this.isSenderImportantFlagEnabled = true,
    this.mailboxContain,
    this.padding,
    this.isDrag = false,
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
                  child: Column(children: [
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
                    Row(children: [
                      Expanded(
                        child: buildEmailPartialContent(
                          context,
                          widget.presentationEmail,
                          widget.isSearchEmailRunning,
                          widget.searchQuery
                        )
                      ),
                    ]),
                  ]),
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
        isShowingEmailContent: widget.isShowingEmailContent,
        isDrag: widget.isDrag,
        isSenderImportantFlagEnabled: widget.isSenderImportantFlagEnabled,
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
                const SizedBox(width: 10),
                buildIconWeb(
                  icon: ValueListenableBuilder(
                    valueListenable: _hoverNotifier,
                    builder: (context, isHovered, child) {
                      return SvgPicture.asset(
                        widget.presentationEmail.isSelected
                          ? imagePaths.icCheckboxSelected
                          : imagePaths.icCheckboxUnselected,
                        colorFilter: ColorFilter.mode(
                          isHovered || widget.presentationEmail.isSelected
                            ? AppColor.primaryColor
                            : AppColor.colorEmailTileCheckboxUnhover,
                          BlendMode.srcIn),
                        width: 20,
                        height: 20);
                    },
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  iconPadding: EdgeInsets.zero,
                  minSize: 28,
                  tooltip: widget.presentationEmail.isSelected
                    ? AppLocalizations.of(context).selected
                    : AppLocalizations.of(context).notSelected,
                  onTap: () {
                    widget.emailActionClick?.call(
                      EmailActionType.selection,
                      widget.presentationEmail
                    );
                  },
                ),
                buildIconWeb(
                  icon: SvgPicture.asset(
                    widget.presentationEmail.hasStarred
                      ? imagePaths.icStar
                      : imagePaths.icUnStar,
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  iconPadding: EdgeInsets.zero,
                  minSize: 28,
                  tooltip: widget.presentationEmail.hasStarred
                    ? AppLocalizations.of(context).not_starred
                    : AppLocalizations.of(context).mark_as_starred,
                  onTap: () => widget.emailActionClick?.call(
                    widget.presentationEmail.hasStarred
                      ? EmailActionType.unMarkAsStarred
                      : EmailActionType.markAsStarred,
                    widget.presentationEmail
                  )
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
                  textStyle: const TextStyle(
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
                Expanded(child: _buildSubjectAndContent()),
                const SizedBox(width: 16),
                ValueListenableBuilder(
                  valueListenable: _hoverNotifier,
                  builder: (_, value, __) {
                    return DesktopListEmailActionHoverWidget(
                      presentationEmail: widget.presentationEmail,
                      isHovered: value,
                      canDeletePermanently: canDeletePermanently,
                      isSearchEmailRunning: widget.isSearchEmailRunning,
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
      return const EdgeInsets.symmetric(vertical: 4);
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

  Widget _buildSubjectAndContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(children: [
        if (widget.presentationEmail.hasCalendarEvent)
          buildCalendarEventIcon(context: context, presentationEmail: widget.presentationEmail),
        if (widget.presentationEmail.isMarkAsImportant && widget.isSenderImportantFlagEnabled)
          buildMarkAsImportantIcon(context),
        if (widget.presentationEmail.getEmailTitle().isNotEmpty)
            Container(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: buildEmailTitle(
                context,
                widget.presentationEmail,
                widget.isSearchEmailRunning,
                widget.searchQuery
              )),
        Expanded(
          child: buildEmailPartialContent(
            context,
            widget.presentationEmail,
            widget.isSearchEmailRunning,
            widget.searchQuery
          ),
        ),
      ]);
    });
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

  @override
  void dispose() {
    _hoverNotifier.dispose();
    super.dispose();
  }
}