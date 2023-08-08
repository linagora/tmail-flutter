import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
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
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColor.colorDividerHorizontal,
            width: 0.5,
          )
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (_presentationEmail.numberOfAllEmailAddress() > 1)
              Expanded(
                child: TMailButtonWidget(
                  key: const Key('reply_all_emails_button'),
                  text: AppLocalizations.of(context).reply_all,
                  icon: imagePaths.icReplyAll,
                  borderRadius: 0,
                  iconSize: 15,
                  textAlign: TextAlign.center,
                  flexibleText: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  backgroundColor: Colors.transparent,
                  textStyle: TextStyle(
                    fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                    color: AppColor.colorTextButton
                  ),
                  verticalDirection: responsiveUtils.isPortraitMobile(context),
                  onTapActionCallback: () => onPressEmailActionClick?.call(EmailActionType.replyAll),
                ),
              ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('reply_email_button'),
                text: AppLocalizations.of(context).reply,
                icon: imagePaths.icReply,
                borderRadius: 0,
                iconSize: 20,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                backgroundColor: Colors.transparent,
                textStyle: TextStyle(
                  fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                  color: AppColor.colorTextButton
                ),
                verticalDirection: responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => onPressEmailActionClick?.call(EmailActionType.reply),
              ),
            ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('forward_email_button'),
                text: AppLocalizations.of(context).forward,
                icon: imagePaths.icForward,
                borderRadius: 0,
                iconSize: 20,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                backgroundColor: Colors.transparent,
                textStyle: TextStyle(
                  fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                  color: AppColor.colorTextButton
                ),
                verticalDirection: responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => onPressEmailActionClick?.call(EmailActionType.forward),
              ),
            ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('compose_new_email_button'),
                text: AppLocalizations.of(context).new_message,
                icon: imagePaths.icNewMessage,
                borderRadius: 0,
                iconSize: 20,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                backgroundColor: Colors.transparent,
                textStyle: TextStyle(
                  fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
                  color: AppColor.colorTextButton
                ),
                verticalDirection: responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => onPressEmailActionClick?.call(EmailActionType.compose),
              ),
            ),
          ]
        ),
      )
    );
  }
}