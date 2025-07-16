
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension QuotasExtensions on Quota {

  UnsignedInt? get presentationHardLimit => hardLimit ?? limit;

  String get usedStorageAsString => used != null ? filesize(used!.value) : '';

  String get hardLimitStorageAsString => presentationHardLimit != null ? filesize(presentationHardLimit!.value) : '';

  bool get isWarnLimitReached {
    if (used != null && warnLimit != null) {
      return used!.value >= warnLimit!.value * 0.9;
    } else {
      return false;
    }
  }

  bool get isHardLimitReached {
    if (used != null && presentationHardLimit != null) {
      return used!.value >= presentationHardLimit!.value;
    } else {
      return false;
    }
  }

  double get usedStoragePercent {
    if (used != null && hardLimit != null && hardLimit!.value > 0) {
      return used!.value / hardLimit!.value;
    } else {
      return 0;
    }
  }

  bool get allowedDisplayToQuotaBanner => storageAvailable && (isHardLimitReached || isWarnLimitReached);

  bool get storageAvailable => used != null && presentationHardLimit != null;

  String getQuotasStateTitle(BuildContext context) {
    if (isHardLimitReached) {
      return '${AppLocalizations.of(context).textQuotasOutOfStorage}'
        '\n${AppLocalizations.of(context).quotaStateLabel(usedStorageAsString, hardLimitStorageAsString)}';
    } else {
      return AppLocalizations.of(context).quotaStateLabel(usedStorageAsString, hardLimitStorageAsString);
    }
  }

  Color getQuotasStateTitleColor() {
    if (isHardLimitReached) {
      return AppColor.colorQuotaError;
    } else {
      return AppColor.steelGray400;
    }
  }

  Color getQuotasStateProgressBarColor() {
    if (isHardLimitReached) {
      return AppColor.colorQuotaError;
    } else if (isWarnLimitReached) {
      return AppColor.colorBackgroundQuotasWarning;
    } else {
      return AppColor.blue400;
    }
  }

  Color getQuotaBannerBackgroundColor() {
    if (isHardLimitReached) {
      return AppColor.colorQuotaError.withOpacity(0.12);
    } else if (isWarnLimitReached) {
      return AppColor.colorBackgroundQuotasWarning.withOpacity(0.12);
    } else {
      return AppColor.colorNetworkConnectionBannerBackground;
    }
  }

  String getQuotaBannerIcon(ImagePaths imagePaths) {
    if (isHardLimitReached) {
      return imagePaths.icQuotasOutOfStorage;
    } else if (isWarnLimitReached) {
      return imagePaths.icQuotasWarning;
    } else {
      return '';
    }
  }

  String getQuotaBannerTitle(BuildContext context) {
    if (isHardLimitReached) {
      return AppLocalizations.of(context).quotaErrorBannerTitle;
    } else if (isWarnLimitReached) {
      return AppLocalizations.of(context).quotaWarningBannerTitle;
    } else {
      return '';
    }
  }

  String getQuotaBannerMessage(BuildContext context) {
    if (isHardLimitReached) {
      return AppLocalizations.of(context).quotaErrorBannerMessage;
    } else if (isWarnLimitReached) {
      return AppLocalizations.of(context).quotaWarningBannerMessage;
    } else {
      return '';
    }
  }

  Color getQuotaBannerTitleColor() {
    if (isHardLimitReached) {
      return AppColor.colorQuotaError;
    } else if (isWarnLimitReached) {
      return AppColor.colorQuotaWarning;
    } else {
      return Colors.black;
    }
  }

  Color getQuotaBannerMessageColor() {
    if (isHardLimitReached) {
      return AppColor.colorQuotaError;
    } else if (isWarnLimitReached) {
      return AppColor.colorQuotaWarning;
    } else {
      return Colors.black;
    }
  }
}