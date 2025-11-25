import 'package:core/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';

@visibleForTesting
typedef MeasureWidthFn = double Function(Label label);

class LabelUtils {
  LabelUtils._();

  static const double defaultPlusMaxWidth = 40.0;

  static ({
    List<Label> displayed,
    int hiddenCount,
  }) computeDisplayedTags({
    required List<Label> tags,
    required double maxWidth,
    required TextStyle textStyle,
    double itemSpacing = 12,
    double horizontalPadding = 4,
    double? tagMaxWidth,
    double? plusMaxWidth,
    @visibleForTesting MeasureWidthFn? measureWidth,
  }) {
    if (tags.isEmpty) {
      return (displayed: const [], hiddenCount: 0);
    }

    final effectiveMeasure = measureWidth ??
        (label) => WidgetUtils.measureTextWidth(
              text: label.safeDisplayName,
              style: textStyle,
              horizontalPadding: horizontalPadding,
            );

    // Measure all tag widths with per-item max constraint
    final widths = tags.map((label) {
      final width = effectiveMeasure(label);
      return tagMaxWidth != null
          ? width.clamp(0, tagMaxWidth).toDouble()
          : width;
    }).toList();

    final total = tags.length;

    // Compute how many fit normally
    final fit = _computeFitCount(
      widths: widths,
      maxWidth: maxWidth,
      itemSpacing: itemSpacing,
    );

    int fitCount = fit.fitCount;
    double usedWidth = fit.usedWidth;
    int remaining = total - fitCount;

    // All fit normally
    if (fitCount > 0 && remaining == 0) {
      return (displayed: tags, hiddenCount: 0);
    }

    // Ensure minimum 1 displayed always
    if (fitCount == 0) {
      final first = tags.first;
      double firstWidth = widths.first;

      // First tag larger than maxWidth → still show it alone
      if (firstWidth > maxWidth) {
        return (displayed: [first], hiddenCount: total - 1);
      }

      final remainingCount = total - 1;
      final plus = _buildPlusLabel(remainingCount);

      double plusWidth = effectiveMeasure(plus);
      if (plusMaxWidth != null) {
        plusWidth = plusWidth.clamp(0, plusMaxWidth);
      }

      final next = firstWidth + itemSpacing + plusWidth;

      if (next <= maxWidth) {
        return (
          displayed: [first, plus],
          hiddenCount: remainingCount,
        );
      }

      return (
        displayed: [first],
        hiddenCount: remainingCount,
      );
    }

    // Normal shrink logic
    while (fitCount > 0) {
      final plus = _buildPlusLabel(remaining);

      double plusWidth = effectiveMeasure(plus);
      if (plusMaxWidth != null) {
        plusWidth = plusWidth.clamp(0, plusMaxWidth);
      }

      final spacing = (fitCount == 0) ? 0 : itemSpacing;
      final next = usedWidth + spacing + plusWidth;

      if (next <= maxWidth) {
        return (
          displayed: [...tags.take(fitCount), plus],
          hiddenCount: remaining,
        );
      }

      fitCount--;
      remaining++;

      usedWidth -= widths[fitCount] + (fitCount == 0 ? 0 : itemSpacing);
    }

    // Final fallback: always show first tag only
    return (
      displayed: [tags.first],
      hiddenCount: total - 1,
    );
  }

  static ({
    List<Label> displayed,
    int hiddenCount,
  }) safeComputeDisplayedTags({
    required List<Label> tags,
    required double maxWidth,
    required TextStyle textStyle,
    double itemSpacing = 12,
    double horizontalPadding = 4,
    double? tagMaxWidth,
    double? plusMaxWidth,
    @visibleForTesting MeasureWidthFn? measureWidth,
  }) {
    try {
      return computeDisplayedTags(
        tags: tags,
        maxWidth: maxWidth,
        textStyle: textStyle,
        itemSpacing: itemSpacing,
        horizontalPadding: horizontalPadding,
        tagMaxWidth: tagMaxWidth,
        plusMaxWidth: plusMaxWidth,
        measureWidth: measureWidth,
      );
    } catch (_, __) {
      if (tags.isEmpty) {
        return (displayed: const [], hiddenCount: 0);
      }

      return (
        displayed: [tags.first],
        hiddenCount: tags.length - 1,
      );
    }
  }

  static ({int fitCount, double usedWidth}) _computeFitCount({
    required List<double> widths,
    required double maxWidth,
    required double itemSpacing,
  }) {
    double used = 0;
    int fit = 0;

    for (var i = 0; i < widths.length; i++) {
      final space = (i == 0) ? 0 : itemSpacing;
      final next = used + space + widths[i];

      if (next <= maxWidth) {
        used = next;
        fit++;
      } else {
        break;
      }
    }

    return (fitCount: fit, usedWidth: used);
  }

  static Label _buildPlusLabel(int n) => Label(
        id: Id(LabelExtension.moreLabelId),
        displayName: n > 999 ? '+999+' : '+$n',
      );
}
