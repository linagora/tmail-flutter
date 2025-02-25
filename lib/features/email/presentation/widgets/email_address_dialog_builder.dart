
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnCloseDialogAction = void Function();
typedef OnCopyEmailAddressDialogAction = void Function(EmailAddress);
typedef OnComposeEmailDialogAction = void Function(EmailAddress);
typedef OnQuickCreatingRuleEmailDialogAction = void Function(EmailAddress);

class EmailAddressDialogBuilder extends StatelessWidget {

  final EmailAddress _emailAddress;
  final OnCloseDialogAction? onCloseDialogAction;
  final OnCopyEmailAddressDialogAction? onCopyEmailAddressAction;
  final OnComposeEmailDialogAction? onComposeEmailAction;
  final OnQuickCreatingRuleEmailDialogAction? onQuickCreatingRuleEmailDialogAction;

  const EmailAddressDialogBuilder(
      this._emailAddress, {
      Key? key,
      this.onCloseDialogAction,
      this.onCopyEmailAddressAction,
      this.onComposeEmailAction,
      this.onQuickCreatingRuleEmailDialogAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      insetPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0),
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        width: 400,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TMailButtonWidget.fromIcon(
                onTapActionCallback: onCloseDialogAction,
                icon: imagePaths.icCircleClose,
                backgroundColor: Colors.transparent,
                margin: const EdgeInsetsDirectional.only(top: 8, end: 8),
                iconSize: 24,
              )
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: (AvatarBuilder()
                  ..text(_emailAddress.asString().firstLetterToUpperCase)
                  ..size(64)
                  ..addTextStyle(const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 23,
                      color: Colors.white))
                  ..avatarColor(_emailAddress.avatarColors))
                .build())),
            if (_emailAddress.displayName.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16),
                  child: Center(child: SelectableText(
                    _emailAddress.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      overflow: CommonTextStyle.defaultTextOverFlow,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColor.colorNameEmail),
                  ))
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                onLongPress: () {
                  AppUtils.copyEmailAddressToClipboard(context, _emailAddress.emailAddress);
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    _emailAddress.emailAddress,
                    textAlign: TextAlign.center,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: AppColor.colorMessageConfirmDialog),
                  )
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  child: TextButton(
                      child: Text(
                        AppLocalizations.of(context).copy_email_address,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.colorTextButton,
                            fontWeight: FontWeight.normal),
                      ),
                      onPressed: () => onCopyEmailAddressAction?.call(_emailAddress)
                  )
              ))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
              child: SizedBox(
                key: const Key('quick_creating_rule_email_button'),
                width: double.infinity,
                height: 44,
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) => AppColor.colorTextButton),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) => AppColor.colorItemEmailSelectedDesktop),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        width: 0,
                        color: AppColor.colorItemEmailSelectedDesktop)))),
                  child: Text(
                    AppLocalizations.of(context).quickCreatingRule,
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppColor.colorTextButton,
                      fontWeight: FontWeight.w500)),
                  onPressed: () => onQuickCreatingRuleEmailDialogAction?.call(_emailAddress)),
              )
            ),
            Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: SizedBox(
                  key: const Key('compose_email_button'),
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                      style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) => Colors.white),
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) => AppColor.colorTextButton),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                  width: 0,
                                  color: AppColor.colorTextButton)))),
                      child: Text(
                          AppLocalizations.of(context).compose_email,
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                      onPressed: () => onComposeEmailAction?.call(_emailAddress)),
                )
            )
          ],
        )
      ),
    );
  }
}
