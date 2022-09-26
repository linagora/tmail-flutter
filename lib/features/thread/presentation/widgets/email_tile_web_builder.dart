
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EmailTileBuilder with BaseEmailItemTile {

  final PresentationEmail _presentationEmail;
  final BuildContext _context;
  final SelectMode _selectModeAll;
  final PresentationMailbox? mailboxCurrent;
  final SearchStatus _searchStatus;
  final SearchQuery? _searchQuery;
  final bool advancedSearchActivated;
  final EdgeInsets? padding;
  final EdgeInsets? paddingDivider;

  OnPressEmailActionClick? _emailActionClick;
  OnMoreActionClick? _onMoreActionClick;

  bool isHoverItem = false;
  bool isHoverIcon = false;

  EmailTileBuilder(
    this._context,
    this._presentationEmail,
    this._selectModeAll,
    this._searchStatus,
    this._searchQuery,
    {
      this.advancedSearchActivated = false,
      this.mailboxCurrent,
      this.padding,
      this.paddingDivider,
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
    if (responsiveUtils.isDesktop(_context)) {
      return Container(
        margin: const EdgeInsets.only(top: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: _selectModeAll == SelectMode.ACTIVE &&
          _presentationEmail.selectMode == SelectMode.ACTIVE
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColor.colorItemEmailSelectedDesktop)
            : null,
        child: tile,
      );
    } else {
      return Container(
          margin: const EdgeInsets.only(top: 3, left: 16, right: 16),
          padding: const EdgeInsets.only(bottom: 8, right: 8, top: 8),
          decoration: _selectModeAll == SelectMode.ACTIVE &&
            _presentationEmail.selectMode == SelectMode.ACTIVE
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColor.colorItemEmailSelectedDesktop)
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  color: Colors.white),
          alignment: Alignment.center,
          child: tile);
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
                      mailboxCurrent,
                      _searchStatus,
                      _searchQuery)),
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
                        _searchStatus,
                        _searchQuery)),
                    buildMailboxContain(
                        _searchStatus,
                        advancedSearchActivated,
                        _presentationEmail),
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
                      _searchStatus,
                      _searchQuery)),
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
                          mailboxCurrent,
                          _searchStatus,
                          _searchQuery)),
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
                            _searchStatus,
                            _searchQuery)),
                        buildMailboxContain(
                            _searchStatus,
                            advancedSearchActivated,
                            _presentationEmail),
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
                          _searchStatus,
                          _searchQuery)),
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
                  mailboxCurrent,
                  _searchStatus,
                  _searchQuery)),
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
      if (mailboxCurrent?.isDrafts == false)
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
      if (mailboxCurrent?.isDrafts == false)
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
    return mailboxCurrent?.isTrash == true || mailboxCurrent?.isDrafts == true;
  }

  Widget _buildDateTimeForDesktopScreen() {
    return Row(children: [
      buildMailboxContain(
          _searchStatus,
          advancedSearchActivated,
          _presentationEmail),
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
                    _searchStatus,
                    _searchQuery)),
        Expanded(child: Container(
            child: buildEmailPartialContent(
                _presentationEmail,
                _searchStatus,
                _searchQuery))
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