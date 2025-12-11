import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';

class LabelListContextMenu extends StatelessWidget {
  final PresentationEmail presentationEmail;
  final List<Label> labelList;
  final ImagePaths imagePaths;

  const LabelListContextMenu({
    super.key,
    required this.labelList,
    required this.presentationEmail,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    final emailLabels = presentationEmail.getLabelList(labelList);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: labelList.length,
      itemBuilder: (context, index) {
        final label = labelList[index];
        final isSelected = emailLabels.contains(label);
        return LabelItemContextMenu(
          label: label,
          imagePaths: imagePaths,
          isSelected: isSelected,
        );
      },
    );
  }
}
