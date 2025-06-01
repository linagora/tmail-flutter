import 'dart:async';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';

typedef OnInputDialogPositiveButtonAction = void Function(String);
typedef OnInputDialogNegativeButtonAction = void Function();
typedef OnInputDialogInputErrorChangedAction = String? Function(String);
typedef OnInputDialogCloseButtonAction = void Function();

class EditTextDialogBuilder extends StatefulWidget {
  final String title;
  final String value;
  final String positiveText;
  final String negativeText;
  final String? closeIcon;
  final OnInputDialogPositiveButtonAction onPositiveButtonAction;
  final OnInputDialogNegativeButtonAction? onNegativeButtonAction;
  final OnInputDialogInputErrorChangedAction? onInputErrorChanged;
  final OnInputDialogCloseButtonAction? onCloseButtonAction;

  const EditTextDialogBuilder({
    super.key,
    required this.title,
    required this.value,
    required this.positiveText,
    required this.negativeText,
    required this.onPositiveButtonAction,
    this.onNegativeButtonAction,
    this.onInputErrorChanged,
    this.closeIcon,
    this.onCloseButtonAction,
  });

  @override
  State<EditTextDialogBuilder> createState() => _EditTextDialogBuilderState();
}

class _EditTextDialogBuilderState extends State<EditTextDialogBuilder> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.value.length,
      );
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(EditTextDialogBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _textController.text = widget.value;
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.value.length,
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: GestureDetector(
        onTap: _focusNode.unfocus,
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: 383,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsetsDirectional.only(
                      start: 24,
                      end: 28,
                    ),
                    child: Text(
                      widget.title,
                      style: ThemeUtils.textStyleM3HeadlineSmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 24,
                      end: 28,
                      top: 8,
                      bottom: 8,
                    ),
                    child: TextFieldBuilder(
                      controller: _textController,
                      focusNode: _focusNode,
                      autoFocus: true,
                      maxLines: 1,
                      textStyle: ThemeUtils.textStyleBodyBody3(
                        color: AppColor.m3SurfaceBackground,
                      ),
                      onTextChange: _onTextChanged,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsetsDirectional.only(
                          start: 12,
                          end: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        enabledBorder: _buildBorder(AppColor.m3Neutral90),
                        border: _buildBorder(AppColor.m3Neutral90),
                        focusedBorder: _buildBorder(AppColor.primaryMain),
                        errorBorder: _buildBorder(AppColor.colorErrorState),
                        focusedErrorBorder: _buildBorder(
                          AppColor.colorErrorState,
                        ),
                        errorStyle: ThemeUtils.textStyleBodyBody3(
                          color: AppColor.colorErrorState,
                        ),
                        errorText: _error,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 24,
                      end: 28,
                      top: 25,
                      bottom: 25,
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        TMailButtonWidget.fromText(
                          text: widget.negativeText,
                          textStyle: ThemeUtils.textStyleM3LabelLarge(),
                          maxLines: 1,
                          alignment: Alignment.center,
                          height: 48,
                          borderRadius: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          backgroundColor: Colors.transparent,
                          onTapActionCallback: _onNegativeAction,
                        ),
                        const SizedBox(width: 8),
                        TMailButtonWidget.fromText(
                          text: widget.positiveText,
                          textStyle: ThemeUtils.textStyleM3LabelLarge(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          alignment: Alignment.center,
                          height: 48,
                          borderRadius: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          backgroundColor: AppColor.primaryMain,
                          onTapActionCallback: _onPositiveAction,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showCloseButton()) _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  InputBorder _buildBorder(Color color) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: color),
      );

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _error = widget.onInputErrorChanged?.call(value);
      });
    });
  }

  void _onPositiveAction() {
    if (_error?.isNotEmpty != true) {
      widget.onPositiveButtonAction(_textController.text);
    }
  }

  void _onNegativeAction() {
    _debounce?.cancel();
    widget.onNegativeButtonAction?.call();
  }

  bool _showCloseButton() =>
      widget.onCloseButtonAction != null && widget.closeIcon != null;

  Widget _buildCloseButton() {
    return PositionedDirectional(
      top: 0,
      end: 0,
      child: TMailButtonWidget.fromIcon(
        icon: widget.closeIcon!,
        iconSize: 24,
        iconColor: AppColor.m3Tertiary,
        padding: const EdgeInsets.all(12),
        borderRadius: 24,
        backgroundColor: Colors.transparent,
        onTapActionCallback: widget.onCloseButtonAction,
      ),
    );
  }
}
