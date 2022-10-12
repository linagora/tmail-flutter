import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnPressEmailActionClick = void Function(EmailActionType emailActionType);

class BottomBarMailWidgetBuilder extends StatelessWidget {

  static const double maxWidthBottomBar = 540;

  final PresentationEmail _presentationEmail;
  final OnPressEmailActionClick? onPressEmailActionClick;

  const BottomBarMailWidgetBuilder(
    this._presentationEmail,
    {
      Key? key,
      this.onPressEmailActionClick
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    final responsiveUtils = Get.find<ResponsiveUtils>();

    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_presentationEmail.numberOfAllEmailAddress() > 1)
              Expanded(child: (ButtonBuilder(imagePaths.icReplyAll)
                ..key(const Key('button_reply_all_message'))
                ..size(15)
                ..radiusSplash(0)
                ..padding(const EdgeInsets.only(top: 5, bottom: 8))
                ..textStyle(TextStyle(
                    fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                    color: AppColor.colorTextButton))
                ..onPressActionClick(() =>onPressEmailActionClick?.call(EmailActionType.replyAll))
                ..text(AppLocalizations.of(context).reply_all,
                    isVertical: responsiveUtils.isPortraitMobile(context)))
              .build()),
            Expanded(child: (ButtonBuilder(imagePaths.icReply)
              ..key(const Key('button_reply_message'))
              ..size(20)
              ..radiusSplash(0)
              ..padding(const EdgeInsets.only(top: 5, bottom: 8))
              ..textStyle(TextStyle(
                  fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                  color: AppColor.colorTextButton))
              ..onPressActionClick(() => onPressEmailActionClick?.call(EmailActionType.reply))
              ..text(AppLocalizations.of(context).reply,
                  isVertical: responsiveUtils.isPortraitMobile(context)))
            .build()),
            Expanded(child: (ButtonBuilder(imagePaths.icForward)
              ..key(const Key('button_forward_message'))
              ..size(20)
              ..radiusSplash(0)
              ..padding(const EdgeInsets.only(top: 5, bottom: 8))
              ..textStyle(TextStyle(
                  fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                  color: AppColor.colorTextButton))
              ..onPressActionClick(() => onPressEmailActionClick?.call(EmailActionType.forward))
              ..text(AppLocalizations.of(context).forward,
                  isVertical: responsiveUtils.isPortraitMobile(context)))
            .build()),
            if (responsiveUtils.mailboxDashboardOnlyHasEmailView(context))
              Expanded(child: (ButtonBuilder(imagePaths.icNewMessage)
                ..key(const Key('button_new_message'))
                ..size(20)
                ..radiusSplash(0)
                ..padding(const EdgeInsets.only(top: 5, bottom: 8))
                ..textStyle(TextStyle(
                    fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                    color: AppColor.colorTextButton))
                ..onPressActionClick(() => onPressEmailActionClick?.call(EmailActionType.compose))
                ..text(AppLocalizations.of(context).new_message,
                    isVertical: responsiveUtils.isPortraitMobile(context)))
              .build())
          ]
      )
    );
  }
}