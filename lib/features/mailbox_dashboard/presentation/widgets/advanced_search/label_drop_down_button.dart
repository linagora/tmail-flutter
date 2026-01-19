import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:labels/labels.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/advanced_search_input_form_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/label_drop_down_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSelectLabelsActions = void Function(Label? label);

class LabelDropDownButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final List<Label> labels;
  final Label? labelSelected;
  final OnSelectLabelsActions onSelectLabelsActions;

  const LabelDropDownButton({
    Key? key,
    required this.imagePaths,
    required this.labels,
    required this.labelSelected,
    required this.onSelectLabelsActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<Label>(
          isExpanded: true,
          items: labels.map((label) {
            final isSelected = labelSelected?.id == label.id;
            return DropdownMenuItem<Label>(
              value: label,
              child: PointerInterceptor(
                child: Row(
                  spacing: 16,
                  children: [
                    SvgPicture.asset(
                      isSelected
                          ? imagePaths.icCheckboxSelected
                          : imagePaths.icCheckboxUnselected,
                      width: LabelDropDownStyle.checkedIconSize,
                      height: LabelDropDownStyle.checkedIconSize,
                      colorFilter: isSelected
                          ? LabelDropDownStyle.checkedIconColor.asFilter()
                          : LabelDropDownStyle.unCheckedIconColor.asFilter(),
                      fit: BoxFit.fill,
                    ),
                    Expanded(
                      child: Text(
                        label.safeDisplayName,
                        style: LabelDropDownStyle.menuItemStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          value: labelSelected,
          customButton: _buildButton(AppLocalizations.of(context)),
          onChanged: onSelectLabelsActions,
          dropdownStyleData: DropdownStyleData(
            maxHeight: LabelDropDownStyle.dropdownMaxHeight,
            decoration: LabelDropDownStyle.dropdownDecoration,
            elevation: LabelDropDownStyle.dropdownElevation,
            offset: LabelDropDownStyle.dropdownOffset,
            padding: LabelDropDownStyle.dropdownPadding,
            scrollbarTheme: ScrollbarThemeData(
              radius: LabelDropDownStyle.dropdownScrollbarRadius,
              thickness: WidgetStateProperty.all<double>(
                LabelDropDownStyle.scrollbarThickness,
              ),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: LabelDropDownStyle.menuItemStyleData,
        ),
      ),
    );
  }

  Widget _buildButton(AppLocalizations appLocalizations) {
    final displayedName =
        labelSelected?.safeDisplayName ?? appLocalizations.allLabels;

    return Container(
      height: AdvancedSearchInputFormStyle.inputFieldHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(
            AdvancedSearchInputFormStyle.inputFieldBorderRadius,
          ),
        ),
        border: Border.all(
          color: AdvancedSearchInputFormStyle.inputFieldBorderColor,
          width: AdvancedSearchInputFormStyle.inputFieldBorderWidth,
        ),
        color: AdvancedSearchInputFormStyle.inputFieldBackgroundColor,
      ),
      padding: LabelDropDownStyle.buttonPadding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayedName,
              style: AdvancedSearchInputFormStyle.inputTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SvgPicture.asset(imagePaths.icDropDown)
        ],
      ),
    );
  }
}
