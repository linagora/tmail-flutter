import 'dart:math';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scribe/scribe.dart';

class AiScribeSuggestionWidget extends StatefulWidget {
  final AIAction aiAction;
  final String? content;
  final ImagePaths imagePaths;
  final Offset? buttonPosition;
  final Size? buttonSize;
  final ModalPlacement? preferredPlacement;
  final ModalCrossAxisAlignment crossAxisAlignment;
  final OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction;

  const AiScribeSuggestionWidget({
    super.key,
    required this.aiAction,
    required this.imagePaths,
    required this.onSelectAiScribeSuggestionAction,
    this.content,
    this.buttonPosition,
    this.buttonSize,
    this.preferredPlacement,
    this.crossAxisAlignment = ModalCrossAxisAlignment.center,
  });

  @override
  State<AiScribeSuggestionWidget> createState() =>
      _AiScribeSuggestionWidgetState();
}

class _AiScribeSuggestionWidgetState extends State<AiScribeSuggestionWidget>
    with AiScribeSuggestionStateMixin {
  @override
  AIAction get aiAction => widget.aiAction;

  @override
  String? get content => widget.content;

  @override
  ImagePaths get imagePaths => widget.imagePaths;

  @override
  OnSelectAiScribeSuggestionAction get onSelectAction =>
      widget.onSelectAiScribeSuggestionAction;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final keyboardHeightWithSpacing = keyboardHeight > 0 ? keyboardHeight + AIScribeSizes.keyboardSpacing : 0; 
    final screenSize = MediaQuery.of(context).size;
    final availableHeight = screenSize.height - keyboardHeightWithSpacing;

    final modalWidth = min(
      screenSize.width * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxWidth,
    );

    final modalMaxHeight = min(
      availableHeight * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxHeight,
    );

    final hasContent = widget.content?.trim().isNotEmpty == true;

    final dialogContent = _buildDialogContent(context, hasContent);

    if (!_hasAnchor) {
      return Center(
        child: _buildModalContainer(
          width: modalWidth,
          maxHeight: modalMaxHeight,
          child: dialogContent,
        ),
      );
    }

    final layout = AnchoredModalLayoutCalculator.calculateAnchoredSuggestLayout(
      screenSize: Size(screenSize.width, availableHeight),
      anchorPosition: widget.buttonPosition!,
      anchorSize: widget.buttonSize!,
      menuSize: Size(modalWidth, modalMaxHeight),
      preferredPlacement: widget.preferredPlacement,
      padding: AIScribeSizes.screenEdgePadding,
    );

    return PointerInterceptor(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _handleClickOutside,
            ),
          ),
          PositionedDirectional(
            start: layout.left,
            // layout.bottom is calculated by taking keyboard into account
            // but positionned without taking keyboard into account
            // that's why we need to add keyboard height here
            bottom: layout.bottom + keyboardHeightWithSpacing,
            child: _buildModalContainer(
              width: modalWidth,
              maxHeight: layout.availableHeight,
              child: dialogContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, bool hasContent) {
    final localizations = ScribeLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        AiScribeSuggestionHeader(
          title: widget.aiAction.getLabel(localizations),
          imagePaths: widget.imagePaths,
        ),
        Flexible(
          child: buildStateContent(context),
        ),
      ],
    );
  }

  Widget _buildModalContainer({
    required double width,
    required double maxHeight,
    required Widget child,
  }) {
    return PointerInterceptor(
      child: Container(
        width: width,
        constraints: BoxConstraints(
          minHeight: AIScribeSizes.suggestionModalMinHeight,
          maxHeight: maxHeight,
        ),
        padding: AIScribeSizes.suggestionContentPadding,
        decoration: BoxDecoration(
          color: AIScribeColors.background,
          borderRadius: BorderRadius.circular(
            AIScribeSizes.menuRadius,
          ),
          boxShadow: AIScribeShadows.modal,
        ),
        child: child,
      ),
    );
  }

  bool get _hasAnchor =>
      widget.buttonPosition != null && widget.buttonSize != null;

  void _handleClickOutside() {
    final shouldDismiss = suggestionState.value.fold(
      (failure) => failure is GenerateAITextFailure,
      (success) => success is GenerateAITextSuccess,
    );
    if (shouldDismiss) {
      Navigator.of(context).pop();
    }
  }
}
