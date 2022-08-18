
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef DisableVacationResponderAction = Function();

class VacationNotificationMessageWidget extends StatelessWidget {

  final VacationResponse vacationResponse;
  final DisableVacationResponderAction? action;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? radius;
  final Widget? leadingIcon;
  final Color? backgroundColor;
  final FontWeight? fontWeight;

  const VacationNotificationMessageWidget({
    super.key,
    required this.vacationResponse,
    this.action,
    this.radius,
    this.margin,
    this.padding,
    this.leadingIcon,
    this.backgroundColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      padding: padding ?? const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 5),
        color: backgroundColor ?? AppColor.colorVacationNotificationMessageBackground,
      ),
      child: Row(children: [
        if (leadingIcon != null) leadingIcon!,
       Expanded(
         child: Text(
           vacationResponse.getNotificationMessage(context),
           style: TextStyle(
             color: Colors.black,
             fontSize: 13,
             fontWeight: fontWeight ?? FontWeight.w500,
           ))),
        if (action != null)
          buildTextButton(
              AppLocalizations.of(context).disable.allInCaps,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColor.colorTextButton),
              backgroundColor: Colors.transparent,
              width: 128,
              height: 44,
              radius: 10,
              onTap: () => action!.call())
      ]),
    );
  }
}