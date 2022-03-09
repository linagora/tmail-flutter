
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCloseBottomSheetAction = void Function();
typedef OnCopyEmailAddressBottomSheetAction = void Function(EmailAddress);
typedef OnComposeEmailBottomSheetAction = void Function(EmailAddress);

class EmailAddressBottomSheetBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final EmailAddress _emailAddress;

  OnCloseBottomSheetAction? _onCloseBottomSheetAction;
  OnCopyEmailAddressBottomSheetAction? _onCopyEmailAddressAction;
  OnComposeEmailBottomSheetAction? _onComposeEmailAction;

  EmailAddressBottomSheetBuilder(
      this._context,
      this._imagePaths,
      this._emailAddress
  );

  void addOnCloseContextMenuAction(OnCloseBottomSheetAction onCloseBottomSheetAction) {
    _onCloseBottomSheetAction = onCloseBottomSheetAction;
  }

  void addOnCopyEmailAddressAction(OnCopyEmailAddressBottomSheetAction onCopyEmailAddressAction) {
    _onCopyEmailAddressAction = onCopyEmailAddressAction;
  }

  void addOnComposeEmailAction(OnComposeEmailBottomSheetAction onComposeEmailAction) {
    _onComposeEmailAction = onComposeEmailAction;
  }

  RoundedRectangleBorder _shape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0)));
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20.0),
        topRight: const Radius.circular(20.0)));
  }

  void show() {
    Get.bottomSheet(
      GestureDetector(
        onTap: () => _onCloseBottomSheetAction?.call(),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.zero,
            decoration: _decoration(_context),
            child: SafeArea(child: GestureDetector(
              onTap: () => {},
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          padding: EdgeInsets.only(top: 16, right: 16),
                          onPressed: () => _onCloseBottomSheetAction?.call(),
                          icon: SvgPicture.asset(_imagePaths.icCloseMailbox, width: 24, height: 24, fit: BoxFit.fill))),
                  (AvatarBuilder()
                    ..text('${_emailAddress.asString().characters.first.toUpperCase()}')
                    ..size(64)
                    ..addTextStyle(TextStyle(fontWeight: FontWeight.w600, fontSize: 23, color: Colors.white))
                    ..avatarColor(_emailAddress.avatarColors))
                      .build(),
                  if (_emailAddress.displayName.isNotEmpty)
                    Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: Text(
                          _emailAddress.asString(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColor.colorNameEmail),
                        )),
                  Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: _emailAddress.displayName.isNotEmpty ? 12 : 16),
                      child: Text(
                        _emailAddress.emailAddress,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: AppColor.colorMessageConfirmDialog),
                      )),
                  Material(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.transparent,
                      child: TextButton(
                          child: Text(
                            AppLocalizations.of(_context).copy_email_address,
                            style: TextStyle(fontSize: 13, color: AppColor.colorTextButton, fontWeight: FontWeight.normal),
                          ),
                          onPressed: () => _onCopyEmailAddressAction?.call(_emailAddress)
                      )
                  ),
                  SizedBox(height: _emailAddress.displayName.isNotEmpty ? 100 : 130),
                  Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
                      child: SizedBox(
                        key: Key('compose_email_button'),
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
                                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.colorTextButton),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(width: 0, color: AppColor.colorTextButton)))),
                            child: Text(AppLocalizations.of(_context).compose_email, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                            onPressed: () => _onComposeEmailAction?.call(_emailAddress)),
                      )
                  )
                ],
              ),
            )),
          ),
        ),
      ),
      useRootNavigator: true,
      shape: _shape(),
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent
    );
  }
}