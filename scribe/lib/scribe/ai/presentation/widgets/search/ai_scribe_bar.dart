import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scribe/scribe.dart';

typedef OnCustomPromptCallback = void Function(String customPrompt);

class AIScribeBar extends StatefulWidget {
  final OnCustomPromptCallback onCustomPrompt;
  final ImagePaths imagePaths;
  final double? borderRadius;
  final TextStyle? hintStyle;

  const AIScribeBar({
    super.key,
    required this.onCustomPrompt,
    required this.imagePaths,
    this.borderRadius,
    this.hintStyle,
  });

  @override
  State<AIScribeBar> createState() => _AIScribeBarState();
}

class _AIScribeBarState extends State<AIScribeBar> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _keyboardListenerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _textFieldFocusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _isButtonEnabled.dispose();
    _textFieldFocusNode.dispose();
    _keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _isButtonEnabled.value = _controller.text.trim().isNotEmpty;
  }

  void _onSendPressed() {
    final prompt = _controller.text.trim();
    if (prompt.isNotEmpty) {
      widget.onCustomPrompt(prompt);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(widget.borderRadius ?? AIScribeSizes.searchBarRadius);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: AIScribeColors.barGradient,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: AIScribeSizes.searchBarWidth,
          padding: AIScribeSizes.searchBarPadding,
          decoration: const BoxDecoration(
            color: AIScribeColors.background,
          ),
          constraints: const BoxConstraints(
            maxHeight: AIScribeSizes.searchBarMaxHeight,
            minHeight: AIScribeSizes.searchBarMinHeight,
          ),
          child: Row(
            children: [
              Expanded(
                child: KeyboardListener(
                  focusNode: _keyboardListenerFocusNode,
                  onKeyEvent: _handleKeyboardEvent,
                  child: TextField(
                    controller: _controller,
                    focusNode: _textFieldFocusNode,
                    decoration: InputDecoration(
                      hintText: ScribeLocalizations.of(context).customPromptAction,
                      hintStyle: widget.hintStyle ?? AIScribeTextStyles.searchBarHint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                    style: AIScribeTextStyles.searchBar,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    cursorHeight: 16,
                  ),
                ),
              ),
              const SizedBox(width: AIScribeSizes.fieldSpacing),
              ValueListenableBuilder<bool>(
                valueListenable: _isButtonEnabled,
                builder: (_, isEnabled, __) {
                  return TMailButtonWidget.fromIcon(
                    icon: widget.imagePaths.icSend,
                    iconSize: AIScribeSizes.sendIcon,
                    padding: AIScribeSizes.sendIconPadding,
                    iconColor: AIScribeColors.background,
                    backgroundColor: isEnabled
                        ? AIScribeColors.sendPromptBackground
                        : AIScribeColors.sendPromptBackgroundDisabled,
                    onTapActionCallback: isEnabled ? _onSendPressed : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleKeyboardEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      final isShiftPressed = keys.contains(LogicalKeyboardKey.shiftLeft) ||
          keys.contains(LogicalKeyboardKey.shiftRight);

      if (!isShiftPressed) {
        _onSendPressed();
      }
    }
  }
}
