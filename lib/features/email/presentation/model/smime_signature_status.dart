
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SMimeSignatureStatus {
  goodSignature,
  badSignature,
  notSigned;

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case SMimeSignatureStatus.goodSignature:
        return imagePaths.icGoodSignature;
      case SMimeSignatureStatus.badSignature:
        return imagePaths.icBadSignature;
      case SMimeSignatureStatus.notSigned:
        return '';
    }
  }

  String getTooltipMessage(BuildContext context) {
    switch(this) {
      case SMimeSignatureStatus.goodSignature:
        return AppLocalizations.of(context).sMimeGoodSignatureMessage;
      case SMimeSignatureStatus.badSignature:
        return AppLocalizations.of(context).sMimeBadSignatureMessage;
      case SMimeSignatureStatus.notSigned:
        return '';
    }
  }
}