import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scribe/scribe.dart';

class AiSelectionOverlay extends StatelessWidget {
  const AiSelectionOverlay({
    super.key,
    required this.selection,
    required this.imagePaths,
    required this.onSelectAiScribeSuggestionAction,
    this.onTapFallback,
  });

  final TextSelectionModel? selection;
  final ImagePaths imagePaths;
  final OnSelectAiScribeSuggestionAction onSelectAiScribeSuggestionAction;
  final AsyncCallback? onTapFallback;

  @override
  Widget build(BuildContext context) {
    if (selection == null ||
        !selection!.hasSelection ||
        selection!.coordinates == null) {
      return const SizedBox.shrink();
    }

    final coordinates = selection!.coordinates!;
    final selectedText = selection!.selectedText;

    return PositionedDirectional(
      start: coordinates.dx,
      top: coordinates.dy,
      child: PointerInterceptor(
        child: InlineAiAssistButton(
          imagePaths: imagePaths,
          selectedText: selectedText,
          onSelectAiScribeSuggestionAction: onSelectAiScribeSuggestionAction,
          onTapFallback: onTapFallback,
        ),
      ),
    );
  }
}
