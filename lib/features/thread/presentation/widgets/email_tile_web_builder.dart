
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:url_launcher/link.dart';

class EmailTileBuilder with BaseEmailItemTile {

  final PresentationEmail _presentationEmail;
  final BuildContext _context;
  final SelectMode _selectModeAll;
  final PresentationMailbox? mailboxContain;
  final SearchQuery? _searchQuery;
  final bool isSearchEmailRunning;
  final EdgeInsets? padding;
  final EdgeInsets? paddingDivider;
  final bool isDrag;
  final bool _isShowingEmailContent;

  OnPressEmailActionClick? _emailActionClick;
  OnMoreActionClick? _onMoreActionClick;

  bool isHoverItem = false;
  bool isHoverIcon = false;

  EmailTileBuilder(
    this._context,
    this._presentationEmail,
    this._selectModeAll,
    this._searchQuery,
    this._isShowingEmailContent,
      {
      this.isSearchEmailRunning = false,
      this.mailboxContain,
      this.padding,
      this.paddingDivider,
      this.isDrag = false,
    }
  );

  void addOnPressEmailActionClick(OnPressEmailActionClick actionClick) {
    _emailActionClick = actionClick;
  }

  void addOnMoreActionClick(OnMoreActionClick onMoreActionClick) {
    _onMoreActionClick = onMoreActionClick;
  }

  void _onHoverIconChanged(bool isHover, StateSetter setState) {
    setState(() => isHoverIcon = isHover);
  }

  void _onHoverItemChanged(bool isHover, StateSetter setState) {
    setState(() => isHoverItem = isHover);
  }

  Widget build() {
    return Container(
      color: Colors.transparent,
      padding: padding,
      child: ResponsiveWidget(
        responsiveUtils: responsiveUtils,
        mobile: _wrapContainerForTile(_buildListTile()),
        tablet: _wrapContainerForTile(_buildListTileTablet()),
        desktop: _wrapContainerForTile(_buildListTileForDesktop()),
      ),
    );
  }

  Widget _wrapContainerForTile(Widget tile) {
    return Container(
      margin: _getMarginItem(),
      padding: _getPaddingItem(),
      decoration: _getDecorationItem(),
      alignment: Alignment.center,
      child: Link(
        uri: _presentationEmail.routeWeb,
        builder: (_, __) => tile
      )
    );
  }

  EdgeInsets _getMarginItem() {
    if (responsiveUtils.isDesktop(_context)) {
      return const EdgeInsets.only(top: 3);
    } else {
      return const EdgeInsets.only(top: 3, left: 16, right: 16);
    }
  }

  EdgeInsets _getPaddingItem() {
    if (responsiveUtils.isDesktop(_context)) {
      return const EdgeInsets.symmetric(vertical: 8);
    } else {
      return const EdgeInsets.only(bottom: 8, right: 8, top: 8);
    }
  }

