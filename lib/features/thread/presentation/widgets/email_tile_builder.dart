import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/base_email_item_tile.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';

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

  void addOnMoreActionClick(OnMoreActionClick onMoreActionClick) {}

  Widget build() {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          ListTile(
            contentPadding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            onTap: () => _emailActionClick?.call(
                EmailActionType.preview,
                _presentationEmail),
            onLongPress: () => _emailActionClick?.call(
                EmailActionType.selection,
                _presentationEmail),
            leading: GestureDetector(
              onTap: () => _emailActionClick?.call(
                  _selectModeAll == SelectMode.ACTIVE
                      ? EmailActionType.selection
                      : EmailActionType.preview,
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
                      child: SvgPicture.asset(
                          imagePaths.icUnreadStatus,
                          width: 9,
                          height: 9,
                          fit: BoxFit.fill)),
                Expanded(child: buildInformationSender(
                    _presentationEmail,
                    mailboxCurrent,
                    _searchStatus,
                    advancedSearchActivated,
                    _searchQuery)),
                if (_presentationEmail.hasAttachment == true)
                  Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: buildIconAttachment()),
                Padding(
                    padding: const EdgeInsets.only(right: 4, left: 8),
                    child: buildDateTime(_context, _presentationEmail)),
                buildIconChevron(),
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
                        Expanded(child: buildEmailTitle(
                            _presentationEmail,
                            _searchStatus,
                            advancedSearchActivated,
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
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(children: [
                      Expanded(child: buildEmailPartialContent(
                          _presentationEmail,
                          _searchStatus,
                          advancedSearchActivated,
                          _searchQuery)),
                    ])
                ),
              ],
            ),
          ),
          Padding(
            padding: paddingDivider ?? const EdgeInsets.symmetric(horizontal: 16),
            child: const Divider(
                color: AppColor.lineItemListColor,
                height: 1,
                thickness: 0.2)),
        ],
      ),
    );
  }

  Widget _buildAvatarIcon() {
    if (_selectModeAll == SelectMode.ACTIVE) {
      return buildIconAvatarSelection(_context, _presentationEmail);
    } else {
      return buildIconAvatarText(_presentationEmail);
    }
  }
}