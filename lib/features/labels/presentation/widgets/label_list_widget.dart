import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/presentation/utils/label_utils.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_widget.dart';

class LabelTagListWidget extends StatelessWidget {
  final List<Label> tags;
  final double horizontalPadding;
  final double itemSpacing;
  final bool autoWrapTagsByMaxWidth;
  final bool isDesktop;

  const LabelTagListWidget({
    super.key,
    required this.tags,
    this.horizontalPadding = 4,
    this.itemSpacing = 12,
    this.autoWrapTagsByMaxWidth = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return autoWrapTagsByMaxWidth
        ? _buildAutoWrapMode()
        : _buildFixedDisplayMode();
  }

  Widget _buildAutoWrapMode() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final maxWidth = constraints.maxWidth;

        final tagMaxWidth =
            maxWidth - LabelUtils.defaultPlusMaxWidth - itemSpacing;

        final result = LabelUtils.safeComputeDisplayedTags(
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
          children: result.displayed
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

  Widget _buildFixedDisplayMode() {
    final result = LabelUtils.safeComputeDisplayedLabelsByMaxDisplay(
      labels: tags,
      maxDisplay: isDesktop ? 3 : 1,
    );

    final displayedWidgets = result.displayed.map((label) {
      return LabelWidget(
        label: label,
        horizontalPadding: horizontalPadding,
        isTruncateLabel: true,
      );
    });

    final plusWidget = (result.hiddenCount > 0)
        ? LabelWidget(
            label: LabelUtils.buildPlusLabel(result.hiddenCount),
            horizontalPadding: horizontalPadding,
          )
        : null;

    return Wrap(
      spacing: itemSpacing,
      runSpacing: 6,
      children: [
        ...displayedWidgets,
        if (plusWidget != null) plusWidget,
      ],
    );
  }
}
