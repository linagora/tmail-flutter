import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/labels/label_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_item.dart';

class LabelListView extends StatelessWidget {
  final List<Label> labels;
  final ImagePaths imagePaths;
  final bool isDesktop;
  final bool isMobileResponsive;
  final OnOpenLabelContextMenuAction? onOpenContextMenu;
  final OnLongPressLabelItemAction? onLongPressLabelItemAction;

  const LabelListView({
    super.key,
    required this.labels,
    required this.imagePaths,
    this.isDesktop = false,
    this.isMobileResponsive = false,
    this.onOpenContextMenu,
    this.onLongPressLabelItemAction,
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
        return LabelListItem(
          label: labels[index],
          imagePaths: imagePaths,
          isDesktop: isDesktop,
          isMobileResponsive: isMobileResponsive,
          onOpenContextMenu: onOpenContextMenu,
          onLongPressLabelItemAction: onLongPressLabelItemAction,
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
