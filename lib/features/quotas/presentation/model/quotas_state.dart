import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum QuotasState {
  notAvailable,
  normal,
  runningOutOfStorage,
  runOutOfStorage;

  Color getColorProgress() {
    switch(this) {
      case QuotasState.notAvailable:
      case QuotasState.normal:
        return AppColor.primaryColor;
      case QuotasState.runningOutOfStorage:
        return AppColor.colorProgressQuotasWarning;
      case QuotasState.runOutOfStorage:
        return AppColor.colorOutOfStorageQuotasWarning;
    }
  }

  Color getColorQuotasFooterText() {
    switch(this) {
      case QuotasState.notAvailable:
      case QuotasState.normal:
      case QuotasState.runningOutOfStorage:
        return AppColor.loginTextFieldHintColor;
      case QuotasState.runOutOfStorage:
        return AppColor.colorOutOfStorageQuotasWarning;
    }
  }

  String getQuotasFooterText(BuildContext context, num usedCapacity, num softLimitCapacity) {
    switch(this) {
      case QuotasState.notAvailable:
      case QuotasState.normal:
      case QuotasState.runningOutOfStorage:
        return AppLocalizations.of(context).textQuotasUsed(
          usedCapacity.toDouble(),
          softLimitCapacity.toDouble(),
        );
      case QuotasState.runOutOfStorage:
        return AppLocalizations.of(context).textQuotasOutOfStorage;
    }
  }

  String getIconWarningBanner(ImagePaths imagePaths) {
    switch(this) {
      case QuotasState.notAvailable:
      case QuotasState.normal:
      case QuotasState.runningOutOfStorage:
        return imagePaths.icQuotasWarning;
      case QuotasState.runOutOfStorage:
        return imagePaths.icQuotasOutOfStorage;
    }
  }

  Color getBackgroundColorWarningBanner() {
    switch(this) {
      case QuotasState.notAvailable:
      case QuotasState.normal:
      case QuotasState.runningOutOfStorage:
        return AppColor.colorBackgroundQuotasWarning.withOpacity(0.12);
      case QuotasState.runOutOfStorage:
        return AppColor.colorOutOfStorageQuotasWarning.withOpacity(0.12);
    }
  }

  String getTitleWarningBanner(BuildContext context, num progress) {
    switch(this) {
      case QuotasState.notAvailable:
      case QuotasState.normal:
      case QuotasState.runningOutOfStorage:
        return AppLocalizations.of(context).textQuotasRunningOutOfStorageTitle(progress.toDouble() * 100);
      case QuotasState.runOutOfStorage:
        return AppLocalizations.of(context).textQuotasRunOutOfStorageTitle;
    }
  }

  String getContentWarningBanner(BuildContext context) {
    switch(this) {
      case QuotasState.notAvailable:
      case QuotasState.normal:
      case QuotasState.runningOutOfStorage:
        return AppLocalizations.of(context).textQuotasRunningOutOfStorageContent;
      case QuotasState.runOutOfStorage:
        return AppLocalizations.of(context).textQuotasRunOutOfStorageContent;
    }
  }
}