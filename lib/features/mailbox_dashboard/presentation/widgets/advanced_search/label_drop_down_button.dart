import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';
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

  LabelDropDownButton({
    super.key,
    required this.imagePaths,
    required this.labels,
    required this.labelSelected,
    required this.onSelectLabelsActions,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: PointerInterceptor(
        child: DropdownButton2<Label>(
          isExpanded: true,
          value: labelSelected,
          items: _buildItems(),
          customButton: _LabelDropdownButtonView(
            imagePaths: imagePaths,
            labelSelected: labelSelected,
            localizations: AppLocalizations.of(context),
          ),
          onChanged: onSelectLabelsActions,
          dropdownStyleData: _dropdownStyleData,
          menuItemStyleData: LabelDropDownStyle.menuItemStyleData,
        ),
      ),
    );
  }

  List<DropdownMenuItem<Label>> _buildItems() {
    return labels.map((label) {
      return DropdownMenuItem<Label>(
        value: label,
        child: _LabelDropdownMenuItem(
          label: label,
          isSelected: labelSelected?.id == label.id,
          imagePaths: imagePaths,
        ),
      );
    }).toList(growable: false);
  }

  final DropdownStyleData _dropdownStyleData = DropdownStyleData(
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
  );
}

class _LabelDropdownMenuItem extends StatelessWidget {
  final Label label;
  final bool isSelected;
  final ImagePaths imagePaths;

  const _LabelDropdownMenuItem({
    required this.label,
    required this.isSelected,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: Row(
        spacing: 16,
        children: [
          SvgPicture.asset(
            isSelected
                ? imagePaths.icCheckboxSelected
                : imagePaths.icCheckboxUnselected,
            width: LabelDropDownStyle.checkedIconSize,
            height: LabelDropDownStyle.checkedIconSize,
            colorFilter: (isSelected
                    ? LabelDropDownStyle.checkedIconColor
                    : LabelDropDownStyle.unCheckedIconColor)
                .asFilter(),
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
    );
  }
}

class _LabelDropdownButtonView extends StatelessWidget {
  final ImagePaths imagePaths;
  final Label? labelSelected;
  final AppLocalizations localizations;

  const _LabelDropdownButtonView({
    required this.imagePaths,
    required this.labelSelected,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final displayedName =
        labelSelected?.safeDisplayName ?? localizations.allLabels;

    return Container(
      height: AdvancedSearchInputFormStyle.inputFieldHeight,
      padding: LabelDropDownStyle.buttonPadding,
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
          SvgPicture.asset(imagePaths.icDropDown),
        ],
      ),
    );
  }
}
