import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_time_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailRecoveryField {
  deletionDate,
  receptionDate,
  subject,
  recipients,
  sender;

  String getTitle(BuildContext context) {
    switch (this) {
      case EmailRecoveryField.deletionDate:
        return AppLocalizations.of(context).deletionDate;
      case EmailRecoveryField.receptionDate:
        return AppLocalizations.of(context).receptionDate;
      case EmailRecoveryField.subject:
        return AppLocalizations.of(context).subject;
      case EmailRecoveryField.recipients:
        return AppLocalizations.of(context).headerRecipients;
      case EmailRecoveryField.sender:
        return AppLocalizations.of(context).sender;
    }
  }

  String getHintText(BuildContext context) {
    switch (this) {
      case EmailRecoveryField.deletionDate:
        return AppLocalizations.of(context).last7Days;
      case EmailRecoveryField.receptionDate:
        return AppLocalizations.of(context).allTime;
      case EmailRecoveryField.subject:
        return AppLocalizations.of(context).enterSomeSuggestions;
      case EmailRecoveryField.recipients:
        return AppLocalizations.of(context).addRecipientButton;
      case EmailRecoveryField.sender:
        return AppLocalizations.of(context).addSender;
    }
  }

  List<EmailRecoveryTimeType> getSupportedTimeTypes(DateTime restorationHorizon) {
    switch (this) {
      case EmailRecoveryField.deletionDate:
        final supportedTypes = [
          EmailRecoveryTimeType.last7Days,
          EmailRecoveryTimeType.last15Days,
          EmailRecoveryTimeType.last30Days,
          EmailRecoveryTimeType.last6Months,
          EmailRecoveryTimeType.last1Year,
        ].where((type) => restorationHorizon
                                .subtract(const Duration(seconds: 2)) // to allow "15 days" if restorationHorizon is exactly 15
                                .isBefore(type.toOldestUTCDate()!.value)).toList();

        return [...supportedTypes, EmailRecoveryTimeType.customRange];
      case EmailRecoveryField.receptionDate:
        return [
          EmailRecoveryTimeType.allTime,
          EmailRecoveryTimeType.last7Days,
          EmailRecoveryTimeType.last30Days,
          EmailRecoveryTimeType.last6Months,
          EmailRecoveryTimeType.lastYear,
          EmailRecoveryTimeType.customRange,
        ];
      default:
        return [];
    }
  }

  TextStyle getTitleTextStyle() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColor.colorContentEmail,
    );
  }

  TextStyle getHintTextStyle() {
    final Color color;
    switch (this) {
      case EmailRecoveryField.deletionDate:
      case EmailRecoveryField.receptionDate:
        color = Colors.black;
        break;
      case EmailRecoveryField.subject:
      case EmailRecoveryField.recipients:
      case EmailRecoveryField.sender:
        color = AppColor.colorHintSearchBar;
        break;
    }
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}