
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SendingState {
  waiting,
  running,
  error,
  success;

  String getTitle(BuildContext context) {
    switch(this) {
      case SendingState.waiting:
      case SendingState.running:
      case SendingState.success:
        return AppLocalizations.of(context).delivering;
      case SendingState.error:
        return AppLocalizations.of(context).error;
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case SendingState.waiting:
      case SendingState.running:
      case SendingState.success:
        return imagePaths.icDelivering;
      case SendingState.error:
        return imagePaths.icError;
    }
  }

  String getAvatarGroup(ImagePaths imagePaths) {
    switch(this) {
      case SendingState.running:
        return imagePaths.icAvatarGroupDelivering;
      case SendingState.waiting:
      case SendingState.error:
      case SendingState.success:
        return imagePaths.icAvatarGroup;
    }
  }

  String getAvatarPersonal(ImagePaths imagePaths) {
    switch(this) {
      case SendingState.running:
        return imagePaths.icAvatarPersonalDelivering;
      case SendingState.waiting:
      case SendingState.error:
      case SendingState.success:
        return imagePaths.icAvatarPersonal;
    }
  }

  Color getTitleColor() {
    switch(this) {
      case SendingState.waiting:
      case SendingState.running:
      case SendingState.success:
        return AppColor.colorTitleSendingItem;
      case SendingState.error:
        return AppColor.colorErrorState;
    }
  }

  Color getBackgroundColor() {
    switch(this) {
      case SendingState.waiting:
      case SendingState.running:
      case SendingState.success:
        return AppColor.colorBackgroundDeliveringState;
      case SendingState.error:
        return AppColor.colorBackgroundErrorState;
    }
  }

  Color getTitleSendingEmailItemColor() {
    switch(this) {
      case SendingState.running:
        return AppColor.colorDeliveringState;
      case SendingState.waiting:
      case SendingState.error:
      case SendingState.success:
        return Colors.black;
    }
  }

  Color getSubTitleSendingEmailItemColor() {
    switch(this) {
      case SendingState.running:
        return AppColor.colorDeliveringState;
      case SendingState.waiting:
      case SendingState.error:
      case SendingState.success:
        return AppColor.colorTitleSendingItem;
    }
  }
}