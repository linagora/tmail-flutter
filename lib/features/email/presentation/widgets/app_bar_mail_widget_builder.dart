
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if ((!_responsiveUtils.isDesktop(_context) && !_responsiveUtils.isTabletLarge(_context)))
              _buildBackButton(),
            if ((!_responsiveUtils.isDesktop(_context) && !_responsiveUtils.isTabletLarge(_context)))
              Expanded(child: _buildMailboxName()),
            if (_presentationEmail != null) _buildListOptionButton(),
          ]
        )
      )
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: SvgPicture.asset(_imagePaths.icBack, width: 20, height: 20, color: AppColor.colorTextButton, fit: BoxFit.fill),
      onPressed: () => _onBackActionClick?.call()
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            key: Key('button_move_to_mailbox_email'),
            icon: SvgPicture.asset(_imagePaths.icMoveEmail, color: AppColor.colorButton, fit: BoxFit.fill),
            onPressed: () {
              if (_presentationEmail != null) {
                _onEmailActionClick?.call(_presentationEmail!, EmailActionType.move);
              }
            }),
        IconButton(
          key: Key('button_mark_as_star_email'),
          icon: SvgPicture.asset(
              (_presentationEmail != null && _presentationEmail!.isFlaggedEmail())
                  ? _imagePaths.icStar
                  : _imagePaths.icUnStar,
              color: AppColor.colorButton,
              fit: BoxFit.fill),
          onPressed: ()  {
            if (_presentationEmail != null) {
              _onEmailActionClick?.call(_presentationEmail!,
                  _presentationEmail!.isFlaggedEmail() ? EmailActionType.markAsUnStar : EmailActionType.markAsStar);
            }
          }),
        IconButton(
          key: Key('button_delete_email'),
          icon: SvgPicture.asset(_imagePaths.icDeleteEmail, color: AppColor.colorButton, fit: BoxFit.fill),
          onPressed: () {
            if (_presentationEmail != null) {
              _onEmailActionClick?.call(_presentationEmail!, EmailActionType.delete);
            }
          }),
        _buildMoreButton(),
      ]
    );
  }

  Widget _buildMoreButton() {
    return Material(
        key: Key('button_more_email'),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Padding(
            padding: EdgeInsets.only(left: 10, right: 16),
            child: GestureDetector(
                onTap: () {
                  if (_presentationEmail != null && _responsiveUtils.isMobileDevice(_context)) {
                    _onMoreActionClick?.call(_presentationEmail!, null);
                  }
                },
                child: SvgPicture.asset(_imagePaths.icMore, color: AppColor.colorButton, fit: BoxFit.fill),
                onTapDown: (detail) {
                  if (_presentationEmail != null && !_responsiveUtils.isMobileDevice(_context)) {
                    final screenSize = MediaQuery.of(_context).size;
                    final offset = detail.globalPosition;
                    final position = RelativeRect.fromLTRB(
                      offset.dx,
                      offset.dy,
                      screenSize.width - offset.dx,
                      screenSize.height - offset.dy,
                    );
                    _onMoreActionClick?.call(_presentationEmail!, position);
                  }
                })
        )
    );
  }
}