import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_bottom_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnEmailActionCallback = void Function(EmailActionType, PresentationEmail);

class EmailViewBottomBarWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final PresentationEmail presentationEmail;
  final EmailLoaded emailLoaded;
  final String userName;
  final OnEmailActionCallback emailActionCallback;
  final BoxDecoration? bottomBarDecoration;

  const EmailViewBottomBarWidget({
    Key? key,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.presentationEmail,
    required this.emailLoaded,
    required this.userName,
    required this.emailActionCallback,
    this.bottomBarDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final countMailAddress = presentationEmail.getCountMailAddressWithoutMe(userName);
    final isReplyToListEnabled = EmailUtils.isReplyToListEnabled(
      emailLoaded.emailCurrent?.listPost ?? '',
    );

    return Container(
      decoration: bottomBarDecoration ?? const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: EmailViewBottomBarWidgetStyles.topBorderColor,
            width: EmailViewBottomBarWidgetStyles.topBorderWidth,
          )
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(EmailViewBottomBarWidgetStyles.radius),
          bottomRight: Radius.circular(EmailViewBottomBarWidgetStyles.radius),
        ),
        color: EmailViewBottomBarWidgetStyles.backgroundColor
      ),
      padding: EmailViewBottomBarWidgetStyles.padding,
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (countMailAddress > 1)
              Expanded(
                child: TMailButtonWidget(
                  key: const Key('reply_all_emails_button'),
                  text: AppLocalizations.of(context).reply_all,
                  icon: imagePaths.icReplyAll,
                  borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                  iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                  iconColor: EmailViewBottomBarWidgetStyles.iconColor,
                  textAlign: TextAlign.center,
                  flexibleText: true,
                  padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                  backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                  textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(
                    context,
                    responsiveUtils,
                  ),
                  verticalDirection: responsiveUtils.isPortraitMobile(context),
                  onTapActionCallback: () => emailActionCallback.call(
                    EmailActionType.replyAll,
                    presentationEmail,
                  ),
                ),
              ),
            if (isReplyToListEnabled)
              Expanded(
                child: TMailButtonWidget(
                  key: const Key('reply_to_list_email_button'),
                  text: AppLocalizations.of(context).replyToList,
                  icon: imagePaths.icReply,
                  borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                  iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                  iconColor: EmailViewBottomBarWidgetStyles.iconColor,
                  textAlign: TextAlign.center,
                  flexibleText: true,
                  padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                  backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                  textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(
                    context,
                    responsiveUtils,
                  ),
                  verticalDirection: responsiveUtils.isPortraitMobile(context),
                  onTapActionCallback: () => emailActionCallback.call(
                    EmailActionType.replyToList,
                    presentationEmail,
                  ),
                ),
              ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('reply_email_button'),
                text: AppLocalizations.of(context).reply,
                icon: imagePaths.icReply,
                borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                iconColor: EmailViewBottomBarWidgetStyles.iconColor,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(
                  context,
                  responsiveUtils,
                ),
                verticalDirection: responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => emailActionCallback.call(
                  EmailActionType.reply,
                  presentationEmail,
                ),
              ),
            ),
            Expanded(
              child: TMailButtonWidget(
                key: const Key('forward_email_button'),
                text: AppLocalizations.of(context).forward,
                icon: imagePaths.icForward,
                borderRadius: EmailViewBottomBarWidgetStyles.buttonRadius,
                iconSize: EmailViewBottomBarWidgetStyles.buttonIconSize,
                iconColor: EmailViewBottomBarWidgetStyles.iconColor,
                textAlign: TextAlign.center,
                flexibleText: true,
                padding: EmailViewBottomBarWidgetStyles.buttonPadding,
                backgroundColor: EmailViewBottomBarWidgetStyles.buttonBackgroundColor,
                textStyle: EmailViewBottomBarWidgetStyles.getButtonTextStyle(
                  context,
                  responsiveUtils,
                ),
                verticalDirection: responsiveUtils.isPortraitMobile(context),
                onTapActionCallback: () => emailActionCallback.call(
                  EmailActionType.forward,
                  presentationEmail,
                ),
              ),
            ),
          ]
        ),
      )
    );
  }
}