import 'dart:math' hide log;

import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
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
  static const double _defaultPadding = 32.0;

  @override
  AIAction get aiAction => widget.aiAction;

  @override
  String? get content => widget.content;

  @override
  ImagePaths get imagePaths => widget.imagePaths;

  @override
  OnSelectAiScribeSuggestionAction get onSelectAction =>
      widget.onSelectAiScribeSuggestionAction;

  bool get _hasAnchor =>
      widget.buttonPosition != null && widget.buttonSize != null;

  bool get _isMobileView =>
      PlatformInfo.isMobile || PlatformInfo.isWebTouchDevice;

  @override
  Widget build(BuildContext context) {
    // Cache MediaQuery data to avoid multiple lookups
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final viewInsetsBottom = mediaQuery.viewInsets.bottom;

    final keyboardHeightWithSpacing = viewInsetsBottom > 0
        ? viewInsetsBottom + AIScribeSizes.keyboardSpacing
        : 0.0;

    final availableHeight = screenSize.height - keyboardHeightWithSpacing;

    final modalWidth = min(
      screenSize.width * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxWidth,
    );

    final modalMaxHeight = min(
      availableHeight * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxHeight,
    );

    final dialogContent = _buildDialogContent(context);

    // No Anchor - Center the modal
    if (!_hasAnchor) {
      return _buildCenteredLayout(
        modalWidth: modalWidth,
        modalMaxHeight: modalMaxHeight,
        child: dialogContent,
      );
    }

    // Anchored Modal
    return _buildAnchoredLayout(
      screenSize: screenSize,
      availableHeight: availableHeight,
      keyboardHeightWithSpacing: keyboardHeightWithSpacing,
      modalWidth: modalWidth,
      modalMaxHeight: modalMaxHeight,
      child: dialogContent,
    );
  }

  Widget _buildCenteredLayout({
    required double modalWidth,
    required double modalMaxHeight,
    required Widget child,
  }) {
    return Center(
      child: _buildModalContainer(
        width: modalWidth,
        maxHeight: modalMaxHeight,
        child: child,
      ),
    );
  }

  Widget _buildAnchoredLayout({
    required Size screenSize,
    required double availableHeight,
    required double keyboardHeightWithSpacing,
    required double modalWidth,
    required double modalMaxHeight,
    required Widget child,
  }) {
    // Safe unwrap because we checked _hasAnchor before calling this
    final anchorPos = widget.buttonPosition!;
    final anchorSize = widget.buttonSize!;

    // Calculate layout using the helper
    final layout = AnchoredModalLayoutCalculator.calculateAnchoredSuggestLayout(
      screenSize: Size(screenSize.width, availableHeight),
      anchorPosition: anchorPos,
      anchorSize: anchorSize,
      menuSize: Size(modalWidth, modalMaxHeight),
      preferredPlacement: widget.preferredPlacement,
      padding: AIScribeSizes.screenEdgePadding,
    );

    // Calculate specific dimensions based on platform logic
    final double? top;
    final double? bottom;
    final double height;
    final double width;

    if (_isMobileView) {
      // Mobile logic: Anchor usually relates to top position
      top = anchorPos.dy;
      bottom = null;

      height = min(
        layout.availableHeight,
        screenSize.height - anchorPos.dy - anchorSize.height - _defaultPadding,
      );

      width = min(
        modalWidth,
        screenSize.width - anchorPos.dx - anchorSize.width - _defaultPadding,
      );
    } else {
      // Desktop/Web logic: Uses calculated bottom offset
      top = null;
      // Layout bottom doesn't account for keyboard in calculation usually, so we add it back
      bottom = layout.bottom + keyboardHeightWithSpacing;

      height = layout.availableHeight;
      width = modalWidth;
    }

    return PointerInterceptor(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _handleClickOutside,
            ),
          ),
          // The Modal
          PositionedDirectional(
            start: layout.left,
            top: top,
            bottom: bottom,
            child: _buildModalContainer(
              width: width,
              maxHeight: height,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
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
          borderRadius: const BorderRadius.all(
            Radius.circular(AIScribeSizes.menuRadius),
          ),
          boxShadow: AIScribeShadows.modal,
        ),
        child: child,
      ),
    );
  }

  void _handleClickOutside() {
    final state = suggestionState.value;
    final shouldDismiss = state.fold(
      (failure) => failure is GenerateAITextFailure,
      (success) => success is GenerateAITextSuccess,
    );

    if (shouldDismiss) {
      Navigator.of(context).pop();
    }
  }
}
