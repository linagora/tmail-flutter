
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseDialogAction = void Function();
typedef OnCopyEmailAddressDialogAction = void Function(EmailAddress);
typedef OnComposeEmailDialogAction = void Function(EmailAddress);

class EmailAddressDialogBuilder extends StatelessWidget {

  final EmailAddress _emailAddress;
  final OnCloseDialogAction? onCloseDialogAction;
  final OnCopyEmailAddressDialogAction? onCopyEmailAddressAction;
  final OnComposeEmailDialogAction? onComposeEmailAction;

  const EmailAddressDialogBuilder(
      this._emailAddress, {
      Key? key,
      this.onCloseDialogAction,
      this.onCopyEmailAddressAction,
      this.onComposeEmailAction,
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
        child: Wrap(
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    onPressed: () => onCloseDialogAction?.call(),
                    icon: SvgPicture.asset(
                        imagePaths.icCloseMailbox,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fill))),
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
                  child: Center(child: Text(
                    _emailAddress.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColor.colorNameEmail),
                  ))
              ),
            Padding(
                padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: _emailAddress.displayName.isNotEmpty ? 12 : 16),
                child: Center(child: Text(
                  _emailAddress.emailAddress,
                  textAlign: TextAlign.center,
                  overflow: CommonTextStyle.defaultTextOverFlow,
                  softWrap: CommonTextStyle.defaultSoftWrap,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: AppColor.colorMessageConfirmDialog),
                ))
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
            SizedBox(height: _emailAddress.displayName.isNotEmpty ? 100 : 130),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                child: SizedBox(
                  key: const Key('compose_email_button'),
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) => Colors.white),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) => AppColor.colorTextButton),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  width: 0,
                                  color: AppColor.colorTextButton)))),
                      child: Text(
                          AppLocalizations.of(context).compose_email,
                          style: const TextStyle(
                              fontSize: 16,
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
