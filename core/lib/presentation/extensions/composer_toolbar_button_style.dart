import 'package:flutter/material.dart';

class ComposerToolbarButtonStyle {
  final String? tooltipLabel;
  final Color? iconColor;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ComposerToolbarButtonStyle({
    this.tooltipLabel,
    this.iconColor,
    this.iconSize = 20,
    this.borderRadius = 20,
    this.padding,
    this.margin,
  });
}
