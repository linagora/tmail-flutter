
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/setting/presentation/model/app_setting.dart';
import 'package:tmail_ui_user/features/setting/presentation/model/reading_pane.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnBackActionClick = void Function();
typedef OnEmailActionClick = void Function(PresentationEmail, EmailActionType);
typedef OnMoreActionClick = void Function(PresentationEmail, RelativeRect?);

class AppBarMailWidgetBuilder {
  OnBackActionClick? _onBackActionClick;
  OnEmailActionClick? _onEmailActionClick;
  OnMoreActionClick? _onMoreActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationEmail? _presentationEmail;
  final PresentationMailbox? _currentMailbox;

  AppBarMailWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationEmail,
    this._currentMailbox,
  );

  void onBackActionClick(OnBackActionClick onBackActionClick) {
    _onBackActionClick = onBackActionClick;
  }

  void addOnEmailActionClick(OnEmailActionClick onEmailActionClick) {
    _onEmailActionClick = onEmailActionClick;
  }

  void addOnMoreActionClick(OnMoreActionClick onMoreActionClick) {
    _onMoreActionClick = onMoreActionClick;
  }

  Widget build() {
    return Container(
      key: Key('app_bar_messenger_widget'),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_conditionShow(_context))
              _buildBackButton(),
            if (_conditionShow(_context))
              Expanded(child: _buildMailboxName()),
            if (_presentationEmail != null) _buildListOptionButton(),
          ]
        )
      )
    );
  }

  bool _conditionShow(BuildContext context) {
    if (AppSetting.readingPane == ReadingPane.rightOfInbox
        && (_responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context))) {
      return false;
    } else {
      return true;
    }
  }

  Widget _buildBackButton() {
    return buildIconWeb(
        icon: SvgPicture.asset(_imagePaths.icBack, width: 18, height: 18, color: AppColor.colorTextButton, fit: BoxFit.fill),
        tooltip: AppLocalizations.of(_context).back,
        onTap: () => _onBackActionClick?.call()
    );
  }

  Widget _buildMailboxName() {
    return Transform(
      transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
      child: Text(
        '${_currentMailbox?.name?.name.capitalizeFirstEach ?? ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 17, color: AppColor.colorTextButton))
    );
  }

  Widget _buildListOptionButton() {
    return Row(
      children: [
        buildIconWeb(
            icon: SvgPicture.asset(_imagePaths.icMoveEmail, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(_context).move_to_mailbox,
            onTap: () {
              if (_presentationEmail != null) {
                _onEmailActionClick?.call(_presentationEmail!, EmailActionType.move);
              }
            }),
        buildIconWeb(
          icon: SvgPicture.asset((_presentationEmail != null && _presentationEmail!.isFlaggedEmail()) ? _imagePaths.icStar : _imagePaths.icUnStar, fit: BoxFit.fill),
          tooltip: (_presentationEmail != null && _presentationEmail!.isFlaggedEmail())
            ? AppLocalizations.of(_context).mark_as_unstar
            : AppLocalizations.of(_context).mark_as_star,
          onTap: () {
            if (_presentationEmail != null) {
              _onEmailActionClick?.call(_presentationEmail!, _presentationEmail!.isFlaggedEmail() ? EmailActionType.markAsUnStar : EmailActionType.markAsStar);
            }
          }),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 16),
          child: buildIconWebHasPosition(
              _context,
              tooltip: AppLocalizations.of(_context).more,
              icon: SvgPicture.asset(_imagePaths.icMore, fit: BoxFit.fill),
              onTap: () {
                if (_presentationEmail != null && _responsiveUtils.isMobile(_context)) {
                  _onMoreActionClick?.call(_presentationEmail!, null);
                }
              },
              onTapDown: (position) {
                if (_presentationEmail != null && !_responsiveUtils.isMobile(_context)) {
                  _onMoreActionClick?.call(_presentationEmail!, position);
                }
              })),
      ]
    );
  }
}