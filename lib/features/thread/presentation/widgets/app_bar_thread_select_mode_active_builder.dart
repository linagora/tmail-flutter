
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseActionClick = void Function();
typedef OnMarkAsEmailReadActionClick = void Function(List<PresentationEmail> listEmail);
typedef OnRemoveEmailActionClick = void Function(List<PresentationEmail> listEmail);
typedef OnOpenContextMenuActionClick = void Function(List<PresentationEmail> listEmail);

class AppBarThreadSelectModeActiveBuilder {
  OnCloseActionClick? _onCloseActionClick;
  OnMarkAsEmailReadActionClick? _onMarkAsEmailReadActionClick;
  OnRemoveEmailActionClick? _onRemoveEmailActionClick;
  OnOpenContextMenuActionClick? _onOpenContextMenuActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final List<PresentationEmail> _listEmail;

  AppBarThreadSelectModeActiveBuilder(this._context, this._imagePaths, this._listEmail);

  void addCloseActionClick(OnCloseActionClick onCloseActionClick) {
    _onCloseActionClick = onCloseActionClick;
  }

  void addOnMarkAsEmailReadActionClick(OnMarkAsEmailReadActionClick onMarkAsEmailReadActionClick) {
    _onMarkAsEmailReadActionClick = onMarkAsEmailReadActionClick;
  }

  void addRemoveEmailActionClick(OnRemoveEmailActionClick onRemoveEmailActionClick) {
    _onRemoveEmailActionClick = onRemoveEmailActionClick;
  }

  void addOpenContextMenuActionClick(OnOpenContextMenuActionClick onOpenContextMenuActionClick) {
    _onOpenContextMenuActionClick = onOpenContextMenuActionClick;
  }

  Widget build() {
    return Container(
        key: Key('app_bar_thread_select_mode_active'),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
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
    return ButtonBuilder(_imagePaths.icComposerClose)
      .padding(5)
      .size(30)
      .onPressActionClick(() {
        if (_onCloseActionClick != null) {
          _onCloseActionClick!();
        }})
      .build();
  }

  Widget _buildListOptionButton() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ButtonBuilder(_imagePaths.icTrash).key(Key('button_remove_email_selected'))
            .onPressActionClick(() {
              if (_onRemoveEmailActionClick != null) {
                _onRemoveEmailActionClick!(_listEmail);
              }})
            .build(),
          SizedBox(width: 10),
          ButtonBuilder(_imagePaths.icEyeDisable).key(Key('button_unread_email_selected'))
            .onPressActionClick(() {
              if (_onMarkAsEmailReadActionClick != null) {
                _onMarkAsEmailReadActionClick!(_listEmail);
              }})
            .build(),
          SizedBox(width: 10),
          ButtonBuilder(_imagePaths.icComposerMenu).key(Key('button_menu_select_email'))
            .onPressActionClick(() {
              if (_onOpenContextMenuActionClick != null) {
                _onOpenContextMenuActionClick!(_listEmail);
              }})
            .build(),
        ]
    );
  }
}