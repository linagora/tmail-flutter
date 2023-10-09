import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_bottom_bar_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmailActionCallback = void Function(EmailActionType, PresentationEmail);

class EmailViewBottomBarWidget extends StatelessWidget {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final PresentationEmail presentationEmail;
  final OnEmailActionCallback emailActionCallback;

  EmailViewBottomBarWidget({
    Key? key,
    required this.presentationEmail,
    required this.emailActionCallback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: EmailViewBottomBarWidgetStyles.topBorderColor,
            width: EmailViewBottomBarWidgetStyles.topBorderWidth,
          ),
          bottom: BorderSide(
            color: EmailViewBottomBarWidgetStyles.topBorderColor,
            width: EmailViewBottomBarWidgetStyles.borderWidth,
          ),
          right: BorderSide(
            color: EmailViewBottomBarWidgetStyles.topBorderColor,
            width: EmailViewBottomBarWidgetStyles.borderWidth,
          ),
          left: BorderSide(
            color: EmailViewBottomBarWidgetStyles.topBorderColor,
            width: EmailViewBottomBarWidgetStyles.borderWidth,
          ),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(EmailViewBottomBarWidgetStyles.radius),
          bottomRight: Radius.circular(EmailViewBottomBarWidgetStyles.radius),
        ),
        color: EmailViewBottomBarWidgetStyles.backgroundColor
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (presentationEmail.numberOfAllEmailAddress() > 1)
              Expanded(
                child: TMailButtonWidget(
                  key: const Key('reply_all_emails_button'),
                  text: AppLocalizations.of(context).reply_all,
                  icon: _imagePaths.icReplyAll,
                  borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                  iconSize: EmailViewBottomBarWidgetStyles.replyAllButtonIconSize,
                  textAlign: TextAlign.center,
                  flexibleText: true,
                  padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                  backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                  textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(context, _responsiveUtils),
                  verticalDirection: _responsiveUtils.isPortraitMobile(context),
                  onTapActionCallback: () => emailActionCallback.call(EmailActionType.replyAll, presentationEmail),
                ),
              ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('reply_email_button'),
                text: AppLocalizations.of(context).reply,
                icon: _imagePaths.icReply,
                borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(context, _responsiveUtils),
                verticalDirection: _responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => emailActionCallback.call(EmailActionType.reply, presentationEmail),
              ),
            ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('forward_email_button'),
                text: AppLocalizations.of(context).forward,
                icon: _imagePaths.icForward,
                borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(context, _responsiveUtils),
                verticalDirection: _responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => emailActionCallback.call(EmailActionType.forward, presentationEmail),
              ),
            ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('compose_new_email_button'),
                text: AppLocalizations.of(context).new_message,
                icon: _imagePaths.icNewMessage,
                borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(context, _responsiveUtils),
                verticalDirection: _responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => emailActionCallback.call(EmailActionType.compose, presentationEmail),
              ),
            ),
          ]
        ),
      )
    );
  }
}