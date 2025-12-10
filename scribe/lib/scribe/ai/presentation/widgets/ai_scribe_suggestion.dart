import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
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
    final modalWidth = screenWidth < AIScribeSizes.mobileBreakpoint
        ? screenWidth * AIScribeSizes.mobileWidthPercentage
        : AIScribeSizes.modalMaxWidthLargeScreen;

    return PointerInterceptor(
      child: Material(
        borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
        child: Container(
          width: modalWidth,
          constraints: const BoxConstraints(
            maxHeight: AIScribeSizes.modalMaxHeight,
          ),
          decoration: BoxDecoration(
            color: AIScribeColors.background,
            borderRadius: BorderRadius.circular(AIScribeSizes.menuBorderRadius),
          ),
          child: FutureBuilder<String>(
            future: widget.suggestionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              } else if (snapshot.hasError) {
                return _buildErrorState();
              } else if (snapshot.hasData) {
                return _buildSuccessState(snapshot.data!);
              } else {
                return _buildErrorState();
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
            height: AIScribeSizes.infoHeight,
            padding: AIScribeSizes.suggestionInfoPadding,
            child: const Center(
              child: CircularProgressIndicator(),
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
            padding: AIScribeSizes.suggestionContentPadding,
            child: SingleChildScrollView(
              child: SelectableText(
                suggestion,
                style: AIScribeTextStyles.suggestionContent,
              ),
            ),
          ),
        ),
        _buildFooter(suggestion),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            height: AIScribeSizes.infoHeight,
            padding: AIScribeSizes.suggestionInfoPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AIScribeSizes.iconSize,
                  color: Colors.red,
                ),
                const SizedBox(height: AIScribeSizes.fieldSpacing),
                Text(
                  ScribeLocalizations.of(context)!.failedToGenerate,
                  style: AIScribeTextStyles.suggestionContent,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AIScribeSizes.suggestionHeaderPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: AIScribeTextStyles.suggestionTitle
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: AIScribeSizes.iconSize,
            ),
            iconSize: AIScribeSizes.iconSize,
            color: Colors.grey[600],
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(String suggestion) {
    return Container(
      padding: AIScribeSizes.suggestionFooterPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.content_copy,
              size: AIScribeSizes.iconSize,
            ),
            color: Colors.grey[600],
            onPressed: () {
              Clipboard.setData(ClipboardData(text: suggestion));
            },
          ),
          TMailButtonWidget(
            text: ScribeLocalizations.of(context)!.insertButton,
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
