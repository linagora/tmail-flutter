
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/tap_down_details_extension.dart';
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
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailTileBuilder extends StatefulWidget {

  final PresentationEmail presentationEmail;
  final SelectMode selectAllMode;
  final PresentationMailbox? mailboxContain;
  final SearchQuery? searchQuery;
  final bool isSearchEmailRunning;
  final EdgeInsets? padding;
  final EdgeInsets? paddingDivider;
  final bool isDrag;
  final bool isShowingEmailContent;
  final OnPressEmailActionClick? emailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  const EmailTileBuilder({
    super.key,
    required this.presentationEmail,
    required this.selectAllMode,
    required this.isShowingEmailContent,
    this.searchQuery,
    this.isSearchEmailRunning = false,
    this.mailboxContain,
    this.padding,
    this.paddingDivider,
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
    return Container(
      margin: _getMarginItem(context),
      padding: _getPaddingItem(context),
      decoration: _getDecorationItem(),
      alignment: Alignment.center,
      child: ResponsiveWidget(
        responsiveUtils: responsiveUtils,
        mobile: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            InkWell(
              onTap: () => widget.emailActionClick?.call(
                EmailActionType.preview,
                widget.presentationEmail
              ),
              onLongPress: () => widget.emailActionClick?.call(
                EmailActionType.selection,
                widget.presentationEmail
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
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
                  Expanded(
                    child: Column(children: [
                      Row(children: [
                        if (!widget.presentationEmail.hasRead)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 5),
                            child: SvgPicture.asset(
                              imagePaths.icUnreadStatus,
                              width: 9,
                              height: 9,
                              fit: BoxFit.fill
                            )
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
                            child: SvgPicture.asset(
                              imagePaths.icAttachment,
                              width: 16,
                              height: 16,
                              fit: BoxFit.fill
                            )
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.presentationEmail.hasCalendarEvent)
                            buildCalendarEventIcon(
                              context: context,
                              presentationEmail: widget.presentationEmail
                            ),
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
                      const SizedBox(height: 8),
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
              )
            ),
            if (widget.selectAllMode == SelectMode.INACTIVE)
              Transform(
                transform: Matrix4.translationValues(0.0, 10.0, 0.0),
                child: const Divider(
                  color: AppColor.lineItemListColor,
                  height: 1
                )
              ),
          ],
        ),
        tablet: InkWell(
          onTap: () => widget.emailActionClick?.call(
            EmailActionType.preview,
            widget.presentationEmail
          ),
          onHover: (value) => _hoverNotifier.value = value,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => widget.emailActionClick?.call(
                      EmailActionType.selection,
                      widget.presentationEmail
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(top: 8, end: 12),
                      child: ValueListenableBuilder(
                        valueListenable: _hoverNotifier,
                        builder: (context, value, child) {
                          return _buildAvatarIcon(
                            context: context,
                            isHovered: value
                          );
                        }
                      )
                    )
                  ),
                  Expanded(child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(children: [
                        Row(children: [
                          if (!widget.presentationEmail.hasRead)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 5),
                              child: SvgPicture.asset(
                                  imagePaths.icUnreadStatus,
                                  width: 9,
                                  height: 9,
                                  fit: BoxFit.fill
                              )
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
                          ValueListenableBuilder(
                            valueListenable: _hoverNotifier,
                            builder: (context, value, child) {
                              if (value) {
                                return const SizedBox(width: 120);
                              } else {
                                return _buildDateTimeForMobileTabletScreen(context);
                              }
                            }
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.presentationEmail.hasCalendarEvent)
                              buildCalendarEventIcon(
                                context: context,
                                presentationEmail: widget.presentationEmail
                              ),
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
                              )
                          ],
                        ),
                        const SizedBox(height: 8),
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
                      if (widget.selectAllMode == SelectMode.INACTIVE)
                        Transform(
                          transform: Matrix4.translationValues(0.0, 10.0, 0.0),
                          child: const Divider(color: AppColor.lineItemListColor, height: 1),
                        ),
                    ],
                  ))
                ]
              ),
              ValueListenableBuilder(
                valueListenable: _hoverNotifier,
                builder: (context, value, child) {
                  if (value) {
                    return Positioned(
                      top: 0,
                      right: 0,
                      child: Transform(
                        transform: Matrix4.translationValues(
                          0.0,
                          widget.selectAllMode == SelectMode.INACTIVE ? -5.0 : 0.0,
                          0.0
                        ),
                        child: _buildListActionButtonWhenHover(context)
                      )
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              ),
            ],
          ),
        ),
        desktop: InkWell(
          onTap: () => widget.emailActionClick?.call(
            EmailActionType.preview,
            widget.presentationEmail
          ),
          onHover: (value) => _hoverNotifier.value = value,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: !widget.presentationEmail.hasRead
                    ? SvgPicture.asset(
                        imagePaths.icUnreadStatus,
                        width: 9,
                        height: 9,
                        fit: BoxFit.fill
                      )
                    : const SizedBox(width: 9)
                ),
                buildIconWeb(
                  icon: SvgPicture.asset(
                    widget.presentationEmail.hasStarred
                      ? imagePaths.icStar
                      : imagePaths.icUnStar,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill
                  ),
                  tooltip: widget.presentationEmail.hasStarred
                    ? AppLocalizations.of(context).starred
                    : AppLocalizations.of(context).not_starred,
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
                  iconPadding: const EdgeInsetsDirectional.only(end: 12),
                  splashRadius: 1
                ),
                InkWell(
                  onTap: () => widget.emailActionClick?.call(
                    EmailActionType.selection,
                    widget.presentationEmail
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: _hoverNotifier,
                    builder: (context, value, child) {
                      return _buildAvatarIcon(
                        context: context,
                        isHovered: value,
                        iconSize: 32,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        )
                      );
                    }
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
                  builder: (context, value, child) {
                    if (value) {
                      return _buildListActionButtonWhenHover(context);
                    } else {
                      return _buildDateTimeForDesktopScreen(context);
                    }
                  }
                ),
              ]),
              if ( widget.selectAllMode == SelectMode.INACTIVE)
                Transform(
                  transform: Matrix4.translationValues(0.0, 10, 0.0),
                  child: const Padding(
                    padding: EdgeInsetsDirectional.only(start: 120),
                    child: Divider(color: AppColor.lineItemListColor, height: 1)
                  ),
                )
            ]),
        ),
      ),
    );
  }

  EdgeInsetsGeometry _getMarginItem(BuildContext context) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsets.only(top: 3);
    } else {
      return const EdgeInsetsDirectional.only(top: 3, start: 16, end: 16);
    }
  }

  EdgeInsetsGeometry _getPaddingItem(BuildContext context) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsets.symmetric(vertical: 8);
    } else {
      return const EdgeInsetsDirectional.only(bottom: 8, end: 8, top: 8);
    }
  }

  BoxDecoration _getDecorationItem() {
    if ((widget.selectAllMode == SelectMode.ACTIVE && widget.presentationEmail.selectMode == SelectMode.ACTIVE) || widget.isDrag || widget.isShowingEmailContent) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColor.colorItemEmailSelectedDesktop);
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color: Colors.white);
    }
  }

  double _getIconSize(BuildContext context) {
    return responsiveUtils.isDesktop(context) ? 18 : 16;
  }

  EdgeInsets _getPaddingIcon(BuildContext context) {
    return responsiveUtils.isDesktop(context)
      ? const EdgeInsets.all(8)
      : const EdgeInsets.all(5);
  }

  Widget _buildListActionButtonWhenHover(BuildContext context) {
    return Row(children: [
      buildSVGIconButton(
        icon: imagePaths.icOpenInNewTab,
        iconColor: AppColor.colorActionButtonHover,
        iconSize: _getIconSize(context),
        padding: _getPaddingIcon(context),
        tooltip: AppLocalizations.of(context).openInNewTab,
        onTap: () => widget.emailActionClick?.call(
          EmailActionType.openInNewTab,
          widget.presentationEmail
        )
      ),
      if(!widget.presentationEmail.isDraft)
        buildSVGIconButton(
          icon: widget.presentationEmail.hasRead ? imagePaths.icRead: imagePaths.icUnread,
          iconColor: AppColor.colorActionButtonHover,
          iconSize: _getIconSize(context),
          padding: _getPaddingIcon(context),
          tooltip: widget.presentationEmail.hasRead
            ? AppLocalizations.of(context).mark_as_unread
            : AppLocalizations.of(context).mark_as_read,
          onTap: () => widget.emailActionClick?.call(
            widget.presentationEmail.hasRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
            widget.presentationEmail
          )
        ),
      if (widget.mailboxContain != null && widget.mailboxContain?.isDrafts == false)
        ... [
          buildSVGIconButton(
            icon: imagePaths.icMove,
            iconColor: AppColor.colorActionButtonHover,
            iconSize: _getIconSize(context),
            padding: _getPaddingIcon(context),
            tooltip: AppLocalizations.of(context).move,
            onTap: () => widget.emailActionClick?.call(
              EmailActionType.moveToMailbox,
              widget.presentationEmail
            )
          ),
        ],
      buildSVGIconButton(
        icon: imagePaths.icDeleteComposer,
        iconColor: AppColor.colorActionButtonHover,
        iconSize: responsiveUtils.isDesktop(context) ? 16 : 14,
        padding: _getPaddingIcon(context),
        tooltip: canDeletePermanently
          ? AppLocalizations.of(context).delete_permanently
          : AppLocalizations.of(context).move_to_trash,
        onTap: () => widget.emailActionClick?.call(
          canDeletePermanently ? EmailActionType.deletePermanently : EmailActionType.moveToTrash,
          widget.presentationEmail
        )
      ),
      buildSVGIconButton(
        icon: imagePaths.icMore,
        iconColor: AppColor.colorActionButtonHover,
        iconSize: _getIconSize(context),
        padding: _getPaddingIcon(context),
        tooltip: AppLocalizations.of(context).more,
        onTapDown: (tapDetails) {
          if (responsiveUtils.isScreenWithShortestSide(context)) {
            widget.onMoreActionClick?.call(widget.presentationEmail, null);
          } else {
            widget.onMoreActionClick?.call(widget.presentationEmail, tapDetails.getPosition(context));
          }
        }
      ),
      if (responsiveUtils.isDesktop(context)) const SizedBox(width: 16),
    ]);
  }

  bool get canDeletePermanently {
    return widget.mailboxContain?.isTrash == true || widget.mailboxContain?.isDrafts == true || widget.mailboxContain?.isSpam == true;
  }

  Widget _buildDateTimeForDesktopScreen(BuildContext context) {
    return Row(children: [
      buildMailboxContain(
          context,
        widget.isSearchEmailRunning,
        widget.presentationEmail
      ),
      if (widget.presentationEmail.hasAttachment == true)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: buildIconAttachment()),
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 20, start: 8),
        child: buildDateTime(context, widget.presentationEmail))
    ]);
  }

  Widget _buildDateTimeForMobileTabletScreen(BuildContext context) {
    return Row(children: [
      buildIconAnsweredOrForwarded(width: 16, height: 16, presentationEmail: widget.presentationEmail),
      if (widget.presentationEmail.hasAttachment == true)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: buildIconAttachment()),
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 4, start: 8),
        child: buildDateTime(context, widget.presentationEmail)),
      buildIconChevron()
    ]);
  }

  Widget _buildSubjectAndContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(children: [
        if (widget.presentationEmail.hasCalendarEvent)
          buildCalendarEventIcon(context: context, presentationEmail: widget.presentationEmail),
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
        Expanded(child: Container(
          child: buildEmailPartialContent(
            context,
            widget.presentationEmail,
            widget.isSearchEmailRunning,
            widget.searchQuery
          ))
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