import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:core/presentation/views/dialog/modal_list_action_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:get/get.dart';

typedef OnSelectColorCallback = void Function(Color? color);

class ColorPickerModal extends StatefulWidget {
  final ImagePaths imagePaths;
  final String modalTitle;
  final String modalSubtitle;
  final String negativeButtonText;
  final String positiveButtonText;
  final String hexColorText;
  final Color? initialColor;
  final OnSelectColorCallback onSelectColorCallback;
  final VoidCallback? onNegativeAction;

  const ColorPickerModal({
    super.key,
    required this.imagePaths,
    required this.modalTitle,
    required this.modalSubtitle,
    required this.onSelectColorCallback,
    this.negativeButtonText = 'Cancel',
    this.positiveButtonText = 'Save',
    this.hexColorText = 'Hex',
    this.initialColor,
    this.onNegativeAction,
  });

  @override
  State<ColorPickerModal> createState() => _ColorPickerModalState();
}

class _ColorPickerModalState extends State<ColorPickerModal> {
  static const Color _defaultColor = Colors.blue;

  final TextEditingController _hexColorInputController =
      TextEditingController();
  final FocusNode _hexColorFocusNode = FocusNode();
  final ValueNotifier<HSVColor> _hsvColorNotifier =
      ValueNotifier(HSVColor.fromColor(_defaultColor));

  @override
  void initState() {
    final currentColor = widget.initialColor ?? _defaultColor;
    _hsvColorNotifier.value = HSVColor.fromColor(currentColor);
    _hexColorInputController.text = currentColor.toHexTriplet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (_, constraints) {
      final currentScreenWidth = constraints.maxWidth;
      final currentScreenHeight = constraints.maxHeight;
      final isMobile = currentScreenWidth < ResponsiveUtils.minTabletWidth;

      Widget bodyWidget = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 2,
            ),
          ],
        ),
        width: math.min(
          currentScreenWidth - 32,
          554,
        ),
        constraints: BoxConstraints(maxHeight: currentScreenHeight - 100),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  alignment: Alignment.center,
                  padding: EdgeInsetsDirectional.only(
                    start: 32,
                    end: 32,
                    top: 16,
                    bottom: isMobile ? 0 : 16,
                  ),
                  child: Text(
                    widget.modalTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColor.m3SurfaceBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 32,
                      end: 32,
                      bottom: 24,
                    ),
                    child: Text(
                      widget.modalSubtitle,
                      style: ThemeUtils.textStyleInter400.copyWith(
                        color: AppColor.steelGrayA540,
                        fontSize: 13,
                        height: 20 / 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 32,
                        end: 32,
                        bottom: isMobile ? 0 : 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 24,
                            ),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 12,
                              ),
                              child: ValueListenableBuilder(
                                valueListenable: _hsvColorNotifier,
                                builder: (_, value, __) {
                                  return PaletteHuePicker(
                                    color: value,
                                    onChanged: _onHsvColorChanged,
                                    hueHeight: 32,
                                    paletteHeight: 200,
                                    palettePadding: const EdgeInsets.only(
                                      bottom: 16,
                                    ),
                                    paletteBorderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    hueBorderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.hexColorText,
                                  style: ThemeUtils.textStyleInter400.copyWith(
                                    color: AppColor.steelGrayA540,
                                    fontSize: 13,
                                    height: 20 / 13,
                                    letterSpacing: 0.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: 107,
                                padding: const EdgeInsetsDirectional.only(
                                  start: 12,
                                  top: 6,
                                ),
                                child: TextField(
                                  controller: _hexColorInputController,
                                  focusNode: _hexColorFocusNode,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.black,
                                  ),
                                  cursorColor: AppColor.primaryColor,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.only(
                                      bottom: 2,
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9A-Fa-f#]'),
                                    ),
                                  ],
                                  onChanged: _onHexColorChanged,
                                ),
                              )
                            ],
                          ),
                          ModalListActionButtonWidget(
                            positiveLabel: widget.positiveButtonText,
                            negativeLabel: widget.negativeButtonText,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            onPositiveAction: _onPositiveAction,
                            onNegativeAction: _onNegativeAction,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            DefaultCloseButtonWidget(
              iconClose: widget.imagePaths.icCloseDialog,
              onTapActionCallback: _onCloseModal,
            ),
          ],
        ),
      );

      bodyWidget = Center(child: bodyWidget);

      if (PlatformInfo.isMobile) {
        bodyWidget = GestureDetector(
          onTap: _onCloseModal,
          child: Scaffold(
            backgroundColor: AppColor.blackAlpha20,
            body: GestureDetector(
              onTap: _clearInputFocus,
              child: bodyWidget,
            ),
          ),
        );
      }

      return bodyWidget;
    });
  }

  void _onCloseModal() {
    _clearInputFocus();
    Get.back();
  }

  void _onNegativeAction() {
    _clearInputFocus();
    widget.onNegativeAction?.call();
    Get.back();
  }

  void _onPositiveAction() {
    _clearInputFocus();
    final hexColorText = _hexColorInputController.text.trimmed;
    if (hexColorText.isNotEmpty) {
      widget.onSelectColorCallback(hexColorText.toColor);
    }
    Get.back();
  }

  void _clearInputFocus() {
    _hexColorFocusNode.unfocus();
  }

  void _onHsvColorChanged(HSVColor hsvColor) {
    _hsvColorNotifier.value = hsvColor;
    _hexColorInputController.text = hsvColor.toColor().toHexTriplet();
  }

  void _onHexColorChanged(String value) {
    _hsvColorNotifier.value = HSVColor.fromColor(value.toColor);
  }

  @override
  void dispose() {
    _hexColorFocusNode.dispose();
    _hexColorInputController.dispose();
    _hsvColorNotifier.dispose();
    super.dispose();
  }
}
