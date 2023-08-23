import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/styles/autocomplete_tag_item_style.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/avatar_tag_item_widget.dart';

typedef OnDeleteTagItemCallback = Function(String tagName);

class AutocompleteTagItemWidget extends StatelessWidget {

  final String tagName;
  final OnDeleteTagItemCallback onDeleteCallback;

  const AutocompleteTagItemWidget({
    super.key,
    required this.tagName,
    required this.onDeleteCallback,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(AutocompleteTagItemStyle.radius),
        ),
        color: AutocompleteTagItemStyle.backgroundColor,
      ),
      margin: AutocompleteTagItemStyle.margin,
      padding: AutocompleteTagItemStyle.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarTagItemWidget(tagName: tagName),
          const SizedBox(width: AutocompleteTagItemStyle.space),
          Text(
            tagName,
            maxLines: 1,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: AutocompleteTagItemStyle.labelTextStyle
          ),
          const SizedBox(width: AutocompleteTagItemStyle.space),
          TMailButtonWidget.fromIcon(
            icon: imagePaths.icClose,
            iconSize: AutocompleteTagItemStyle.deleteIconSize,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            onTapActionCallback: () => onDeleteCallback(tagName),
          )
        ],
      ),
    );
  }
}
