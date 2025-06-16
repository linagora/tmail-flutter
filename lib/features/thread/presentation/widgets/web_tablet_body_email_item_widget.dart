import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/item_email_tile_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class WebTabletBodyEmailItemWidget extends StatefulWidget {
  final PresentationEmail presentationEmail;
  final SelectMode selectAllMode;
  final bool canDeletePermanently;
  final bool isSearchEmailRunning;
  final bool isShowingEmailContent;
  final bool isShowDateTimeView;
  final bool isDrag;
  final bool isSenderImportantFlagEnabled;
  final EdgeInsetsGeometry? padding;
  final SearchQuery? searchQuery;
  final PresentationMailbox? mailboxContain;
  final OnPressEmailActionClick? emailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  const WebTabletBodyEmailItemWidget({
    super.key,
    required this.presentationEmail,
    required this.selectAllMode,
    required this.canDeletePermanently,
    required this.isSearchEmailRunning,
    required this.isShowingEmailContent,
    required this.isDrag,
    required this.isSenderImportantFlagEnabled,
    required this.padding,
    required this.searchQuery,
    required this.mailboxContain,
    required this.emailActionClick,
    required this.onMoreActionClick,
    this.isShowDateTimeView = false,
  });

  @override
  State<WebTabletBodyEmailItemWidget> createState() =>
      _WebTabletBodyEmailItemWidgetState();
}

