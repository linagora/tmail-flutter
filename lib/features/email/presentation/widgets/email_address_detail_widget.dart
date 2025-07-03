import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/base/widget/email_address_with_copy_widget.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseDialogAction = void Function();
typedef OnCopyEmailAddressDialogAction = void Function(EmailAddress);
typedef OnComposeEmailDialogAction = void Function(EmailAddress);
typedef OnQuickCreatingRuleEmailDialogAction = void Function(EmailAddress);

class EmailAddressDetailWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final EmailAddress emailAddress;
  final OnCloseDialogAction? onCloseDialogAction;
  final OnCopyEmailAddressDialogAction? onCopyEmailAddressAction;
  final OnComposeEmailDialogAction? onComposeEmailAction;
  final OnQuickCreatingRuleEmailDialogAction?
      onQuickCreatingRuleEmailDialogAction;

  const EmailAddressDetailWidget({
    Key? key,
    required this.imagePaths,
    required this.emailAddress,
    this.onCloseDialogAction,
    this.onCopyEmailAddressAction,
    this.onComposeEmailAction,
    this.onQuickCreatingRuleEmailDialogAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatarBuilder(
                username: emailAddress.asString().firstLetterToUpperCase,
                size: 67,
                textStyle: ThemeUtils.textStyleInter500().copyWith(
                  fontSize: 33.5,
                  height: 50.25 / 33.5,
                  letterSpacing: 0.31,
                  color: AppColor.secondaryContrastText,
                ),
              ),
              const SizedBox(height: 24),
              if (emailAddress.displayName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectableText(
                    emailAddress.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: ThemeUtils.textStyleM3HeadlineSmall.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
              EmailAddressWithCopyWidget(
                label: emailAddress.emailAddress,
                copyLabelIcon: imagePaths.icCopy,
                onCopyButtonAction: () =>
                    onCopyEmailAddressAction?.call(emailAddress),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ConfirmDialogButton(
                  label: AppLocalizations.of(context).quickCreatingRule,
                  backgroundColor: Colors.white,
                  textColor: AppColor.primaryMain,
                  borderColor: AppColor.primaryMain,
                  onTapAction: () =>
                      onQuickCreatingRuleEmailDialogAction?.call(emailAddress),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ConfirmDialogButton(
                  label: AppLocalizations.of(context).compose_email,
                  backgroundColor: AppColor.primaryMain,
                  textColor: Colors.white,
                  onTapAction: () => onComposeEmailAction?.call(emailAddress),
                ),
              ),
            ],
          ),
        ),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: TMailButtonWidget.fromIcon(
            icon: imagePaths.icCloseDialog,
            iconSize: 24,
            iconColor: AppColor.m3Tertiary,
            padding: const EdgeInsets.all(10),
            borderRadius: 24,
            backgroundColor: Colors.transparent,
            onTapActionCallback: onCloseDialogAction,
          ),
        ),
      ],
    );
  }
}
