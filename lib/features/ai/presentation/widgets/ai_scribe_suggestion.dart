import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/ai/presentation/styles/ai_scribe_styles.dart';

class AIScribeSuggestion extends StatelessWidget {
  final String suggestion;
  final VoidCallback onClose;
  final VoidCallback onInsert;
  final ImagePaths imagePaths;

  const AIScribeSuggestion({
    super.key,
    required this.suggestion,
    required this.onClose,
    required this.onInsert,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColor.textSecondary,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 400,
          minHeight: 150,
        ),
        child: SingleChildScrollView(
          child: SelectableText(
            suggestion,
            style: AIScribeTextStyles.resultContent,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Material(
            shape: const CircleBorder(),
            color: AppColor.primaryColor,
            child: InkWell(
              onTap: onInsert,
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_upward,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
