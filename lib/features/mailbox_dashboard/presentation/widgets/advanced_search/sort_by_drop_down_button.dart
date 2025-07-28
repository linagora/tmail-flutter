import 'package:core/presentation/resources/image_paths.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/sort_by_drop_down_style.dart';

typedef OnSortOrderSelected = void Function(EmailSortOrderType?);

class SortByDropDownButton extends StatelessWidget {

  final ImagePaths imagePaths;
  final EmailSortOrderType? sortOrderSelected;
  final OnSortOrderSelected? onSortOrderSelected;

  const SortByDropDownButton({
    Key? key,
    required this.imagePaths,
    this.sortOrderSelected,
    this.onSortOrderSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<EmailSortOrderType>(
          isExpanded: true,
          items: EmailSortOrderType.values
            .map((sortType) => DropdownMenuItem<EmailSortOrderType>(
              value: sortType,
              enabled: sortType != sortOrderSelected,
              child: PointerInterceptor(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        sortType.getTitle(context),
                        style: SortByDropdownStyle.menuItemStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (sortType == sortOrderSelected)
                      SvgPicture.asset(
                        imagePaths.icChecked,
                        width: SortByDropdownStyle.checkedIconSize,
                        height: SortByDropdownStyle.checkedIconSize,
                        fit: BoxFit.fill,
                      ),
                  ],
                )
              )
            )).toList(),
          value: sortOrderSelected,
          customButton: Container(
            height: AdvancedSearchInputFormStyle.inputFieldHeight,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(AdvancedSearchInputFormStyle.inputFieldBorderRadius),
              ),
              border: Border.all(
                color: AdvancedSearchInputFormStyle.inputFieldBorderColor,
                width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
              ),
              color: AdvancedSearchInputFormStyle.inputFieldBackgroundColor,
            ),
            padding: SortByDropdownStyle.buttonPadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sortOrderSelected?.getTitle(context) ?? '',
                    style: AdvancedSearchInputFormStyle.inputTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                SvgPicture.asset(imagePaths.icDropDown)
              ]
            ),
          ),
          onChanged: onSortOrderSelected,
          dropdownStyleData: DropdownStyleData(
            maxHeight: SortByDropdownStyle.dropdownMaxHeight,
            decoration: SortByDropdownStyle.dropdownDecoration,
            elevation: SortByDropdownStyle.dropdownElevation,
            offset: SortByDropdownStyle.dropdownOffset,
            padding: SortByDropdownStyle.dropdownPadding,
            scrollbarTheme: ScrollbarThemeData(
              radius: SortByDropdownStyle.dropdownScrollbarRadius,
              thickness: WidgetStateProperty.all<double>(SortByDropdownStyle.scrollbarThickness),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            )
          ),
          menuItemStyleData: SortByDropdownStyle.menuItemStyleData,
        )
      )
    );
  }
}
