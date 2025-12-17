import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

typedef OnCustomPromptCallback = void Function(String customPrompt);

class AIScribeBar extends StatefulWidget {
  final OnCustomPromptCallback onCustomPrompt;
  final ImagePaths imagePaths;

  const AIScribeBar({
    super.key,
    required this.onCustomPrompt,
    required this.imagePaths,
  });

  @override
  State<AIScribeBar> createState() => _AIScribeBarState();
}

class _AIScribeBarState extends State<AIScribeBar> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);

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
        boxShadow: AIScribeShadows.modal,
      ),
      constraints: const BoxConstraints(
        maxHeight: AIScribeSizes.searchBarMaxHeight,
        minHeight: AIScribeSizes.searchBarMinHeight,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: ScribeLocalizations.of(context).inputPlaceholder,
                hintStyle: AIScribeTextStyles.searchBarHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              style: AIScribeTextStyles.searchBar,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              cursorHeight: 16,
              onSubmitted: (_) => _onSendPressed(),
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
}
