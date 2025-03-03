
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnCloseBottomSheetAction = void Function();
typedef OnCopyEmailAddressBottomSheetAction = void Function(EmailAddress);
typedef OnComposeEmailBottomSheetAction = void Function(EmailAddress);
typedef OnQuickCreatingRuleEmailBottomSheetAction = void Function(EmailAddress);

class EmailAddressBottomSheetBuilder {

  final BuildContext _context;
  final ImagePaths _imagePaths;
  final EmailAddress _emailAddress;

  OnCloseBottomSheetAction? _onCloseBottomSheetAction;
  OnCopyEmailAddressBottomSheetAction? _onCopyEmailAddressAction;
  OnComposeEmailBottomSheetAction? _onComposeEmailAction;
  OnQuickCreatingRuleEmailBottomSheetAction? _creatingRuleEmailBottomSheetAction;

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

  void addOnQuickCreatingRuleEmailBottomSheetAction(OnQuickCreatingRuleEmailBottomSheetAction creatingRuleEmailBottomSheetAction) {
    _creatingRuleEmailBottomSheetAction = creatingRuleEmailBottomSheetAction;
  }

  RoundedRectangleBorder _shape() {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0)));
  }

  BoxDecoration _decoration(BuildContext context) {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0)));
  }

  void show() {
    Get.bottomSheet(
      PointerInterceptor(child: GestureDetector(
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
                          padding: const EdgeInsets.only(top: 16, right: 16),
                          onPressed: () => _onCloseBottomSheetAction?.call(),
                          icon: SvgPicture.asset(
                              _imagePaths.icCircleClose,
                              width: 24,
                              height: 24,
                              fit: BoxFit.fill))),
                  (AvatarBuilder()
                      ..text(_emailAddress.asString().firstLetterToUpperCase)
                      ..size(64)
                      ..addTextStyle(const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 23,
                          color: Colors.white))
                      ..avatarColor(_emailAddress.avatarColors))
                    .build(),
                  if (_emailAddress.displayName.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16),
                        child: Text(
                          _emailAddress.displayName,
                          textAlign: TextAlign.center,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColor.colorNameEmail),
                        )),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      onLongPress: () {
                        AppUtils.copyEmailAddressToClipboard(_context, _emailAddress.emailAddress);
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
                  Material(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.transparent,
                      child: TextButton(
                          child: Text(
                            AppLocalizations.of(_context).copy_email_address,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColor.colorTextButton,
                                fontWeight: FontWeight.normal),
                          ),
                          onPressed: () => _onCopyEmailAddressAction?.call(_emailAddress)
                      )
                  ),
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
                          AppLocalizations.of(_context).quickCreatingRule,
                          style: const TextStyle(
                            fontSize: 17,
                            color: AppColor.colorTextButton,
                            fontWeight: FontWeight.w500)),
                        onPressed: () => _creatingRuleEmailBottomSheetAction?.call(_emailAddress)),
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
                                AppLocalizations.of(_context).compose_email,
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            onPressed: () => _onComposeEmailAction?.call(_emailAddress)),
                      )
                  )
                ],
              ),
            )),
          ),
        ),
      )),
      useRootNavigator: true,
      shape: _shape(),
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent
    );
  }
}