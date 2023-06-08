
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SendingState {
  ready,
  delivering,
  error;

  String getTitle(BuildContext context) {
    switch(this) {
      case SendingState.delivering:
        return AppLocalizations.of(context).delivering;
      case SendingState.error:
        return AppLocalizations.of(context).error;
      case SendingState.ready:
        return '';
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch(this) {
      case SendingState.delivering:
        return imagePaths.icDelivering;
      case SendingState.error:
        return imagePaths.icError;
      case SendingState.ready:
        return '';
    }
  }

  String getAvatarGroup(ImagePaths imagePaths) {
    switch(this) {
      case SendingState.delivering:
        return imagePaths.icAvatarGroupDelivering;
      case SendingState.error:
        return imagePaths.icAvatarGroup;
      case SendingState.ready:
        return imagePaths.icAvatarGroup;
    }
  }

  String getAvatarPersonal(ImagePaths imagePaths) {
    switch(this) {
      case SendingState.delivering:
        return imagePaths.icAvatarPersonalDelivering;
      case SendingState.error:
        return imagePaths.icAvatarPersonal;
      case SendingState.ready:
        return imagePaths.icAvatarPersonal;
    }
  }

  Color getTitleColor() {
    switch(this) {
      case SendingState.delivering:
        return AppColor.colorTitleSendingItem;
      case SendingState.error:
        return AppColor.colorErrorState;
      case SendingState.ready:
        return Colors.transparent;
    }
  }

  Color getBackgroundColor() {
    switch(this) {
      case SendingState.delivering:
        return AppColor.colorBackgroundDeliveringState;
      case SendingState.error:
        return AppColor.colorBackgroundErrorState;
      case SendingState.ready:
        return Colors.transparent;
    }
  }
}