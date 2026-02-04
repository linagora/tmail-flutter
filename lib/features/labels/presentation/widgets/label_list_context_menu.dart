import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCreateANewLabelAction = void Function();

class LabelListContextMenu extends StatelessWidget {
  final List<Label> labelList;
  final List<Label> emailLabels;
  final ImagePaths imagePaths;
  final OnSelectLabelAction onSelectLabelAction;
  final OnCreateANewLabelAction onCreateANewLabelAction;

  const LabelListContextMenu({
    super.key,
    required this.labelList,
    required this.emailLabels,
    required this.imagePaths,
    required this.onSelectLabelAction,
    required this.onCreateANewLabelAction,
  });

  @override
  Widget build(BuildContext context) {
    final createLabelButton = TMailButtonWidget.fromText(
      text: AppLocalizations.of(context).createANewLabel,
      backgroundColor: Colors.transparent,
      textStyle: ThemeUtils.textStyleBodyBody3(color: Colors.black),
      width: double.infinity,
      alignment: AlignmentDirectional.centerStart,
      borderRadius: 0,
      height: 48,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      margin: labelList.isNotEmpty
          ? const EdgeInsetsDirectional.only(bottom: 8)
          : null,
      onTapActionCallback: onCreateANewLabelAction,
    );

    if (labelList.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: labelList.length,
              itemBuilder: (_, index) {
                final label = labelList[index];
                final isSelected = emailLabels.contains(label);
                return LabelItemContextMenu(
                  label: label,
                  imagePaths: imagePaths,
                  isSelected: isSelected,
                  onSelectLabelAction: onSelectLabelAction,
                );
              },
            ),
          ),
          Divider(
            height: 1,
            color: AppColor.gray424244.withValues(alpha: 0.12),
          ),
          createLabelButton,
        ],
      );
    } else {
      return createLabelButton;
    }
  }
}
