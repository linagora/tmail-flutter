import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:scribe/scribe/ai/presentation/styles/ai_scribe_styles.dart';

typedef OnInsertTextCallback = void Function(String text);

class AIScribeSuggestion extends StatefulWidget {
  final String title;
  final Future<String> suggestionFuture;
  final VoidCallback onClose;
  final OnInsertTextCallback onInsert;
  final ImagePaths imagePaths;

  const AIScribeSuggestion({
    super.key,
    required this.title,
    required this.suggestionFuture,
    required this.onClose,
    required this.onInsert,
    required this.imagePaths,
  });

  @override
  State<AIScribeSuggestion> createState() => _AIScribeSuggestionModalState();
}

class _AIScribeSuggestionModalState extends State<AIScribeSuggestion> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth < 600 ? screenWidth * 0.9 : 500.0;

    return PointerInterceptor(
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
        child: Container(
          width: modalWidth,
          constraints: const BoxConstraints(
            maxHeight: 400,
          ),
          decoration: BoxDecoration(
            color: AIScribeColors.background,
            borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
            boxShadow: AIScribeShadows.elevation8,
          ),
          child: FutureBuilder<String>(
            future: widget.suggestionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              } else if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              } else if (snapshot.hasData) {
                return _buildSuccessState(snapshot.data!);
              } else {
                return _buildErrorState('No data received');
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Generating AI response...',
                  style: AIScribeTextStyles.suggestionContent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(String suggestion) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: SingleChildScrollView(
              child: SelectableText(
                suggestion,
                style: AIScribeTextStyles.suggestionContent,
              ),
            ),
          ),
        ),
        _buildToolbar(suggestion),
        _buildFooter(suggestion),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 32, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to generate AI response',
                  style: AIScribeTextStyles.suggestionContent,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: AIScribeTextStyles.suggestionContent,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: AIScribeTextStyles.suggestionTitle
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            iconSize: 18,
            color: Colors.grey[600],
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(String suggestion) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.content_copy, size: 18),
            color: Colors.grey[600],
            onPressed: () {
              Clipboard.setData(ClipboardData(text: suggestion));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(String suggestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TMailButtonWidget(
            text: 'Insert',
            textStyle: AIScribeButtonStyles.mainActionButtonText,
            padding: AIScribeButtonStyles.mainActionButtonPadding,
            backgroundColor: AIScribeButtonStyles.mainActionButtonBackgroundColor,
            onTapActionCallback: () => widget.onInsert(suggestion),
          )
        ],
      ),
    );
  }
}
