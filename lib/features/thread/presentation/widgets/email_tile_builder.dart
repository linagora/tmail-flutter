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
  bool isHoverItemSelected = false;

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
      key: const Key('thread_tile'),
      data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: _wrapContainerForTile(_buildListTile()),
        desktop: _wrapContainerForTile(_buildListTileForDesktop()),
      )
    );
  }

  Widget _wrapContainerForTile(Widget tile) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
      child: tile);
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
          child: Container(
              width: 56,
              height: 56,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: _buildAvatarIcon()),
        ),
        title: Row(
          children: [
            if (!_presentationEmail.hasRead)
              Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: SvgPicture.asset(_imagePaths.icUnreadStatus, width: 9, height: 9, fit: BoxFit.fill)),
            Expanded(
                child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                    ? RichTextBuilder(
                        _getInformationSender(),
                        _searchQuery!.value,
                        const TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                        TextStyle(fontSize: 15, color: _buildTextColorForReadEmail(), backgroundColor: AppColor.bgWordSearch, fontWeight: _buildFontForReadEmail())).build()
                    : Text(
                        _getInformationSender(),
                        maxLines: 1,
                        overflow:TextOverflow.ellipsis,
                        style:  TextStyle(fontSize: 15, color: _buildTextColorForReadEmail(), fontWeight: _buildFontForReadEmail()))
            ),
            if (_presentationEmail.hasAttachment == true)
              Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SvgPicture.asset(_imagePaths.icAttachment, width: 16, height: 16, fit: BoxFit.fill)),
            Padding(
                padding: const EdgeInsets.only(right: 4, left: 8),
                child: Text(
                    _presentationEmail.getReceivedAt(Localizations.localeOf(_context).toLanguageTag()),
                    maxLines: 1,
                    overflow:TextOverflow.ellipsis,
                    style:  TextStyle(fontSize: 13, color: _buildTextColorForReadEmail(), fontWeight: _buildFontForReadEmail()))),
            SvgPicture.asset(_imagePaths.icChevron, width: 16, height: 16, fit: BoxFit.fill),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                        ? RichTextBuilder(
                            _presentationEmail.getEmailTitle(),
                            _searchQuery!.value,
                             TextStyle(fontSize: 13, color: _buildTextColorForReadEmail(), fontWeight: _buildFontForReadEmail()),
                             TextStyle(fontSize: 13, backgroundColor: AppColor.bgWordSearch, color: _buildTextColorForReadEmail(), fontWeight: _buildFontForReadEmail())).build()
                        : Text(
                            _presentationEmail.getEmailTitle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:  TextStyle(fontSize: 13, color: _buildTextColorForReadEmail(), fontWeight: _buildFontForReadEmail()))
                    ),
                    if (_searchStatus == SearchStatus.ACTIVE && _presentationEmail.mailboxName.isNotEmpty)
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                          constraints: const BoxConstraints(maxWidth: 100),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.backgroundCounterMailboxColor),
                          child: Text(
                            _presentationEmail.mailboxName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
                          )
                      ),
                    if (_presentationEmail.hasStarred)
                      SvgPicture.asset(_imagePaths.icStar, width: 15, height: 15, fit: BoxFit.fill)
                  ],
                )),
            Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(children: [
                  Expanded(child: _searchStatus == SearchStatus.ACTIVE && _searchQuery != null && _searchQuery!.value.isNotEmpty
                      ? RichTextBuilder(
                          _presentationEmail.getPartialContent(),
                          _searchQuery!.value,
                          const TextStyle(fontSize: 13, color: AppColor.colorContentEmail),
                          const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, backgroundColor: AppColor.bgWordSearch)).build()
                      : Text(
                          _presentationEmail.getPartialContent(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail))
                  ),
                ])
            ),
          ],
        ),
      ),
      const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
    ]);
  }

  Widget _buildListTileForDesktop() {
    return GestureDetector(
      onTap: () => _emailActionClick?.call(EmailActionType.preview, _presentationEmail),
      onLongPress: () => _emailActionClick?.call(EmailActionType.selection, _presentationEmail),
      child: Column(children: [
        Row(children: [
          Container(
              alignment: Alignment.center,
              child: !_presentationEmail.hasRead
                  ? SvgPicture.asset(_imagePaths.icUnreadStatus, width: 9, height: 9, fit: BoxFit.fill)
                  : const SizedBox(width: 9)),
          buildIconWeb(
              icon: SvgPicture.asset(
                  _presentationEmail.hasStarred ? _imagePaths.icStar : _imagePaths.icUnStar,
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill),
              tooltip: _presentationEmail.hasStarred ? AppLocalizations.of(_context).starred : AppLocalizations.of(_context).not_starred,
              onTap: () => _emailActionClick?.call(
                  _presentationEmail.hasStarred ?  EmailActionType.unMarkAsStarred :  EmailActionType.markAsStarred,
                  _presentationEmail)),
          GestureDetector(
            onTap: () => _emailActionClick?.call(
                _selectModeAll == SelectMode.ACTIVE ? EmailActionType.selection : EmailActionType.preview,
                _presentationEmail),
            child: Container(
                width: 40,
                height: 56,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: _buildAvatarIcon(
                  iconSize: 40,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: _isSearchEnabled
              ? RichTextBuilder(
                  _getInformationSender(),
                  _searchQuery!.value,
                  const TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                  const TextStyle(fontSize: 15, color: AppColor.colorNameEmail, backgroundColor: AppColor.bgWordSearch, fontWeight: FontWeight.w600)).build()
              : Text(_getInformationSender(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 24),
          Expanded(child: _buildSubjectAndContent()),
          const SizedBox(width: 16),
          if (_searchStatus == SearchStatus.ACTIVE && _presentationEmail.mailboxName.isNotEmpty)
            Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                constraints: const BoxConstraints(maxWidth: 80),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColor.backgroundCounterMailboxColor),
                child: Text(_presentationEmail.mailboxName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
                )
            ),
          if (_presentationEmail.hasAttachment == true)
            Padding(padding: const EdgeInsets.only(left: 8),
                child: SvgPicture.asset(_imagePaths.icAttachment, width: 16, height: 16, fit: BoxFit.fill)),
          Padding(
              padding: const EdgeInsets.only(right: 20, left: 8),
              child: Text(_presentationEmail.getReceivedAt(Localizations.localeOf(_context).toLanguageTag()),
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal))),
        ]),
        if (_selectModeAll == SelectMode.INACTIVE)
          const Padding(
              padding: EdgeInsets.only(left: 85),
              child: Divider(color: AppColor.lineItemListColor, height: 1, thickness: 0.2)),
      ]),
    );
  }

  Widget _buildSubjectAndContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(children: [
        Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
            child: _isSearchEnabled
                ? RichTextBuilder(
                    _presentationEmail.getEmailTitle(),
                    _searchQuery!.value,
                    const TextStyle(fontSize: 13, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600),
                    const TextStyle(fontSize: 13, backgroundColor: AppColor.bgWordSearch, color: AppColor.colorNameEmail)).build()
                : Text(_presentationEmail.getEmailTitle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColor.colorNameEmail, fontWeight: FontWeight.w600))
        ),
        if (_presentationEmail.getEmailTitle().isNotEmpty) const SizedBox(width: 12),
        Expanded(
          child: Container(
            child: _isSearchEnabled
              ? RichTextBuilder(
                  _presentationEmail.getPartialContent(),
                  _searchQuery!.value,
                  const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal),
                  const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, backgroundColor: AppColor.bgWordSearch)).build()
              : Text(_presentationEmail.getPartialContent(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColor.colorContentEmail, fontWeight: FontWeight.normal))
          )
        ),
      ]);
    });
  }

  Widget _buildAvatarIcon({
    double? iconSize,
    TextStyle? textStyle
  }) {
    if (_selectModeAll == SelectMode.ACTIVE) {
      return Container(
        alignment: Alignment.center,
        child: SvgPicture.asset(
          _presentationEmail.selectMode == SelectMode.ACTIVE
              ? _imagePaths.icSelected
              : _imagePaths.icUnSelected,
          width: 24, height: 24));
    } else {
      return Container(
          width: iconSize ?? 56,
          height: iconSize ?? 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular((iconSize ?? 56) * 0.5),
              border: Border.all(color: Colors.transparent),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 1.0],
                  colors: _presentationEmail.avatarColors),
              color: AppColor.avatarColor
          ),
          child: Text(
              _presentationEmail.getAvatarText(),
              style: textStyle ?? const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)
          )
      );
    }
  }

  FontWeight _buildFontForReadEmail() {
    if (!_presentationEmail.hasRead) return FontWeight.w600;
    return FontWeight.normal;
  }

  Color _buildTextColorForReadEmail() {
    if (_presentationEmail.hasRead) return AppColor.colorContentEmail;
    return AppColor.colorNameEmail;
  }

  String _getInformationSender() {
    if (_mailboxRole == PresentationMailbox.roleSent
        || _mailboxRole == PresentationMailbox.roleDrafts
        || _mailboxRole == PresentationMailbox.roleOutbox) {
      return _presentationEmail.recipientsName();
    }
    return _presentationEmail.getSenderName();
  }

  bool get _isSearchEnabled => _searchStatus == SearchStatus.ACTIVE
      && _searchQuery != null
      && _searchQuery!.value.isNotEmpty;
}