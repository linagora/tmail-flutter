import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/widget/email_address_with_copy_widget.dart';
import 'package:tmail_ui_user/features/base/widget/user_avatar_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class EditRecipientsView extends StatelessWidget {
  final EmailAddress emailAddress;
  final ImagePaths imagePaths;
  final VoidCallback onCopyAction;
  final VoidCallback onEditAction;
  final VoidCallback onCreateRuleAction;
  final VoidCallback onCloseAction;

  const EditRecipientsView({
    super.key,
    required this.emailAddress,
    required this.imagePaths,
    required this.onCopyAction,
    required this.onEditAction,
    required this.onCreateRuleAction,
    required this.onCloseAction,
  });

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Container(
        width: 361,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 16,
                end: 24,
                top: 16,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                        padding: const EdgeInsetsDirectional.only(end: 21),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (emailAddress.displayName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 12),
                                child: Text(
                                  emailAddress.displayName,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColor.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            EmailAddressWithCopyWidget(
                              label: emailAddress.emailAddress,
                              copyLabelIcon: imagePaths.icCopy,
                              onCopyButtonAction: onCopyAction,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ConfirmDialogButton(
                            label: AppLocalizations.of(context).editEmail,
                            backgroundColor: AppColor.primaryMain,
                            textColor: Colors.white,
                            onTapAction: onEditAction,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ConfirmDialogButton(
                            label: AppLocalizations.of(context).createARule,
                            backgroundColor: Colors.white,
                            textColor: AppColor.primaryMain,
                            borderColor: AppColor.primaryMain,
                            onTapAction: onCreateRuleAction,
                          ),
                        ),
                      ),
                    ],
                  )
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
                onTapActionCallback: onCloseAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
