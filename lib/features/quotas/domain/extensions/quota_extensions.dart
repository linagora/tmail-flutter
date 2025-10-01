
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension QuotasExtensions on Quota {

  UnsignedInt? get presentationHardLimit => hardLimit ?? limit;

  String get usedStorageAsString => used != null ? filesize(used!.value) : '';

  String get hardLimitStorageAsString => presentationHardLimit != null ? filesize(presentationHardLimit!.value) : '';

  String get quotaAvailableStorageAsString {
    if (storageAvailable && presentationHardLimit!.value > used!.value) {
      return filesize(presentationHardLimit!.value - used!.value);
    }
    return '0 B';
  }

  bool get isWarnLimitReached {
    if (used != null && warnLimit != null) {
      return used!.value >= warnLimit!.value;
    } else {
      return false;
    }
  }

  bool get isHardLimitReached {
    if (storageAvailable) {
      return used!.value >= presentationHardLimit!.value;
    } else {
      return false;
    }
  }

  double get usedStoragePercent {
    if (storageAvailable && presentationHardLimit!.value > 0) {
      return used!.value / presentationHardLimit!.value;
    } else {
      return 0;
    }
  }

  bool get allowedDisplayToQuotaBanner => storageAvailable && (isHardLimitReached || isWarnLimitReached);

  bool get storageAvailable => used != null && presentationHardLimit != null;

  bool get isStorageUsageIndicatorAppear {
    if (storageAvailable) {
      return used!.value > presentationHardLimit!.value * 0.8;
    } else {
      return false;
    }
  }

  String getQuotasStateTitle(BuildContext context) {
    if (isHardLimitReached) {
      return '${AppLocalizations.of(context).textQuotasOutOfStorage}'
        '\n${AppLocalizations.of(context).quotaStateLabel(usedStorageAsString, hardLimitStorageAsString)}';
    } else {
      return AppLocalizations.of(context).quotaAvailableLabel(quotaAvailableStorageAsString);
    }
  }

  Color getQuotasStateTitleColor() {
    if (isHardLimitReached) {
      return AppColor.colorQuotaError;
    } else {
      return AppColor.steelGray400;
    }
  }

  Color getQuotasStateProgressBarColor({bool fromSetting = false}) {
    if (isHardLimitReached) {
      return AppColor.colorQuotaError;
    } else if (isWarnLimitReached) {
      return AppColor.colorBackgroundQuotasWarning;
    } else {
      return fromSetting ? AppColor.blue25AEFE : AppColor.blue400;
    }
  }

  String getQuotaBannerTitle(BuildContext context) {
    if (isHardLimitReached) {
      return AppLocalizations.of(context).quotaErrorBannerTitle;
    } else if (isWarnLimitReached) {
      return AppLocalizations.of(context).quotaBannerWarningTitle;
    } else {
      return '';
    }
  }
}