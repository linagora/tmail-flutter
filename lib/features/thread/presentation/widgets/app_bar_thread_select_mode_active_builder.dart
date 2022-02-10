
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseActionClick = void Function();
typedef OnMarkAsEmailReadActionClick = void Function(List<PresentationEmail> listEmail);
typedef OnRemoveEmailActionClick = void Function(List<PresentationEmail> listEmail);
typedef OnOpenContextMenuActionClick = void Function(List<PresentationEmail> listEmail);
typedef OnOpenPopupMenuActionClick = void Function(List<PresentationEmail> listEmail, RelativeRect position);

class AppBarThreadSelectModeActiveBuilder {
  OnCloseActionClick? _onCloseActionClick;
  OnMarkAsEmailReadActionClick? _onMarkAsEmailReadActionClick;
  // OnRemoveEmailActionClick? _onRemoveEmailActionClick;
  OnOpenContextMenuActionClick? _onOpenContextMenuActionClick;
  OnOpenPopupMenuActionClick? _onOpenPopupMenuActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final List<PresentationEmail> _listEmail;
  final ResponsiveUtils _responsiveUtils;

  AppBarThreadSelectModeActiveBuilder(this._context, this._imagePaths, this._listEmail, this._responsiveUtils);

  void addCloseActionClick(OnCloseActionClick onCloseActionClick) {
    _onCloseActionClick = onCloseActionClick;
  }

  void addOnMarkAsEmailReadActionClick(OnMarkAsEmailReadActionClick onMarkAsEmailReadActionClick) {
    _onMarkAsEmailReadActionClick = onMarkAsEmailReadActionClick;
  }

  // void addRemoveEmailActionClick(OnRemoveEmailActionClick onRemoveEmailActionClick) {
  //   _onRemoveEmailActionClick = onRemoveEmailActionClick;
  // }

  void addOpenContextMenuActionClick(OnOpenContextMenuActionClick onOpenContextMenuActionClick) {
    _onOpenContextMenuActionClick = onOpenContextMenuActionClick;
  }

  void addOnOpenPopupMenuActionClick(OnOpenPopupMenuActionClick onOpenPopupMenuActionClick) {
    _onOpenPopupMenuActionClick = onOpenPopupMenuActionClick;
  }

  Widget build() {
    return Container(
        key: Key('app_bar_thread_select_mode_active'),
        alignment: Alignment.topCenter,
        color: Colors.white,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.only(left: 10, right: 16, top: 10, bottom: 10),
        child: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.zero),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildBackButton(),
                  Expanded(child: _buildCountItemSelected()),
                  _buildListOptionButton(),
                ]
            )
        )
    );
  }

  Widget _buildCountItemSelected() {
    return Padding(
      padding: EdgeInsets.only(left: 12),
      child: Text(
        AppLocalizations.of(_context).count_email_selected(_listEmail.length),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 18, color: AppColor.nameUserColor, fontWeight: FontWeight.w500)));
  }

  Widget _buildBackButton() {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: IconButton(
        color: AppColor.baseTextColor,
        icon: SvgPicture.asset(_imagePaths.icComposerClose, color: AppColor.baseTextColor, fit: BoxFit.fill),
        onPressed: () => {
          if (_onCloseActionClick != null) {
            _onCloseActionClick!()
          }
        }
      ));
  }

  Widget _buildListOptionButton() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IconButton(
          //   key: Key('button_remove_email_selected'),
          //   color: AppColor.baseTextColor,
          //   icon: SvgPicture.asset(_imagePaths.icTrash, color: AppColor.baseTextColor, fit: BoxFit.fill),
          //   onPressed: () => {
          //     if (_onRemoveEmailActionClick != null) {
          //       _onRemoveEmailActionClick!(_listEmail)
          //     }
          //   }),
          Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: IconButton(
              key: Key('button_unread_email_selected'),
              color: AppColor.baseTextColor,
              icon: SvgPicture.asset(_imagePaths.icEyeDisable, color: AppColor.baseTextColor, fit: BoxFit.fill),
              onPressed: () => {
                if (_onMarkAsEmailReadActionClick != null) {
                  _onMarkAsEmailReadActionClick!(_listEmail)
                }
              })),
          GestureDetector(
            key: Key('button_menu_select_email'),
            onTap: () => {
              if (_onOpenContextMenuActionClick != null && _responsiveUtils.isMobile(_context)) {
                _onOpenContextMenuActionClick!(_listEmail)
              }
            },
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(
                _imagePaths.icComposerMenu,
                color: AppColor.baseTextColor,
                width: 24,
                height: 24,
                fit: BoxFit.fill),
            ),
            onTapDown: (detail) {
              if (_onOpenPopupMenuActionClick != null && !_responsiveUtils.isMobile(_context)) {
                final screenSize = MediaQuery.of(_context).size;
                final offset = detail.globalPosition;
                final position = RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy,
                  screenSize.width - offset.dx,
                  screenSize.height - offset.dy,
                );
                _onOpenPopupMenuActionClick!(_listEmail, position);
              }
            })
        ]
    );
  }
}