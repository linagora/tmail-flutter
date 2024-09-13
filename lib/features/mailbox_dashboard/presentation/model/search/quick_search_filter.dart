
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum QuickSearchFilter {
  hasAttachment,
  last7Days,
  fromMe,
  starred,
  sortBy,
  dateTime,
  from,
  to,
  folder;

  String getTitle(
    BuildContext context, {
    EmailReceiveTimeType? receiveTimeType,
    EmailSortOrderType? sortOrderType,
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? listAddressOfFrom,
    UserName? userName,
    Set<String>? listAddressOfTo,
    PresentationMailbox? mailbox
  }) {
    switch(this) {
      case QuickSearchFilter.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
      case QuickSearchFilter.last7Days:
        return AppLocalizations.of(context).last7Days;
      case QuickSearchFilter.fromMe:
        return AppLocalizations.of(context).fromMe;
      case QuickSearchFilter.sortBy:
        return sortOrderType?.getTitle(context)
          ?? AppLocalizations.of(context).mostRecent;
      case QuickSearchFilter.dateTime:
        return receiveTimeType?.getTitle(
          context,
          startDate: startDate,
          endDate: endDate
        ) ?? AppLocalizations.of(context).allTime;
      case QuickSearchFilter.from:
        return AppLocalizations.of(context).from_email_address_prefix;
      case QuickSearchFilter.folder:
        return mailbox?.getDisplayName(context) ?? AppLocalizations.of(context).all;
      case QuickSearchFilter.to:
        return AppLocalizations.of(context).to_email_address_prefix;
      case QuickSearchFilter.starred:
        return AppLocalizations.of(context).starred;
    }
  }

  String getIcon(ImagePaths imagePaths, {bool isSelected = false}) {
    switch(this) {
      case QuickSearchFilter.hasAttachment:
        return isSelected ? imagePaths.icSelectedSB : imagePaths.icAttachmentSB;
      case QuickSearchFilter.last7Days:
        return isSelected ? imagePaths.icSelectedSB : imagePaths.icCalendarSB;
      case QuickSearchFilter.fromMe:
        return isSelected ? imagePaths.icSelectedSB : imagePaths.icUserSB;
      case QuickSearchFilter.sortBy:
        return imagePaths.icFilterSB;
      case QuickSearchFilter.dateTime:
        return imagePaths.icCalendarSB;
      case QuickSearchFilter.from:
        return imagePaths.icUserSB;
      case QuickSearchFilter.to:
        return imagePaths.icUserSB;
      case QuickSearchFilter.folder:
        return imagePaths.icFolderMailbox;
      case QuickSearchFilter.starred:
        return isSelected ? imagePaths.icSelectedSB : imagePaths.icStar;
    }
  }

  Color getBackgroundColor({bool isFilterSelected = false}) {
    if (isFilterSelected) {
      return AppColor.primaryColor.withOpacity(0.06);
    } else {
      return AppColor.colorSearchFilterButton;
    }
  }

  Color getSuggestionBackgroundColor({bool isFilterSelected = false}) {
    if (isFilterSelected) {
      return AppColor.primaryColor.withOpacity(0.06);
    } else {
      return AppColor.colorSuggestionSearchFilterButton.withOpacity(0.6);
    }
  }

  Color getIconColor({bool isSelected = false}) {
    if (isSelected) {
      return AppColor.primaryColor;
    } else {
      if (this == QuickSearchFilter.starred) {
        return AppColor.colorStarredSearchFilterIcon;
      } else {
        return AppColor.colorSearchFilterIcon;
      }
    }
  }

  bool isApplied(List<QuickSearchFilter> listFilter) => listFilter.contains(this);

  bool isSelected(
    BuildContext context,
    SearchEmailFilter searchFilter,
    EmailSortOrderType sortOrderType,
    UserName? userName,
  ) {
    switch (this) {
      case QuickSearchFilter.hasAttachment:
        return searchFilter.hasAttachment;
      case QuickSearchFilter.last7Days:
        return searchFilter.emailReceiveTimeType == EmailReceiveTimeType.last7Days;
      case QuickSearchFilter.fromMe:
        return searchFilter.from.length == 1 &&
          userName?.value.isNotEmpty == true &&
          userName?.value == searchFilter.from.first;
      case QuickSearchFilter.sortBy:
        return sortOrderType != EmailSortOrderType.mostRecent;
      case QuickSearchFilter.dateTime:
        return searchFilter.emailReceiveTimeType != EmailReceiveTimeType.allTime;
      case QuickSearchFilter.from:
        return searchFilter.from.isNotEmpty;
      case QuickSearchFilter.to:
        return searchFilter.to.isNotEmpty;
      case QuickSearchFilter.folder:
        return searchFilter.mailbox != null;
      case QuickSearchFilter.starred:
        return searchFilter.hasKeyword.contains(KeyWordIdentifier.emailFlagged.value) == true;
    }
  }

  bool isOnTapWithPositionActionSupported() =>
    this == QuickSearchFilter.dateTime || this == QuickSearchFilter.sortBy;

  bool isArrowDownIconSupported() =>
    this == QuickSearchFilter.dateTime ||
    this == QuickSearchFilter.from ||
    this == QuickSearchFilter.to ||
    this == QuickSearchFilter.folder ||
    this == QuickSearchFilter.sortBy;
}