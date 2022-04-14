import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnOpenEmailActionClick = void Function(PresentationEmail selectedEmail);
typedef OnSelectEmailActionClick = void Function(PresentationEmail selectedEmail);
typedef OnMarkAsStarActionClick = void Function(PresentationEmail selectedEmail);

class EmailTileBuilder {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  final PresentationEmail _presentationEmail;
  final BuildContext _context;
  final SelectMode _selectModeAll;
  final Role? _mailboxRole;
  final SearchStatus _searchStatus;
  final SearchQuery? _searchQuery;

  OnOpenEmailActionClick? _onOpenEmailActionClick;
  OnSelectEmailActionClick? _onSelectEmailActionClick;
  OnMarkAsStarActionClick? _onMarkAsStarActionClick;

  EmailTileBuilder(
    this._context,
    this._presentationEmail,
    this._mailboxRole,
    this._selectModeAll,
    this._searchStatus,
    this._searchQuery,
  );

  void onOpenEmailAction(OnOpenEmailActionClick onOpenEmailActionClick) {
    _onOpenEmailActionClick = onOpenEmailActionClick;
  }

  void onSelectEmailAction(OnSelectEmailActionClick onSelectEmailActionClick) {
    _onSelectEmailActionClick = onSelectEmailActionClick;
  }

  void addOnMarkAsStarActionClick(OnMarkAsStarActionClick onMarkAsStarActionClick) {
    _onMarkAsStarActionClick = onMarkAsStarActionClick;
  }

  Widget build() {
    return Theme(
      key: Key('thread_tile'),
      data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: _buildListTile(),
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
    return Container(
        margin: kIsWeb && _selectModeAll == SelectMode.ACTIVE
            ? EdgeInsets.only(top: 3, left: 16, right: 16)
            : EdgeInsets.zero,
        padding: kIsWeb && _selectModeAll == SelectMode.ACTIVE
            ? EdgeInsets.only(top: 8, bottom: 16, right: 8)
            : EdgeInsets.only(bottom: 10, left: 16, right: 16),
        decoration: kIsWeb && _selectModeAll == SelectMode.ACTIVE && _presentationEmail.selectMode == SelectMode.ACTIVE
            ? BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppColor.colorItemEmailSelectedDesktop)
            : BoxDecoration(borderRadius: BorderRadius.circular(0), color: Colors.white),
        alignment: Alignment.center,
        child: Column(children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => _onOpenEmailActionClick?.call(_presentationEmail),
            onLongPress: () => _onSelectEmailActionClick!.call(_presentationEmail),
            leading: GestureDetector(
              onTap: () {
                if (_selectModeAll == SelectMode.ACTIVE) {
                  _onSelectEmailActionClick?.call(_presentationEmail);
                } else {
                  _onOpenEmailActionClick?.call(_presentationEmail);
                }
              },
              child: _buildAvatarIcon(),
            ),
            title: Transform(
                transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                child: Row(
                  children: [
                    if (_presentationEmail.isUnReadEmail())
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
                                overflow:TextOverflow.ellipsis,
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
                            overflow:TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail))),
                    (ButtonBuilder(_imagePaths.icChevron)
                        ..paddingIcon(EdgeInsets.zero)
                        ..size(16))
                      .build(),
                  ],
                )
            ),
            subtitle: Transform(
                transform: Matrix4.translationValues(0.0, 8.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                    overflow: TextOverflow.ellipsis,
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
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
                                  )
                              ),
                            if (_presentationEmail.isFlaggedEmail() )
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
                                  overflow:TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail))
                          ),
                        ])),
                    if (kIsWeb && _selectModeAll == SelectMode.INACTIVE)
                      Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
                  ],
                )
            ),
          ),
          if (!kIsWeb)
            Padding(
                padding: EdgeInsets.only(top: 12, right: 12),
                child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
        ]),
    );
  }

  Widget _buildListTileForDesktop() {
    return InkWell(
      onTap: () => _onOpenEmailActionClick?.call(_presentationEmail),
      onLongPress: () => _onSelectEmailActionClick?.call(_presentationEmail),
      child: Column(children: [
        Row(children: [
          Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              alignment: Alignment.center,
              child: _presentationEmail.isUnReadEmail()
                  ? SvgPicture.asset(_imagePaths.icUnreadStatus, width: 9, height: 9, fit: BoxFit.fill)
                  : SizedBox(width: 9)),
          buildIconWeb(
              icon: SvgPicture.asset(
                  _presentationEmail.isFlaggedEmail() ? _imagePaths.icStar : _imagePaths.icUnStar,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill),
              tooltip: _presentationEmail.isFlaggedEmail() ? AppLocalizations.of(_context).starred : AppLocalizations.of(_context).not_starred,
              onTap: () => _onMarkAsStarActionClick?.call(_presentationEmail)),
          if (_selectModeAll == SelectMode.INACTIVE) SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_selectModeAll == SelectMode.ACTIVE) {
                _onSelectEmailActionClick?.call(_presentationEmail);
              } else {
                _onOpenEmailActionClick?.call(_presentationEmail);
              }
            },
            child: _buildAvatarIcon(
                iconSize: 32,
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                paddingIconSelect: EdgeInsets.all(5)),
          ),
          if (_selectModeAll == SelectMode.INACTIVE) SizedBox(width: 10),
          Container(width: 180, child: _isSearchEnabled
            ? RichTextBuilder(
                _getInformationSender(),
                '${_searchQuery!.value}',
                TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                TextStyle(fontSize: 15, color: AppColor.colorNameEmail, backgroundColor: AppColor.bgWordSearch, fontWeight: FontWeight.w600)).build()
            : Text('${_getInformationSender()}',
                maxLines: 1,
                style: TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600)),
          ),
          SizedBox(width: 10),
          Expanded(child: _buildSubjectAndContent()),
          SizedBox(width: 10),
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
                style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal))),
        ]),
        if (_selectModeAll == SelectMode.INACTIVE)
          Padding(
              padding: EdgeInsets.only(top: 7.5, bottom: 7.5, left: 70),
              child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
      ]),
    );
  }

  Widget _buildSubjectAndContent() {
    return LayoutBuilder(builder: (context, constraints) {
      log('EmailTileBuilder::_buildSubjectAndContent(): maxWidth(Subject+Content): ${constraints.maxWidth}');
      return Row(
        children: [
          Flexible(
            child: Container(
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
            )
          ),
          if (_presentationEmail.getEmailTitle().isNotEmpty) SizedBox(width: 12),
          Expanded(child: _isSearchEnabled
              ? RichTextBuilder(
                  '${_presentationEmail.getPartialContent()}',
                  '${_searchQuery!.value}',
                  TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal),
                  TextStyle(fontSize: 13, color: AppColor.colorContentEmail, backgroundColor: AppColor.bgWordSearch)).build()
              : Text('${_presentationEmail.getPartialContent()}',
                  maxLines: 1,
                  style: TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal))),
        ]
      );
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
          ..size(iconSize ?? (GetPlatform.isWeb ? 48 : 56))
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

  bool get _isSearchEnabled => _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty;
}