import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/labels/label_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_item.dart';

class LabelListView extends StatelessWidget {
  final List<Label> labels;
  final ImagePaths imagePaths;
  final bool isDesktop;
  final Id? labelIdSelected;
  final OnOpenLabelCallback onOpenLabelCallback;
  final bool isMobileResponsive;
  final OnOpenLabelContextMenuAction? onOpenContextMenu;

  const LabelListView({
    super.key,
    required this.labels,
    required this.imagePaths,
    required this.onOpenLabelCallback,
    this.isDesktop = false,
    this.labelIdSelected,
    this.isMobileResponsive = false,
    this.onOpenContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    Widget labelListView = ListView.builder(
      key: const PageStorageKey('label_list'),
      shrinkWrap: true,
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: labels.length,
      itemBuilder: (context, index) {
        final label = labels[index];
        return LabelListItem(
          label: label,
          imagePaths: imagePaths,
          isSelected: label.id == labelIdSelected,
          isDesktop: isDesktop,
          onOpenLabelCallback: onOpenLabelCallback,
          isMobileResponsive: isMobileResponsive,
          onOpenContextMenu: onOpenContextMenu,
        );
      },
    );

    if (!isDesktop) {
      labelListView = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: labelListView,
      );
    }

    return labelListView;
  }
}
