
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnBackActionClick = void Function();
typedef OnEmailActionClick = void Function(PresentationEmail, EmailActionType);
typedef OnMoreActionClick = void Function(PresentationEmail, RelativeRect?);

class AppBarMailWidgetBuilder extends StatelessWidget {
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final PresentationEmail? _presentationEmail;
  final PresentationMailbox? _currentMailbox;
  final OnBackActionClick? onBackActionClick;
  final OnEmailActionClick? onEmailActionClick;
  final OnMoreActionClick? onMoreActionClick;

  AppBarMailWidgetBuilder(
    this._presentationEmail,
    this._currentMailbox,
    {
      Key? key,
      this.onBackActionClick,
      this.onEmailActionClick,
      this.onMoreActionClick
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('app_bar_messenger_widget'),
      alignment: Alignment.center,
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 8),
      child: Row(children: [
        if (_responsiveUtils.mailboxDashboardHasMailboxAndEmailView(context))
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onBackActionClick?.call(),
              borderRadius: BorderRadius.circular(15),
              child: Tooltip(
                message: AppLocalizations.of(context).back,
                child: Container(
                  color: Colors.transparent,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SvgPicture.asset(
                        _imagePaths.icBack,
                        width: 18,
                        height: 18,
                        color: AppColor.colorTextButton,
                        fit: BoxFit.fill),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      constraints: BoxConstraints(
                          maxWidth: _responsiveUtils.getSizeScreenWidth(context) - 250),
                      child: Text(
                          _currentMailbox?.name?.name.capitalizeFirstEach ?? '',
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          style: const TextStyle(fontSize: 17, color: AppColor.colorTextButton)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        const Spacer(),
        if (_presentationEmail != null) _buildListOptionButton(context),
      ])
    );
  }

  Widget _buildListOptionButton(BuildContext context) {
    return Row(
      children: [
        buildIconWeb(
            icon: SvgPicture.asset(_imagePaths.icMoveEmail, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).move_message,
            onTap: () => onEmailActionClick?.call(
                _presentationEmail!,
                EmailActionType.moveToMailbox)),
        buildIconWeb(
          icon: SvgPicture.asset(
              _presentationEmail!.hasStarred
                ? _imagePaths.icStar
                : _imagePaths.icUnStar,
              fit: BoxFit.fill),
          tooltip: _presentationEmail!.hasStarred
              ? AppLocalizations.of(context).not_starred
              : AppLocalizations.of(context).mark_as_starred,
          onTap: () => onEmailActionClick?.call(_presentationEmail!,
              _presentationEmail!.hasStarred
                  ? EmailActionType.unMarkAsStarred
                  : EmailActionType.markAsStarred)),
        buildIconWeb(
            icon: SvgPicture.asset(_imagePaths.icDeleteEmail, fit: BoxFit.fill),
            tooltip: _currentMailbox?.role != PresentationMailbox.roleTrash
                ? AppLocalizations.of(context).move_to_trash
                : AppLocalizations.of(context).delete_permanently,
            onTap: () {
              if (_currentMailbox?.role != PresentationMailbox.roleTrash) {
                onEmailActionClick?.call(
                    _presentationEmail!,
                    EmailActionType.moveToTrash);
              } else {
                onEmailActionClick?.call(
                    _presentationEmail!,
                    EmailActionType.deletePermanently);
              }
            }),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 16),
          child: buildIconWebHasPosition(
            context,
            tooltip: AppLocalizations.of(context).more,
            icon: SvgPicture.asset(_imagePaths.icMore, fit: BoxFit.fill),
            onTap: () {
              if (_presentationEmail != null && _responsiveUtils.isMobile(context)) {
                onMoreActionClick?.call(_presentationEmail!, null);
              }
            },
            onTapDown: (position) {
              if (_presentationEmail != null && !_responsiveUtils.isMobile(context)) {
                onMoreActionClick?.call(_presentationEmail!, position);
              }
            }
          )
        ),
      ]
    );
  }
}