
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseDialogAction = void Function();
typedef OnCopyEmailAddressDialogAction = void Function(EmailAddress);
typedef OnComposeEmailDialogAction = void Function(EmailAddress);

class EmailAddressDialogBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final EmailAddress _emailAddress;

  OnCloseDialogAction? _onCloseDialogAction;
  OnCopyEmailAddressDialogAction? _onCopyEmailAddressAction;
  OnComposeEmailDialogAction? _onComposeEmailAction;

  EmailAddressDialogBuilder(
      this._context,
      this._imagePaths,
      this._emailAddress
  );

  void addOnCloseContextMenuAction(OnCloseDialogAction onCloseDialogAction) {
    _onCloseDialogAction = onCloseDialogAction;
  }

  void addOnCopyEmailAddressAction(OnCopyEmailAddressDialogAction onCopyEmailAddressAction) {
    _onCopyEmailAddressAction = onCopyEmailAddressAction;
  }

  void addOnComposeEmailAction(OnComposeEmailDialogAction onComposeEmailAction) {
    _onComposeEmailAction = onComposeEmailAction;
  }

  Widget build() {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                    onPressed: () => _onCloseDialogAction?.call(),
                    icon: SvgPicture.asset(_imagePaths.icCloseMailbox, width: 24, height: 24, fit: BoxFit.fill))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: (AvatarBuilder()
                  ..text(_emailAddress.asString().characters.first.toUpperCase())
                  ..size(64)
                  ..addTextStyle(const TextStyle(fontWeight: FontWeight.w600, fontSize: 23, color: Colors.white))
                  ..avatarColor(_emailAddress.avatarColors))
                .build())),
            if (_emailAddress.displayName.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Center(child: Text(
                    _emailAddress.asString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColor.colorNameEmail),
                  ))
              ),
            Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: _emailAddress.displayName.isNotEmpty ? 12 : 16),
                child: Center(child: Text(
                  _emailAddress.emailAddress,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: AppColor.colorMessageConfirmDialog),
                ))
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                  child: TextButton(
                      child: Text(
                        AppLocalizations.of(_context).copy_email_address,
                        style: const TextStyle(fontSize: 13, color: AppColor.colorTextButton, fontWeight: FontWeight.normal),
                      ),
                      onPressed: () => _onCopyEmailAddressAction?.call(_emailAddress)
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
                          foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.colorTextButton),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(width: 0, color: AppColor.colorTextButton)))),
                      child: Text(AppLocalizations.of(_context).compose_email, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                      onPressed: () => _onComposeEmailAction?.call(_emailAddress)),
                )
            )
          ],
        )
      ),
    );
  }
}
