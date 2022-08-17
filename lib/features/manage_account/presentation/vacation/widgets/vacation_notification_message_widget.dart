
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef DisableVacationResponderAction = Function();

class VacationNotificationMessageWidget extends StatelessWidget {

  final VacationResponse vacationResponse;
  final DisableVacationResponderAction? action;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? radius;

  const VacationNotificationMessageWidget({
    super.key,
    required this.vacationResponse,
    this.action,
    this.radius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      padding: padding ?? const EdgeInsets.only(top: 5, bottom: 5, left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 5),
        color: AppColor.colorVacationNotificationMessageBackground,
      ),
      child: Row(children: [
       Expanded(
         child: Text(
           AppLocalizations.of(context).yourVacationResponderIsEnabled,
           style: const TextStyle(
             color: Colors.black,
             fontSize: 16,
             fontWeight: FontWeight.bold,
           ))),
        buildTextButton(
            AppLocalizations.of(context).disable.allInCaps,
            textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColor.colorTextButton),
            backgroundColor: Colors.transparent,
            width: 128,
            height: 44,
            radius: 10,
            onTap: () => action?.call())
      ]),
    );
  }
}