  BoxDecoration _getDecorationItem() {
    if ((_selectModeAll == SelectMode.ACTIVE && _presentationEmail.selectMode == SelectMode.ACTIVE) || isDrag || _isShowingEmailContent) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColor.colorItemEmailSelectedDesktop);
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color: Colors.white);
    }
  }

  Widget _buildListTile() {
    return Stack(alignment: Alignment.bottomCenter,
      children: [
        InkWell(
          onTap: () => _emailActionClick?.call(
              EmailActionType.preview,
              _presentationEmail),
          onLongPress: () => _emailActionClick?.call(
              EmailActionType.selection,
              _presentationEmail),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: () => _emailActionClick?.call(
                  _selectModeAll == SelectMode.ACTIVE
                      ? EmailActionType.selection
                      : EmailActionType.preview,
                  _presentationEmail),
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: _buildAvatarIcon(),
              ),
            ),
            Expanded(
              child: Column(children: [
                Row(children: [
                  if (!_presentationEmail.hasRead)
                    Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(
                            imagePaths.icUnreadStatus,
                            width: 9,
                            height: 9,
                            fit: BoxFit.fill)),
                  Expanded(child: buildInformationSender(
                    _presentationEmail,
                    mailboxContain,
                    isSearchEmailRunning,
                    _searchQuery
                  )),
                  if (_presentationEmail.hasAttachment == true)
                    Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: SvgPicture.asset(
                            imagePaths.icAttachment,
                            width: 16,
                            height: 16,
                            fit: BoxFit.fill)),
                  Padding(
                      padding: const EdgeInsets.only(right: 4, left: 8),
                      child: buildDateTime(_context, _presentationEmail)),
                  buildIconChevron()
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: buildEmailTitle(
                      _presentationEmail,
                      isSearchEmailRunning,
                      _searchQuery
                    )),
                    buildMailboxContain(
                      isSearchEmailRunning,
                      _presentationEmail
                    ),
                    if (_presentationEmail.hasStarred)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: buildIconStar(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: buildEmailPartialContent(
                    _presentationEmail,
                    isSearchEmailRunning,
                    _searchQuery
                  )),
                ]),
              ]),
            )
          ])
        ),
        if (_selectModeAll == SelectMode.INACTIVE)
          Transform(
              transform: Matrix4.translationValues(0.0, 10.0, 0.0),
              child: const Divider(
                  color: AppColor.lineItemListColor,
                  height: 1,
                  thickness: 0.2)),
      ],
    );
  }

  Widget _buildListTileTablet() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        onTap: () => _emailActionClick?.call(
            EmailActionType.preview,
            _presentationEmail),
        onHover: (value) => _onHoverItemChanged(value, setState),
        child: Stack(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                onTap: () {
                  if (isHoverIcon) {
                    _emailActionClick?.call(
                        EmailActionType.selection,
                        _presentationEmail);
                  }
                },
                onHover: (value) => _onHoverIconChanged(value, setState),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: _buildAvatarIcon())),
              Expanded(child: Stack(alignment: Alignment.bottomCenter,
                children: [
                  Column(children: [
                    Row(children: [
                      if (!_presentationEmail.hasRead)
                        Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: SvgPicture.asset(
                                imagePaths.icUnreadStatus,
                                width: 9,
                                height: 9,
                                fit: BoxFit.fill)),
                      Expanded(child: buildInformationSender(
                        _presentationEmail,
                        mailboxContain,
                        isSearchEmailRunning,
                        _searchQuery
                      )),
                      if (isHoverItem)
                        const SizedBox(width: 120)
                      else
                        _buildDateTimeForMobileTabletScreen()
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: buildEmailTitle(
                          _presentationEmail,
                          isSearchEmailRunning,
                          _searchQuery
                        )),
                        buildMailboxContain(
                          isSearchEmailRunning,
                          _presentationEmail
                        ),
                        if (_presentationEmail.hasStarred)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: buildIconStar(),
                          )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: buildEmailPartialContent(
                        _presentationEmail,
                        isSearchEmailRunning,
                        _searchQuery
                      )),
                    ]),
                  ]),
                  if (_selectModeAll == SelectMode.INACTIVE)
                    Transform(
                      transform: Matrix4.translationValues(0.0, 10.0, 0.0),
                      child: const Divider(
                          color: AppColor.lineItemListColor,
                          height: 1,
                          thickness: 0.2),
                    ),
                ],
              ))
            ]),
            if (isHoverItem)
              Positioned(
                top: 0,
                right: 0,
                child: Transform(
                    transform: Matrix4.translationValues(
                        0.0,
                        _selectModeAll == SelectMode.INACTIVE ? -5.0 : 0.0,
                        0.0),
                    child: _buildListActionButtonWhenHover()))
          ],
        ),
      );
    });
  }

  Widget _buildListTileForDesktop() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        onTap: () => _emailActionClick?.call(
            EmailActionType.preview,
            _presentationEmail),
        onHover: (value) => _onHoverItemChanged(value, setState),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                alignment: Alignment.center,
                child: !_presentationEmail.hasRead
                    ? SvgPicture.asset(
                        imagePaths.icUnreadStatus,
                        width: 9,
                        height: 9,
                        fit: BoxFit.fill)
                    : const SizedBox(width: 9)),
            buildIconWeb(
                icon: SvgPicture.asset(
                    _presentationEmail.hasStarred
                        ? imagePaths.icStar
                        : imagePaths.icUnStar,
                    width: 16,
                    height: 16,
                    fit: BoxFit.fill),
                tooltip: _presentationEmail.hasStarred
                    ? AppLocalizations.of(_context).starred
                    : AppLocalizations.of(_context).not_starred,
                onTap: () => _emailActionClick?.call(
                    _presentationEmail.hasStarred
                        ? EmailActionType.unMarkAsStarred
                        : EmailActionType.markAsStarred,
                    _presentationEmail)),
            InkWell(
              onTap: () {
                if (isHoverIcon) {
                  _emailActionClick?.call(
                      EmailActionType.selection,
                      _presentationEmail);
                }
              },
              onHover: (value) => _onHoverIconChanged(value, setState),
              child: _buildAvatarIcon(
                  iconSize: 32,
                  textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 160,
              child: buildInformationSender(
                _presentationEmail,
                mailboxContain,
                isSearchEmailRunning,
                _searchQuery
              )),
            const SizedBox(width: 24),
            Expanded(child: _buildSubjectAndContent()),
            const SizedBox(width: 16),
            if (isHoverItem)
              _buildListActionButtonWhenHover()
            else
              _buildDateTimeForDesktopScreen()
          ]),
          if ( _selectModeAll == SelectMode.INACTIVE)
            Transform(
              transform: Matrix4.translationValues(0.0, 10, 0.0),
              child: const Padding(
                  padding: EdgeInsets.only(left: 80),
                  child: Divider(
                      color: AppColor.lineItemListColor,
                      height: 1,
                      thickness: 0.2)),
            )
        ]),
      );
    });
  }

  Widget _buildListActionButtonWhenHover() {
    return Row(children: [
      if(!_presentationEmail.isDraft)
        buildIconWeb(
            minSize: 18,
            iconSize: 18,
            iconPadding: const EdgeInsets.all(5),
            splashRadius: 10,
            icon: SvgPicture.asset(
                _presentationEmail.hasRead
                    ? imagePaths.icRead
                    : imagePaths.icUnread,
                color: AppColor.colorActionButtonHover,
                width: 16,
                height: 16,
                fit: BoxFit.fill),
            tooltip: _presentationEmail.hasRead
                ? AppLocalizations.of(_context).mark_as_unread
                : AppLocalizations.of(_context).mark_as_read,
            onTap: () => _emailActionClick?.call(
                _presentationEmail.hasRead
                    ? EmailActionType.markAsUnread
                    : EmailActionType.markAsRead,
                _presentationEmail)),
      const SizedBox(width: 5),
      if (mailboxContain?.isDrafts == false)
        ... [
          buildIconWeb(
              minSize: 18,
              iconSize: 18,
              iconPadding: const EdgeInsets.all(5),
              splashRadius: 10,
              icon: SvgPicture.asset(
                  imagePaths.icMove,
                  width: 16,
                  height: 16,
                  color: AppColor.colorActionButtonHover,
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(_context).move,
              onTap: () => _emailActionClick?.call(
                  EmailActionType.moveToMailbox,
                  _presentationEmail)),
          const SizedBox(width: 5),
        ],
      buildIconWeb(
          minSize: 18,
          iconSize: 18,
          iconPadding: const EdgeInsets.all(5),
          splashRadius: 10,
          icon: SvgPicture.asset(
              canDeletePermanently ? imagePaths.icDeleteComposer : imagePaths.icDelete,
              width: canDeletePermanently ? 14 : 16,
              height: canDeletePermanently ? 14 : 16,
              color: AppColor.colorActionButtonHover,
              fit: BoxFit.fill),
          tooltip: canDeletePermanently
              ? AppLocalizations.of(_context).delete_permanently
              : AppLocalizations.of(_context).move_to_trash,
          onTap: () => _emailActionClick?.call(
              canDeletePermanently
                  ? EmailActionType.deletePermanently
                  : EmailActionType.moveToTrash,
              _presentationEmail)),
      const SizedBox(width: 5),
      if (mailboxContain?.isDrafts == false)
        buildIconWebHasPosition(
            _context,
            icon: SvgPicture.asset(
                imagePaths.icMore,
                width: 16,
                height: 16,
                color: AppColor.colorActionButtonHover,
                fit: BoxFit.fill),
            tooltip: AppLocalizations.of(_context).more,
            onTap: () {
              if (responsiveUtils.isMobile(_context)) {
                _onMoreActionClick?.call(_presentationEmail, null);
              }
            },
            onTapDown: (position) {
              if (!responsiveUtils.isMobile(_context)) {
                _onMoreActionClick?.call(_presentationEmail, position);
              }
            }),
      if (responsiveUtils.isDesktop(_context)) const SizedBox(width: 16),
    ]);
  }

  bool get canDeletePermanently {
    return mailboxContain?.isTrash == true || mailboxContain?.isDrafts == true;
  }

  Widget _buildDateTimeForDesktopScreen() {
    return Row(children: [
      buildMailboxContain(
        isSearchEmailRunning,
        _presentationEmail
      ),
      if (_presentationEmail.hasAttachment == true)
        Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildIconAttachment()),
      Padding(
          padding: const EdgeInsets.only(right: 20, left: 8),
          child: buildDateTime(_context, _presentationEmail))
    ]);
  }

  Widget _buildDateTimeForMobileTabletScreen() {
    return Row(children: [
      if (_presentationEmail.hasAttachment == true)
        Padding(
            padding: const EdgeInsets.only(left: 8),
            child: buildIconAttachment()),
      Padding(
          padding: const EdgeInsets.only(right: 4, left: 8),
          child: buildDateTime(_context, _presentationEmail)),
      buildIconChevron()

    ]);
  }

  Widget _buildSubjectAndContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(children: [
        if (_presentationEmail.getEmailTitle().isNotEmpty)
            Container(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
              padding: const EdgeInsets.only(right: 12),
              child: buildEmailTitle(
                _presentationEmail,
                isSearchEmailRunning,
                _searchQuery
              )),
        Expanded(child: Container(
          child: buildEmailPartialContent(
            _presentationEmail,
            isSearchEmailRunning,
            _searchQuery
          ))
        ),
      ]);
    });
  }

  Widget _buildAvatarIcon({double? iconSize, TextStyle? textStyle}) {
    if (isHoverIcon || _presentationEmail.selectMode == SelectMode.ACTIVE ||
        (responsiveUtils.isMobile(_context) && _selectModeAll == SelectMode.ACTIVE)) {
        return buildIconAvatarSelection(
            _context,
            _presentationEmail,
            iconSize: iconSize ?? 48,
            textStyle: textStyle);
    } else {
      return buildIconAvatarText(
          _presentationEmail,
          iconSize: iconSize ?? 48,
          textStyle: textStyle);
    }
  }
}