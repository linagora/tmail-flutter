import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';

class LabelListContextMenu extends StatelessWidget {
  final List<Label> labelList;
  final List<Label> emailLabels;
  final ImagePaths imagePaths;
  final OnSelectLabelAction onSelectLabelAction;

  const LabelListContextMenu({
    super.key,
    required this.labelList,
    required this.emailLabels,
    required this.imagePaths,
    required this.onSelectLabelAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
    );
  }
}
