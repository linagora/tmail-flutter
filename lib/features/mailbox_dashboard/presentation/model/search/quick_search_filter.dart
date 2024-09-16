
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum QuickSearchFilter {
  hasAttachment,
  last7Days,
  fromMe,
  sortBy,
  dateTime,
  from;

  String getName(BuildContext context) {
    switch(this) {
      case QuickSearchFilter.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
      case QuickSearchFilter.last7Days:
        return AppLocalizations.of(context).last7Days;
      case QuickSearchFilter.fromMe:
        return AppLocalizations.of(context).fromMe;
      case QuickSearchFilter.sortBy:
        return AppLocalizations.of(context).sortBy;
      case QuickSearchFilter.dateTime:
        return AppLocalizations.of(context).allTime;
      case QuickSearchFilter.from:
        return AppLocalizations.of(context).from_email_address_prefix;
      default:
        return '';
    }
  }

  String getTitle(
    BuildContext context, {
    EmailReceiveTimeType? receiveTimeType,
    EmailSortOrderType? sortOrderType,
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? listAddressOfFrom,
    UserName? userName
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
        if (listAddressOfFrom?.length != 1) {
          return AppLocalizations.of(context).from_email_address_prefix;
        }

        if (userName?.value.isNotEmpty == true && listAddressOfFrom?.first == userName?.value) {
          return AppLocalizations.of(context).fromMe;
        } else {
          return '${AppLocalizations.of(context).from_email_address_prefix} ${listAddressOfFrom?.first}';
        }
      default:
        return '';
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
      return AppColor.colorTextBody;
    }
  }

  bool isApplied(List<QuickSearchFilter> listFilter) => listFilter.contains(this);

  bool isSelected(
    BuildContext context,
    SearchEmailFilter searchFilter,
    EmailSortOrderType sortOrderType
  ) {
    switch (this) {
      case QuickSearchFilter.hasAttachment:
        return searchFilter.hasAttachment;
      case QuickSearchFilter.last7Days:
        return true;
      case QuickSearchFilter.fromMe:
        return searchFilter.from.length == 1;
      case QuickSearchFilter.sortBy:
        return sortOrderType != EmailSortOrderType.mostRecent;
      case QuickSearchFilter.dateTime:
        return searchFilter.emailReceiveTimeType != EmailReceiveTimeType.allTime;
      case QuickSearchFilter.from:
        return searchFilter.from.isNotEmpty;
    }
  }

  bool isOnTapWithPositionActionSupported() =>
    this == QuickSearchFilter.dateTime || this == QuickSearchFilter.sortBy;

  bool isArrowDownIconSupported() =>
    this == QuickSearchFilter.dateTime ||
    this == QuickSearchFilter.from ||
    this == QuickSearchFilter.sortBy;
}