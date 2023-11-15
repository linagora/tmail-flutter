import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/styles/email_sort_by_action_tile_widget_style.dart';

typedef OnSortOrderSelected = void Function(BuildContext, EmailSortOrderType);

class EmailSortByActionTitleWidget extends StatelessWidget {

  final EmailSortOrderType sortType;
  final ImagePaths imagePaths;
  final EmailSortOrderType? sortTypeSelected;
  final OnSortOrderSelected? onSortOrderSelected;

  const EmailSortByActionTitleWidget({
    super.key,
    required this.sortType,
    required this.imagePaths,
    this.sortTypeSelected,
    this.onSortOrderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSortOrderSelected?.call(context, sortType),
      child: Padding(
        padding: EmailSortByActionTitleWidgetStyle.padding,
        child: SizedBox(
          width: EmailSortByActionTitleWidgetStyle.width,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  sortType.getTitle(context),
                  style: sortType.getTextStyle(isInDropdown: true),
                )
              ),
              if (sortType == sortTypeSelected)
                const SizedBox(width: EmailSortByActionTitleWidgetStyle.space),
              if (sortType == sortTypeSelected)
                SvgPicture.asset(
                  imagePaths.icFilterSelected,
                  width: EmailSortByActionTitleWidgetStyle.iconSize,
                  height: EmailSortByActionTitleWidgetStyle.iconSize,
                  fit: BoxFit.fill,
                )
            ],
          ),
        ),
      ),
    );
  }
}