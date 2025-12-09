import 'package:flutter/material.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

typedef OnCustomPromptCallback = void Function(String customPrompt);

class AIScribeBar extends StatefulWidget {
  final OnCustomPromptCallback onCustomPrompt;

  const AIScribeBar({
    super.key,
    required this.onCustomPrompt,
  });

  @override
  State<AIScribeBar> createState() => _AIScribeBarState();
}

class _AIScribeBarState extends State<AIScribeBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _controller.text.trim().isNotEmpty;
    });
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
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: AIScribeSizes.menuItemPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AIScribeColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: ScribeLocalizations.of(context)!.inputPlaceholder,
                hintStyle: TextStyle(
                  color: AIScribeColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: AIScribeTextStyles.menuItem,
              onSubmitted: (_) => _onSendPressed(),
            ),
          ),
          const SizedBox(width: 8),
          TMailButtonWidget.fromIcon(
            icon: ImagePaths().icSend,
            iconSize: 16,
            iconColor: Colors.white,
            backgroundColor: _isButtonEnabled
                ? AIScribeButtonStyles.sendCustomPromptBackgroundColor
                : AIScribeButtonStyles.sendCustomPromptBackgroundColorDisabled,
            onTapActionCallback: _isButtonEnabled ? _onSendPressed : null,
          )
        ],
      ),
    );
  }
}
