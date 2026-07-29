import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Presentation-layer styling for the Filter Message button, kept out of the
/// domain [FilterMessageOption] so the model stays free of Flutter/l10n.
extension FilterMessageOptionStyleExtension on FilterMessageOption {
  bool get _isAll => this == FilterMessageOption.all;

  String getIconToast(ImagePaths imagePaths) => _icons(imagePaths).toast;

  String getContextMenuIcon(ImagePaths imagePaths) => _icons(imagePaths).menu;

  ({String toast, String menu}) _icons(ImagePaths imagePaths) => switch (this) {
        FilterMessageOption.all =>
          (toast: imagePaths.icFilterMessageAll, menu: ''),
        FilterMessageOption.unread =>
          (toast: imagePaths.icUnreadToast, menu: imagePaths.icUnread),
        FilterMessageOption.attachments => (
            toast: imagePaths.icFilterMessageAttachments,
            menu: imagePaths.icAttachment
          ),
        FilterMessageOption.starred =>
          (toast: imagePaths.icStar, menu: imagePaths.icUnStar),
      };

  String getName(AppLocalizations appLocalizations) =>
      _labels(appLocalizations).name;

  String getTitle(BuildContext context) =>
      _labels(AppLocalizations.of(context)).title;

  String getMessageToast(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return _isAll
        ? appLocalizations.disable_filter_message_toast
        : appLocalizations.filter_message_toast(getName(appLocalizations));
  }

  ({String name, String title}) _labels(AppLocalizations appLocalizations) =>
      switch (this) {
        FilterMessageOption.all =>
          (name: '', title: appLocalizations.filter_messages),
        FilterMessageOption.unread =>
          (name: appLocalizations.unread, title: appLocalizations.with_unread),
        FilterMessageOption.attachments => (
            name: appLocalizations.with_attachments,
            title: appLocalizations.with_attachments
          ),
        FilterMessageOption.starred => (
            name: appLocalizations.starred,
            title: appLocalizations.with_starred
          ),
      };

  String getIcon(ImagePaths imagePaths) =>
      _isAll ? imagePaths.icFilterAdvanced : imagePaths.icSelectedSB;

  Color getIconColor() =>
      _isAll ? AppColor.colorFilterMessageIcon : AppColor.primaryColor;

  Color getBackgroundColor({bool isSelected = false}) => isSelected
      ? AppColor.primaryColor.withValues(alpha: 0.06)
      : AppColor.colorFilterMessageButton.withValues(alpha: 0.6);

  TextStyle getTextStyle() => ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: _isAll ? AppColor.colorFilterMessageTitle : AppColor.primaryColor,
      );
}
