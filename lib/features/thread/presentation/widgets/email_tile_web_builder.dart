import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPressEmailActionClick = void Function(EmailActionType, PresentationEmail);
typedef OnMoreActionClick = void Function(PresentationEmail, RelativeRect?);

class EmailTileBuilder {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  final PresentationEmail _presentationEmail;
  final BuildContext _context;
  final SelectMode _selectModeAll;
  final Role? _mailboxRole;
  final SearchStatus _searchStatus;
  final SearchQuery? _searchQuery;

  OnPressEmailActionClick? _emailActionClick;
  OnMoreActionClick? _onMoreActionClick;

  bool isHoverItem = false;

  EmailTileBuilder(
    this._context,
    this._presentationEmail,
    this._mailboxRole,
    this._selectModeAll,
    this._searchStatus,
    this._searchQuery,
  );

  void addOnPressEmailActionClick(OnPressEmailActionClick actionClick) {
    _emailActionClick = actionClick;
  }

  void addOnMoreActionClick(OnMoreActionClick onMoreActionClick) {
    _onMoreActionClick = onMoreActionClick;
  }

  Widget build() {
    return Theme(
      key: Key('thread_tile'),
      data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Container(
          margin: _selectModeAll == SelectMode.ACTIVE
              ? EdgeInsets.only(top: 3, left: 16, right: 16)
              : EdgeInsets.zero,
          padding: _selectModeAll == SelectMode.ACTIVE
              ? EdgeInsets.only(top: 8, bottom: 16, right: 8)
              : EdgeInsets.only(bottom: 10, left: 16, right: 16),
          decoration: _selectModeAll == SelectMode.ACTIVE && _presentationEmail.selectMode == SelectMode.ACTIVE
              ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppColor.colorItemEmailSelectedDesktop)
              : BoxDecoration(borderRadius: BorderRadius.circular(0), color: Colors.white),
          alignment: Alignment.center,
          child: _buildListTile()),
        tablet: Container(
            margin: _selectModeAll == SelectMode.ACTIVE
                ? EdgeInsets.only(top: 3, left: 16, right: 16)
                : EdgeInsets.zero,
            padding: _selectModeAll == SelectMode.ACTIVE
                ? EdgeInsets.only(top: 8, bottom: 16, right: 8)
                : EdgeInsets.only(bottom: 10, left: 16, right: 16),
            decoration: _selectModeAll == SelectMode.ACTIVE && _presentationEmail.selectMode == SelectMode.ACTIVE
                ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppColor.colorItemEmailSelectedDesktop)
                : BoxDecoration(borderRadius: BorderRadius.circular(0), color: Colors.white),
            alignment: Alignment.center,
            child: _buildListTileTabletLarge()),
        tabletLarge: Container(
            margin: _selectModeAll == SelectMode.ACTIVE
                ? EdgeInsets.only(top: 3, left: 16, right: 16)
                : EdgeInsets.zero,
            padding: _selectModeAll == SelectMode.ACTIVE
                ? EdgeInsets.only(top: 8, bottom: 16, right: 8)
                : EdgeInsets.only(bottom: 10, left: 16, right: 16),
            decoration: _selectModeAll == SelectMode.ACTIVE && _presentationEmail.selectMode == SelectMode.ACTIVE
                ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppColor.colorItemEmailSelectedDesktop)
                : BoxDecoration(borderRadius: BorderRadius.circular(0), color: Colors.white),
            alignment: Alignment.center,
            child: _buildListTileTabletLarge()),
        desktop: Container(
          margin: _selectModeAll == SelectMode.ACTIVE ? EdgeInsets.only(top: 3, left: 8, right: 8) : EdgeInsets.zero,
          padding: _selectModeAll == SelectMode.ACTIVE ? EdgeInsets.symmetric(vertical: 8) : EdgeInsets.zero,
          decoration: _selectModeAll == SelectMode.ACTIVE && _presentationEmail.selectMode == SelectMode.ACTIVE
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColor.colorItemEmailSelectedDesktop)
            : null,
          child: _buildListTileForDesktop(),
        ),
      )
    );
  }

  Widget _buildListTile() {
    return Column(children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => _emailActionClick?.call(EmailActionType.preview, _presentationEmail),
        onLongPress: () => _emailActionClick?.call(EmailActionType.selection, _presentationEmail),
        leading: GestureDetector(
          onTap: () => _emailActionClick?.call(
              _selectModeAll == SelectMode.ACTIVE ? EmailActionType.selection : EmailActionType.preview,
              _presentationEmail),
          child: _buildAvatarIcon(),
        ),
        title: Row(children: [
          if (!_presentationEmail.hasRead)
            Padding(
                padding: EdgeInsets.only(right: 5),
                child: SvgPicture.asset(_imagePaths.icUnreadStatus, width: 9, height: 9, fit: BoxFit.fill)),
          Expanded(
              child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                  ? RichTextBuilder(
                      _getInformationSender(),
                      '${_searchQuery!.value}',
                      TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                      TextStyle(fontSize: 15, color: AppColor.colorNameEmail, backgroundColor: AppColor.bgWordSearch, fontWeight: FontWeight.w600)).build()
                  : Text(
                      _getInformationSender(),
                      maxLines: 1,
                      style: TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600))
          ),
          if (_presentationEmail.hasAttachment == true)
            Padding(
                padding: EdgeInsets.only(left: 8),
                child: (ButtonBuilder(_imagePaths.icAttachment)
                    ..paddingIcon(EdgeInsets.zero)
                    ..size(16))
                  .build()),
          Padding(
              padding: EdgeInsets.only(right: 4, left: 8),
              child: Text(
                  '${_presentationEmail.getReceivedAt(Localizations.localeOf(_context).toLanguageTag())}',
                  maxLines: 1,
                  style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail))),
          (ButtonBuilder(_imagePaths.icChevron)
              ..paddingIcon(EdgeInsets.zero)
              ..size(16))
            .build(),
        ]),
        subtitle: Transform(
            transform: Matrix4.translationValues(0.0, 8.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                            ? RichTextBuilder(
                                '${_presentationEmail.getEmailTitle()}',
                                '${_searchQuery!.value}',
                                TextStyle(fontSize: 13, color: AppColor.colorNameEmail),
                                TextStyle(fontSize: 13, backgroundColor: AppColor.bgWordSearch, color: AppColor.colorNameEmail)).build()
                            : Text(
                                '${_presentationEmail.getEmailTitle()}',
                                maxLines: 1,
                                style: TextStyle(fontSize: 13, color: AppColor.colorNameEmail))
                        ),
                        if (_searchStatus == SearchStatus.ACTIVE && _presentationEmail.mailboxName.isNotEmpty)
                          Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                              constraints: BoxConstraints(maxWidth: 100),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColor.backgroundCounterMailboxColor),
                              child: Text(
                                '${_presentationEmail.mailboxName}',
                                maxLines: 1,
                                style: TextStyle(fontSize: 10, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
                              )
                          ),
                        if (_presentationEmail.hasStarred)
                          (ButtonBuilder(_imagePaths.icStar)
                              ..paddingIcon(EdgeInsets.zero)
                              ..size(15))
                            .build(),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(children: [
                      Expanded(child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                          ? RichTextBuilder(
                              '${_presentationEmail.getPartialContent()}',
                              '${_searchQuery!.value}',
                              TextStyle(fontSize: 13, color: AppColor.colorContentEmail),
                              TextStyle(fontSize: 13, color: AppColor.colorContentEmail, backgroundColor: AppColor.bgWordSearch)).build()
                          : Text(
                              '${_presentationEmail.getPartialContent()}',
                              maxLines: 1,
                              style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail))
                      ),
                    ])),
                if (_selectModeAll == SelectMode.INACTIVE)
                  Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
              ],
            )
        ),
      ),
    ]);
  }

  Widget _buildListTileTabletLarge() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        onTap: () => _emailActionClick?.call(EmailActionType.preview, _presentationEmail),
        onLongPress: () => _emailActionClick?.call(EmailActionType.selection, _presentationEmail),
        onHover: (value) => setState(() => isHoverItem = value),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: GestureDetector(
                onTap: () => _emailActionClick?.call(
                    _selectModeAll == SelectMode.ACTIVE ? EmailActionType.selection : EmailActionType.preview,
                    _presentationEmail),
                child: _buildAvatarIcon())),
          SizedBox(width: 12),
          Expanded(child: Column(children: [
            Transform(
                transform: Matrix4.translationValues(0.0, isHoverItem ? -10.0 : 0.0, 0.0),
                child: Row(children: [
                  if (!_presentationEmail.hasRead)
                    Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(_imagePaths.icUnreadStatus, width: 9, height: 9, fit: BoxFit.fill)),
                  Expanded(
                      child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                          ? RichTextBuilder(
                              _getInformationSender(),
                              '${_searchQuery!.value}',
                              TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                              TextStyle(fontSize: 15, color: AppColor.colorNameEmail, backgroundColor: AppColor.bgWordSearch, fontWeight: FontWeight.w600)).build()
                          : Text(
                              _getInformationSender(),
                              maxLines: 1,
                              style: TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600))
                  ),
                  if (isHoverItem)
                    _buildListActionButtonWhenHover()
                  else
                    _buildDateTimeForMobileTabletScreen()
                ])),
                Transform(
                  transform: Matrix4.translationValues(0.0, isHoverItem ? -10.0 : 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: isHoverItem ? 0 : 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                                  ? RichTextBuilder(
                                      '${_presentationEmail.getEmailTitle()}',
                                      '${_searchQuery!.value}',
                                      TextStyle(fontSize: 13, color: AppColor.colorNameEmail),
                                      TextStyle(fontSize: 13, backgroundColor: AppColor.bgWordSearch, color: AppColor.colorNameEmail)).build()
                                  : Text(
                                      '${_presentationEmail.getEmailTitle()}',
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 13, color: AppColor.colorNameEmail))
                              ),
                              if (_searchStatus == SearchStatus.ACTIVE && _presentationEmail.mailboxName.isNotEmpty)
                                Container(
                                    margin: EdgeInsets.only(left: 8),
                                    padding: EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                                    constraints: BoxConstraints(maxWidth: 100),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColor.backgroundCounterMailboxColor),
                                    child: Text(
                                      '${_presentationEmail.mailboxName}',
                                      maxLines: 1,
                                      style: TextStyle(fontSize: 10, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
                                    )
                                ),
                              if (_presentationEmail.hasStarred)
                                (ButtonBuilder(_imagePaths.icStar)
                                    ..paddingIcon(EdgeInsets.zero)
                                    ..size(15))
                                  .build(),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(children: [
                            Expanded(child: _searchStatus ==
                                SearchStatus.ACTIVE && _searchQuery != null &&
                                _searchQuery!.value.isNotEmpty
                                ? RichTextBuilder(
                                    '${_presentationEmail.getPartialContent()}',
                                    '${_searchQuery!.value}',
                                    TextStyle(fontSize: 13, color: AppColor.colorContentEmail),
                                    TextStyle(fontSize: 13, color: AppColor.colorContentEmail, backgroundColor: AppColor.bgWordSearch)).build()
                                : Text(
                                    '${_presentationEmail.getPartialContent()}',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail))
                            ),
                          ])),
                      if (_selectModeAll == SelectMode.INACTIVE)
                        Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
                    ],
                  )
                ),
          ]))
        ]),
      );
    });
  }

  Widget _buildListTileForDesktop() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        onTap: () => _emailActionClick?.call(EmailActionType.preview, _presentationEmail),
        onLongPress: () => _emailActionClick?.call(EmailActionType.selection, _presentationEmail),
        onHover: (value) => setState(() => isHoverItem = value),
        child: Column(children: [
          Row(children: [
            Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                alignment: Alignment.center,
                child: !_presentationEmail.hasRead
                    ? SvgPicture.asset(_imagePaths.icUnreadStatus, width: 9, height: 9, fit: BoxFit.fill)
                    : SizedBox(width: 9)),
            buildIconWeb(
                icon: SvgPicture.asset(
                    _presentationEmail.hasStarred ? _imagePaths.icStar : _imagePaths.icUnStar,
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill),
                tooltip: _presentationEmail.hasStarred ? AppLocalizations.of(_context).starred : AppLocalizations.of(_context).not_starred,
                onTap: () => _emailActionClick?.call(
                    _presentationEmail.hasStarred ? EmailActionType.unMarkAsStarred : EmailActionType.markAsStarred,
                    _presentationEmail)),
            if (_selectModeAll == SelectMode.INACTIVE) SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_selectModeAll == SelectMode.ACTIVE) {
                  _emailActionClick?.call(EmailActionType.selection, _presentationEmail);
                } else {
                  _emailActionClick?.call(EmailActionType.preview, _presentationEmail);
                }
              },
              child: _buildAvatarIcon(
                  iconSize: 32,
                  textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  paddingIconSelect: EdgeInsets.all(5)),
            ),
            if (_selectModeAll == SelectMode.INACTIVE) SizedBox(width: 10),
            Container(
              width: 160,
              child: _isSearchEnabled
                  ? RichTextBuilder(
                      _getInformationSender(),
                      '${_searchQuery!.value}',
                      TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                      TextStyle(fontSize: 15, color: AppColor.colorNameEmail, backgroundColor: AppColor.bgWordSearch, fontWeight: FontWeight.w600)).build()
                  : Text('${_getInformationSender()}',
                      maxLines: 1,
                      style: TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600)),
            ),
            SizedBox(width: 24),
            Expanded(child: _buildSubjectAndContent()),
            SizedBox(width: 16),
            if (isHoverItem)
              _buildListActionButtonWhenHover()
            else
              _buildDateTimeForDesktopScreen()
          ]),
          if (_selectModeAll == SelectMode.INACTIVE)
            Padding(
                padding: EdgeInsets.only(top: 7.5, bottom: 7.5, left: 70),
                child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
        ]),
      );
    });
  }

  Widget _buildListActionButtonWhenHover() {
    return Row(children: [
      buildIconWeb(
          icon: SvgPicture.asset(
              _presentationEmail.hasRead ? _imagePaths.icRead : _imagePaths.icUnread,
              color: AppColor.colorActionButtonHover,
              width: 16,
              height: 16,
              fit: BoxFit.fill),
          tooltip: _presentationEmail.hasRead ? AppLocalizations.of(_context).mark_as_unread : AppLocalizations.of(_context).mark_as_read,
          onTap: () => _emailActionClick?.call(
              _presentationEmail.hasRead ? EmailActionType.markAsUnread : EmailActionType.markAsRead,
              _presentationEmail)),
      if (_mailboxRole != PresentationMailbox.roleDrafts)
        buildIconWeb(
            icon: SvgPicture.asset(
                _imagePaths.icMove,
                width: 16,
                height: 16,
                color: AppColor.colorActionButtonHover,
                fit: BoxFit.fill),
            tooltip: AppLocalizations.of(_context).move,
            onTap: () => _emailActionClick?.call(EmailActionType.moveToMailbox, _presentationEmail)),
      buildIconWeb(
          icon: SvgPicture.asset(
              _imagePaths.icDelete,
              width: 16,
              height: 16,
              color: AppColor.colorActionButtonHover,
              fit: BoxFit.fill),
          tooltip: _mailboxRole != PresentationMailbox.roleTrash
              ? AppLocalizations.of(_context).move_to_trash
              : AppLocalizations.of(_context).delete_permanently,
          onTap: () => _emailActionClick?.call(
              _mailboxRole != PresentationMailbox.roleTrash ? EmailActionType.moveToTrash : EmailActionType.deletePermanently,
              _presentationEmail)),
      if (_mailboxRole != PresentationMailbox.roleDrafts)
        buildIconWebHasPosition(
            _context,
            icon: SvgPicture.asset(
                _imagePaths.icMore,
                width: 16,
                height: 16,
                color: AppColor.colorActionButtonHover,
                fit: BoxFit.fill),
            tooltip: AppLocalizations.of(_context).more,
            onTap: () {
              if (_responsiveUtils.isMobile(_context)) {
                _onMoreActionClick?.call(_presentationEmail, null);
              }
            },
            onTapDown: (position) {
              if (!_responsiveUtils.isMobile(_context)) {
                _onMoreActionClick?.call(_presentationEmail, position);
              }
            }),
      if (_responsiveUtils.isDesktop(_context)) SizedBox(width: 16),
    ]);
  }

  Widget _buildDateTimeForDesktopScreen() {
    return Row(children: [
      if (_searchStatus == SearchStatus.ACTIVE && _presentationEmail.mailboxName.isNotEmpty)
        Container(
            margin: EdgeInsets.only(left: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            constraints: BoxConstraints(maxWidth: 100),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.backgroundCounterMailboxColor),
            child: Text('${_presentationEmail.mailboxName}',
              maxLines: 1,
              style: TextStyle(fontSize: 10, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
            )
        ),
      if (_presentationEmail.hasAttachment == true)
        Padding(padding: EdgeInsets.only(left: 8),
            child: (ButtonBuilder(_imagePaths.icAttachment)
                ..paddingIcon(EdgeInsets.zero)
                ..size(16))
              .build()),
      Padding(padding: EdgeInsets.only(right: 20, left: 8),
          child: Text('${_presentationEmail.getReceivedAt(Localizations.localeOf(_context).toLanguageTag())}',
              maxLines: 1,
              style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal)))
    ]);
  }

  Widget _buildDateTimeForMobileTabletScreen() {
    return Row(children: [
      if (_presentationEmail.hasAttachment == true)
        Padding(
            padding: EdgeInsets.only(left: 8),
            child: (ButtonBuilder(_imagePaths.icAttachment)
                ..paddingIcon(EdgeInsets.zero)
                ..size(16))
              .build()),
      Padding(
          padding: EdgeInsets.only(right: 4, left: 8),
          child: Text('${_presentationEmail.getReceivedAt(Localizations.localeOf(_context).toLanguageTag())}',
              maxLines: 1,
              style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail))),
      (ButtonBuilder(_imagePaths.icChevron)
          ..paddingIcon(EdgeInsets.zero)
          ..size(16))
        .build()
    ]);
  }

  Widget _buildSubjectAndContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(children: [
        Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
            child: _isSearchEnabled
                ? RichTextBuilder(
                    '${_presentationEmail.getEmailTitle()}',
                    '${_searchQuery!.value}',
                    TextStyle(fontSize: 13, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                    TextStyle(fontSize: 13, backgroundColor: AppColor.bgWordSearch, color: AppColor.colorNameEmail)).build()
                : Text('${_presentationEmail.getEmailTitle()}',
                    maxLines: 1,
                    style: TextStyle(fontSize: 13, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600))
        ),
        if (_presentationEmail.getEmailTitle().isNotEmpty) SizedBox(width: 12),
        Expanded(
            child: Container(
                child: _isSearchEnabled
                    ? RichTextBuilder(
                        '${_presentationEmail.getPartialContent()}',
                        '${_searchQuery!.value}',
                        TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal),
                        TextStyle(fontSize: 13, color: AppColor.colorContentEmail, backgroundColor: AppColor.bgWordSearch)).build()
                    : Text('${_presentationEmail.getPartialContent()}',
                        maxLines: 1,
                        style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal))
            )
        ),
      ]);
    });
  }

  Widget _buildAvatarIcon({
    double? iconSize,
    EdgeInsets? paddingIconSelect,
    TextStyle? textStyle
  }) {
    if (_selectModeAll == SelectMode.ACTIVE) {
      return Tooltip(
          child: Padding(
              padding: EdgeInsets.all(12),
              child: SvgPicture.asset(_presentationEmail.selectMode == SelectMode.ACTIVE ? _imagePaths.icSelected : _imagePaths.icUnSelected, fit: BoxFit.fill)),
          message: AppLocalizations.of(_context).select);
    } else {
      return (AvatarBuilder()
          ..text('${_presentationEmail.getAvatarText()}')
          ..size(iconSize ?? 48)
          ..textColor(Colors.white)
          ..addTextStyle(textStyle)
          ..avatarColor(_presentationEmail.avatarColors))
        .build();
    }
  }

  String _getInformationSender() {
    if (_mailboxRole == PresentationMailbox.roleSent
        || _mailboxRole == PresentationMailbox.roleDrafts
        || _mailboxRole == PresentationMailbox.roleOutbox) {
      return '${_presentationEmail.recipientsName()}';
    }
    return '${_presentationEmail.getSenderName()}';
  }

  bool get _isSearchEnabled => _searchStatus == SearchStatus.ACTIVE
      && _searchQuery != null
      && _searchQuery!.value.isNotEmpty;
}