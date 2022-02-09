
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

typedef OnBackActionClick = void Function();
typedef OnUnreadEmailActionClick = void Function(PresentationEmail presentationEmail);
typedef OnMoveToMailboxActionClick = void Function(PresentationEmail presentationEmail);
typedef OnMarkAsStarActionClick = void Function(PresentationEmail presentationEmail);

class AppBarMailWidgetBuilder {
  OnBackActionClick? _onBackActionClick;
  OnUnreadEmailActionClick? _onUnreadEmailActionClick;
  OnMoveToMailboxActionClick? _onMoveToMailboxActionClick;
  OnMarkAsStarActionClick? _markAsStarActionClick;

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final PresentationEmail? _presentationEmail;

  AppBarMailWidgetBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationEmail,
  );

  void onBackActionClick(OnBackActionClick onBackActionClick) {
    _onBackActionClick = onBackActionClick;
  }

  void onUnreadEmailActionClick(OnUnreadEmailActionClick onUnreadEmailActionClick) {
    _onUnreadEmailActionClick = onUnreadEmailActionClick;
  }

  void addOnMoveToMailboxActionClick(OnMoveToMailboxActionClick onMoveToMailboxActionClick) {
    _onMoveToMailboxActionClick = onMoveToMailboxActionClick;
  }

  void addOnMarkAsStarActionClick(OnMarkAsStarActionClick onMarkAsStarActionClick) {
    _markAsStarActionClick = onMarkAsStarActionClick;
  }

  Widget build() {
    return Container(
      key: Key('app_bar_messenger_widget'),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if ((!_responsiveUtils.isDesktop(_context) && !_responsiveUtils.isTabletLarge(_context))
                || Get.currentRoute != AppRoutes.MAILBOX_DASHBOARD)
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children:[_buildBackButton()])),
            if (_presentationEmail != null) _buildListOptionButton(),
          ]
        )
      )
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      color: AppColor.appColor,
      icon: SvgPicture.asset(_imagePaths.icBack, color: AppColor.appColor, fit: BoxFit.fill),
      onPressed: () {
        if (_onBackActionClick != null) {
          _onBackActionClick!();
        }
      }
    );
  }

  Widget _buildListOptionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // IconButton(
        //   color: AppColor.baseTextColor,
        //   icon: SvgPicture.asset(_imagePaths.icTrash, color: AppColor.baseTextColor, fit: BoxFit.fill),
        //   onPressed: () {
        //     if (_onBackActionClick != null) {
        //       _onBackActionClick!();
        //     }
        //   }),
        IconButton(
          key: Key('button_mark_as_star_email'),
          icon: SvgPicture.asset(
              (_presentationEmail != null && _presentationEmail!.isFlaggedEmail())
                  ? _imagePaths.icStar
                  : _imagePaths.icUnStar,
              fit: BoxFit.fill),
          onPressed: () {
            if (_markAsStarActionClick != null && _presentationEmail != null) {
              _markAsStarActionClick!(_presentationEmail!);
            }
          }),
        IconButton(
          key: Key('button_mark_as_unread_email'),
          color: AppColor.baseTextColor,
          icon: SvgPicture.asset(_imagePaths.icUnreadEmail, fit: BoxFit.fill),
          onPressed: () {
            if (_onUnreadEmailActionClick != null && _presentationEmail != null && _presentationEmail!.isReadEmail()) {
              _onUnreadEmailActionClick!(_presentationEmail!);
            }
          }),
        IconButton(
          key: Key('button_move_to_mailbox_email'),
          color: AppColor.baseTextColor,
          icon: SvgPicture.asset(_imagePaths.icMoveEmail, fit: BoxFit.fill),
          onPressed: () {
            if (_onMoveToMailboxActionClick != null && _presentationEmail != null) {
              _onMoveToMailboxActionClick!(_presentationEmail!);
            }
          }),
      ]
    );
  }
}