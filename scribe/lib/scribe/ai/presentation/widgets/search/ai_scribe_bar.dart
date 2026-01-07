import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scribe/scribe.dart';

typedef OnCustomPromptCallback = void Function(String customPrompt);

class AIScribeBar extends StatefulWidget {
  final OnCustomPromptCallback onCustomPrompt;
  final ImagePaths imagePaths;
  final List<BoxShadow>? boxShadow;

  const AIScribeBar({
    super.key,
    required this.onCustomPrompt,
    required this.imagePaths,
    this.boxShadow,
  });

  @override
  State<AIScribeBar> createState() => _AIScribeBarState();
}

class _AIScribeBarState extends State<AIScribeBar> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _isButtonEnabled.dispose();
    _focusNode.dispose();
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
    return Container(
      width: AIScribeSizes.searchBarWidth,
      padding: AIScribeSizes.searchBarPadding,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(AIScribeSizes.searchBarRadius),
        ),
        color: AIScribeColors.background,
        boxShadow: widget.boxShadow ?? AIScribeShadows.modal,
      ),
      constraints: const BoxConstraints(
        maxHeight: AIScribeSizes.searchBarMaxHeight,
        minHeight: AIScribeSizes.searchBarMinHeight,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _focusNode.requestFocus,
              child: KeyboardListener(
                focusNode: _focusNode,
                onKeyEvent: _handleKeyboardEvent,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: ScribeLocalizations.of(context).customPromptAction,
                    hintStyle: AIScribeTextStyles.searchBarHint,
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
