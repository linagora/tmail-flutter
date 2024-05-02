
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/email_receive_time_type_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum QuickSearchFilter {
  hasAttachment,
  last7Days,
  fromMe,
  sortBy;

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
    }
  }

  String getTitle(
    BuildContext context, {
    EmailReceiveTimeType? receiveTimeType,
    EmailSortOrderType? sortOrderType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    switch(this) {
      case QuickSearchFilter.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
      case QuickSearchFilter.last7Days:
        return receiveTimeType?.getTitle(context, startDate: startDate, endDate: endDate)
          ?? AppLocalizations.of(context).allTime;
      case QuickSearchFilter.fromMe:
        return AppLocalizations.of(context).fromMe;
      case QuickSearchFilter.sortBy:
        return sortOrderType?.getTitle(context)
          ?? AppLocalizations.of(context).mostRecent;
    }
  }

  String getIcon(ImagePaths imagePaths, {required bool isFilterSelected}) {
    if (isFilterSelected) {
      return imagePaths.icSelectedSB;
    } else {
      switch(this) {
        case QuickSearchFilter.hasAttachment:
          return imagePaths.icAttachmentSB;
        case QuickSearchFilter.last7Days:
          return imagePaths.icCalendarSB;
        case QuickSearchFilter.fromMe:
          return imagePaths.icUserSB;
        case QuickSearchFilter.sortBy:
          return imagePaths.icFilterSB;
      }
    }
  }

  Color getBackgroundColor({required bool isFilterSelected}) {
    if (isFilterSelected) {
      return AppColor.colorItemEmailSelectedDesktop;
    } else {
      return AppColor.colorButtonHeaderThread;
    }
  }

  TextStyle getTextStyle({required bool isFilterSelected}) {
    if (isFilterSelected) {
      return const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColor.colorTextButton);
    } else {
      return const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColor.colorTextButtonHeaderThread);
    }
  }

  bool isApplied(List<QuickSearchFilter> listFilter) => listFilter.contains(this);

  bool isSelected(SearchEmailFilter filter) {
    switch (this) {
      case QuickSearchFilter.hasAttachment:
        return filter.hasAttachment == true;
      case QuickSearchFilter.last7Days:
        return true;
      case QuickSearchFilter.fromMe:
        return filter.from.length == 1;
      case QuickSearchFilter.sortBy:
        return true;
    }
  }

  bool isTapOpenPopupMenu() => this == QuickSearchFilter.last7Days || this == QuickSearchFilter.sortBy;
}