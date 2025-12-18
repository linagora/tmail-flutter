import 'dart:math';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      _AiScribeSuggestionWidgetModalState();
}

class _AiScribeSuggestionWidgetModalState
    extends State<AiScribeSuggestionWidget> {
  GenerateAITextInteractor? _generateAITextInteractor;
  final ValueNotifier<dynamic> _valueNotifier =
      ValueNotifier(dartz.Right(GenerateAITextLoading()));

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<GenerateAITextInteractor>()) {
      _generateAITextInteractor = Get.find<GenerateAITextInteractor>();
      _getAiSuggestion(
        _generateAITextInteractor!,
        widget.aiAction,
        widget.content,
      );
    }
  }

  Future<void> _getAiSuggestion(
    GenerateAITextInteractor interactor,
    AIAction action,
    String? content,
  ) async {
    final result = await interactor.execute(action, content);

    result.fold((failure) {
      _valueNotifier.value = failure;
    }, (success) {
      _valueNotifier.value = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ScribeLocalizations.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final modalWidth = min(
      screenSize.width * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxWidth,
    );
    final modalHeight = min(
      screenSize.height * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxHeight,
    );

    final dialogContent = Container(
      width: modalWidth,
      constraints: BoxConstraints(
        minHeight: AIScribeSizes.suggestionModalMinHeight,
        maxHeight: modalHeight,
      ),
      decoration: BoxDecoration(
        color: AIScribeColors.background,
        borderRadius: const BorderRadius.all(
          Radius.circular(AIScribeSizes.menuRadius),
        ),
        boxShadow: AIScribeShadows.modal,
      ),
      padding: AIScribeSizes.suggestionContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AiScribeSuggestionHeader(
            title: widget.aiAction.getLabel(localizations),
            imagePaths: widget.imagePaths,
          ),
          Flexible(
            child: ValueListenableBuilder(
              valueListenable: _valueNotifier,
              builder: (_, value, __) {
                if (value is GenerateAITextSuccess) {
                  return AiScribeSuggestionSuccess(
                    imagePaths: widget.imagePaths,
                    suggestionText: value.response.result,
                    onSelectAction: widget.onSelectAiScribeSuggestionAction,
                  );
                } else if (value is GenerateAITextFailure) {
                  return AiScribeSuggestionError(imagePaths: widget.imagePaths);
                } else {
                  return AiScribeSuggestionLoading(
                    imagePaths: widget.imagePaths,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );

    if (widget.buttonPosition != null && widget.buttonSize != null) {
      final layoutResult = AnchoredModalLayoutCalculator.calculate(
        input: AnchoredModalLayoutInput(
          screenSize: MediaQuery.of(context).size,
          anchorPosition: widget.buttonPosition!,
          anchorSize: widget.buttonSize!,
          menuSize: Size(
            modalWidth,
            AIScribeSizes.suggestionModalMinHeight,
          ),
          preferredPlacement: widget.preferredPlacement,
          crossAxisAlignment: widget.crossAxisAlignment,
        ),
        padding: AIScribeSizes.screenEdgePadding,
      );

      final position = layoutResult.position;

      final top = widget.preferredPlacement == ModalPlacement.top
          ? position.dy - AIScribeSizes.modalWithoutContentSpacing
          : position.dy;

      return PointerInterceptor(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: Navigator.of(context).pop,
          child: Stack(
            children: [
              PositionedDirectional(
                start: position.dx,
                top: top,
                child: dialogContent,
              ),
            ],
          ),
        ),
      );
    }

    return Center(child: dialogContent);
  }
}