class _WebTabletBodyEmailItemWidgetState
    extends State<WebTabletBodyEmailItemWidget> with BaseEmailItemTile {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  bool _isHover = false;
  bool _popupMenuVisible = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => widget.emailActionClick?.call(
          EmailActionType.preview,
          widget.presentationEmail,
        ),
        hoverColor: Theme.of(context).colorScheme.outline.withOpacity(0.08),
        onHover: (value) {
          setState(() {
            _isHover = value;
          });
        },
        child: Container(
          padding: widget.padding ?? _getPaddingItem(context),
          decoration: _getDecorationItem(),
          alignment: Alignment.center,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () => widget.emailActionClick?.call(
                            EmailActionType.selection,
                            widget.presentationEmail),
                        child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              top: 8,
                              end: 12,
                            ),
                            child: _buildAvatarIcon(
                              context: context,
                              isHovered: _isHover,
                            ))),
                  ),
                  Expanded(
                    child: Column(
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
                              widget.searchQuery,
                            ),
                          ),
                          if (_shouldShowPopupMenu)
                            const SizedBox(width: 120)
                          else
                            _buildDateTimeForMobileTabletScreen(context),
                        ]),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.presentationEmail.hasCalendarEvent)
                              buildCalendarEventIcon(
                                context: context,
                                presentationEmail: widget.presentationEmail,
                              ),
                            if (widget.presentationEmail.isMarkAsImportant &&
                                widget.isSenderImportantFlagEnabled)
                              buildMarkAsImportantIcon(context),
                            Expanded(
                              child: buildEmailTitle(
                                context,
                                widget.presentationEmail,
                                widget.isSearchEmailRunning,
                                widget.searchQuery,
                              ),
                            ),
                            buildMailboxContain(
                              context,
                              widget.isSearchEmailRunning,
                              widget.presentationEmail,
                            ),
                            if (widget.presentationEmail.hasStarred)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 8,
                                ),
                                child: buildIconStar(),
                              )
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: buildEmailPartialContent(
                                context,
                                widget.presentationEmail,
                                widget.isSearchEmailRunning,
                                widget.searchQuery,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Transform(
                  transform: Matrix4.translationValues(
                    0.0,
                    widget.selectAllMode == SelectMode.INACTIVE ? -5.0 : 0.0,
                    0.0,
                  ),
                  child: Row(
                    children: [
                      if (_isHover) ...[
                        TMailButtonWidget.fromIcon(
                          icon: _imagePaths.icOpenInNewTab,
                          iconColor: ItemEmailTileStyles.actionIconColor,
                          iconSize: _getIconSize(),
                          padding: _getPaddingIcon(context),
                          backgroundColor: Colors.transparent,
                          tooltipMessage:
                              AppLocalizations.of(context).openInNewTab,
                          onTapActionCallback: () =>
                              widget.emailActionClick?.call(
                            EmailActionType.openInNewTab,
                            widget.presentationEmail,
                          ),
                        ),
                        if (!widget.presentationEmail.isDraft)
                          TMailButtonWidget.fromIcon(
                            icon: widget.presentationEmail.hasRead
                                ? _imagePaths.icUnread
                                : _imagePaths.icRead,
                            iconColor: ItemEmailTileStyles.actionIconColor,
                            iconSize: _getIconSize(),
                            padding: _getPaddingIcon(context),
                            backgroundColor: Colors.transparent,
                            tooltipMessage: widget.presentationEmail.hasRead
                                ? AppLocalizations.of(context).mark_as_unread
                                : AppLocalizations.of(context).mark_as_read,
                            onTapActionCallback: () =>
                                widget.emailActionClick?.call(
                              widget.presentationEmail.hasRead
                                  ? EmailActionType.markAsUnread
                                  : EmailActionType.markAsRead,
                              widget.presentationEmail,
                            ),
                          ),
                        if (widget.mailboxContain != null &&
                            widget.mailboxContain?.isDrafts == false) ...[
                          TMailButtonWidget.fromIcon(
                            icon: _imagePaths.icMove,
                            iconColor: ItemEmailTileStyles.actionIconColor,
                            iconSize: _getIconSize(),
                            padding: _getPaddingIcon(context),
                            backgroundColor: Colors.transparent,
                            tooltipMessage: AppLocalizations.of(context).move,
                            onTapActionCallback: () =>
                                widget.emailActionClick?.call(
                              EmailActionType.moveToMailbox,
                              widget.presentationEmail,
                            ),
                          ),
                        ],
                        TMailButtonWidget.fromIcon(
                          icon: _imagePaths.icDeleteComposer,
                          iconColor: ItemEmailTileStyles.actionIconColor,
                          iconSize: 14,
                          padding: _getPaddingIcon(context),
                          backgroundColor: Colors.transparent,
                          tooltipMessage: widget.canDeletePermanently
                              ? AppLocalizations.of(context).delete_permanently
                              : AppLocalizations.of(context).move_to_trash,
                          onTapActionCallback: () =>
                              widget.emailActionClick?.call(
                            widget.canDeletePermanently
                                ? EmailActionType.deletePermanently
                                : EmailActionType.moveToTrash,
                            widget.presentationEmail,
                          ),
                        ),
                      ],
                      if (_shouldShowPopupMenu)
                        TMailButtonWidget.fromIcon(
                          icon: _imagePaths.icMoreVertical,
                          iconColor: ItemEmailTileStyles.actionIconColor,
                          iconSize: _getIconSize(),
                          padding: _getPaddingIcon(context),
                          backgroundColor: _popupMenuVisible
                              ? Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.08)
                              : Colors.transparent,
                          tooltipMessage: AppLocalizations.of(context).more,
                          onTapActionAtPositionCallback: (position) {
                            if (_responsiveUtils
                                .isScreenWithShortestSide(context)) {
                              widget.onMoreActionClick
                                  ?.call(widget.presentationEmail, null);
                            } else {
                              _onPopupMenuVisibleChange(true);

                              widget.onMoreActionClick
                                  ?.call(widget.presentationEmail, position)
                                  .whenComplete(
                                      () => _onPopupMenuVisibleChange(false));
                            }
                          },
                        )
                    ],
                  ),
                ),
              )
            ],
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
    if (((widget.selectAllMode == SelectMode.ACTIVE &&
                widget.presentationEmail.selectMode == SelectMode.ACTIVE) ||
            widget.isDrag) &&
        responsiveUtils.isDesktop(context)) {
      return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: AppColor.blue100,
      );
    } else if (widget.isShowingEmailContent &&
        responsiveUtils.isTabletLarge(context)) {
      return const BoxDecoration(color: AppColor.blue100);
    } else {
      return null;
    }
  }

  Widget _buildAvatarIcon({
    required BuildContext context,
    bool isHovered = false,
    double? iconSize,
    TextStyle? textStyle,
  }) {
    if (widget.presentationEmail.isSelected ||
        (responsiveUtils.isScreenWithShortestSide(context) &&
            widget.selectAllMode == SelectMode.ACTIVE) ||
        isHovered) {
      return buildIconAvatarSelection(
        context,
        widget.presentationEmail,
        iconSize: iconSize ?? 48,
        textStyle: textStyle,
      );
    } else {
      return buildIconAvatarText(
        widget.presentationEmail,
        iconSize: iconSize ?? 48,
        textStyle: textStyle,
      );
    }
  }

  Widget _buildDateTimeForMobileTabletScreen(BuildContext context) {
    return Row(
      children: [
        buildIconAnsweredOrForwarded(
          width: 16,
          height: 16,
          presentationEmail: widget.presentationEmail,
        ),
        if (widget.presentationEmail.hasAttachment == true)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: buildIconAttachment(),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 4, start: 8),
          child: buildDateTime(
            context,
            widget.presentationEmail,
          ),
        ),
        buildIconChevron(),
      ],
    );
  }

  double _getIconSize() => 16;

  EdgeInsets _getPaddingIcon(BuildContext context) {
    return const EdgeInsets.all(5);
  }

  bool get _shouldShowPopupMenu => _isHover || _popupMenuVisible;

  void _onPopupMenuVisibleChange(bool visible) {
    if (_popupMenuVisible != visible && mounted) {
      setState(() {
        _popupMenuVisible = visible;
      });
    }
  }
}
