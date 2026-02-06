import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/color/color_circle_widget.dart';
import 'package:core/presentation/views/color/color_picker_modal.dart';
import 'package:flutter/material.dart';

class ColorsMapWidget extends StatefulWidget {
  final ImagePaths imagePaths;
  final Color? customColor;
  final VoidCallback? onOpenColorPicker;
  final OnSelectColorCallback? onSelectColorCallback;

  const ColorsMapWidget({
    super.key,
    required this.imagePaths,
    this.customColor,
    this.onOpenColorPicker,
    this.onSelectColorCallback,
  });

  @override
  State<ColorsMapWidget> createState() => _ColorsMapWidgetState();
}

class _ColorsMapWidgetState extends State<ColorsMapWidget> {
  static const List<Color> _defaultColors = [
    Color(0xFF273891),
    Color(0xFF7E57E3),
    Color(0xFF9E83E8),
    Color(0xFF617ADB),
    Color(0xFF4896E5),
    Color(0xFF038199),
    Color(0xFF457D6C),
    Color(0xFF1EBBCC),
    Color(0xFF51B588),
    Color(0xFFE0465C),
    Color(0xFFED20A4),
    Color(0xFFED768D),
    Color(0xFFB85B17),
    Color(0xFFBA8144),
    Color(0xFFED916B),
    Color(0xFFEDA91D),
    Color(0xFFEDC661),
    Color(0xFF131326),
    Color(0xFF2C2C42),
    Color(0xFF646580),
  ];

  static final Set<int> _defaultColorValues =
    _defaultColors.map((c) => c.toInt()).toSet();

  final ValueNotifier<Color?> _selectedColor = ValueNotifier(null);
  List<Color> _colorList = <Color>[];

  @override
  void initState() {
    super.initState();
    _setUpColorList();
  }

  @override
  void didUpdateWidget(covariant ColorsMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customColor != widget.customColor) {
      _setUpColorList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        TMailButtonWidget.fromIcon(
          icon: widget.imagePaths.icCloseDialog,
          iconColor: AppColor.m3SurfaceBackground.withValues(alpha: 0.48),
          iconSize: 18.46,
          width: 40,
          height: 40,
          borderRadius: 100,
          backgroundColor: Colors.transparent,
          border: Border.all(width: 2, color: AppColor.grayCDCDCD),
          onTapActionCallback: _clearColor,
        ),
        ..._colorList
            .map(
              (color) => ValueListenableBuilder(
                valueListenable: _selectedColor,
                builder: (context, value, child) {
                  return ColorCircleWidget(
                    color: color,
                    isSelected: color == value,
                    onTap: () => _selectColor(color),
                    imagePaths: widget.imagePaths,
                  );
                },
              ),
            )
            .toList(),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFFB2C36),
                Color(0xFFAD46FF),
                Color(0xFF2B7FFF),
              ],
              stops: [0, 0.5, 1],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
          ),
          child: TMailButtonWidget.fromIcon(
            icon: widget.imagePaths.icColorPicker,
            iconColor: AppColor.textSecondary,
            iconSize: 18.46,
            width: 38,
            height: 38,
            borderRadius: 100,
            backgroundColor: Colors.white,
            onTapActionCallback: widget.onOpenColorPicker,
          ),
        ),
      ],
    );
  }

  void _setUpColorList() {
    final custom = widget.customColor;
    final hasCustom = custom != null;
    final isCustomInDefaults =
        hasCustom && _defaultColorValues.contains(custom.toInt());

    _colorList = (hasCustom && !isCustomInDefaults)
        ? [custom, ..._defaultColors]
        : _defaultColors;

    _selectedColor.value = custom;
  }

  void _selectColor(Color color) {
    _selectedColor.value = color;
    widget.onSelectColorCallback?.call(color);
  }

  void _clearColor() {
    _selectedColor.value = null;
    widget.onSelectColorCallback?.call(null);
  }

  @override
  void dispose() {
    _selectedColor.dispose();
    super.dispose();
  }
}
