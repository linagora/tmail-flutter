import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_widget.dart';

class LabelTagListWidget extends StatelessWidget {
  final List<Label> tags;
  final double horizontalPadding;
  final double itemSpacing;

  const LabelTagListWidget({
    super.key,
    required this.tags,
    this.horizontalPadding = 4,
    this.itemSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final maxWidth = constraints.maxWidth;

        final tagMaxWidth =
            maxWidth - LabelUtils.defaultPlusMaxWidth - itemSpacing;

        final displayedTagsDataResult = LabelUtils.safeComputeDisplayedTags(
          tags: tags,
          maxWidth: maxWidth,
          textStyle: ThemeUtils.textStyleContentCaption(),
          itemSpacing: itemSpacing,
          horizontalPadding: horizontalPadding,
          tagMaxWidth: tagMaxWidth,
          plusMaxWidth: LabelUtils.defaultPlusMaxWidth,
        );

        return Wrap(
          spacing: itemSpacing,
          runSpacing: 6,
          children: displayedTagsDataResult.displayed
              .map(
                (tagDisplayed) => LabelWidget(
                  label: tagDisplayed,
                  horizontalPadding: horizontalPadding,
                  maxWidth: tagMaxWidth,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
