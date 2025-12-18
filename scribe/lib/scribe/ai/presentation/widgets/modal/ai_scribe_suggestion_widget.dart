import 'dart:math';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/data/network/ai_api_exception.dart';

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

class _AiScribeSuggestionWidgetState extends State<AiScribeSuggestionWidget> {
  GenerateAITextInteractor? _interactor;

  final ValueNotifier<dartz.Either<Failure, Success>> _state =
      ValueNotifier(dartz.Right(GenerateAITextLoading()));

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<GenerateAITextInteractor>()) {
      _state.value = dartz.Left(
        GenerateAITextFailure(
          GenerateAITextInteractorIsNotRegisteredException(),
        ),
      );
      return;
    }

    _interactor = Get.find<GenerateAITextInteractor>();
    _loadSuggestion();
  }

  Future<void> _loadSuggestion() async {
    final result = await _interactor!.execute(
      widget.aiAction,
      widget.content,
    );

    result.fold(
      (failure) => _state.value = dartz.Left(failure),
      (success) => _state.value = dartz.Right(success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final modalWidth = min(
      screenSize.width * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxWidth,
    );

    final modalMaxHeight = min(
      screenSize.height * AIScribeSizes.mobileFactor,
      AIScribeSizes.suggestionModalMaxHeight,
    );

    final dialogContent = _buildDialogContent(context);

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
      screenSize: screenSize,
      anchorPosition: widget.buttonPosition!,
      anchorSize: widget.buttonSize!,
      modalMaxHeight: modalMaxHeight,
      preferredPlacement: widget.preferredPlacement,
    );

    return PointerInterceptor(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleClickOutside,
        child: Stack(
          children: [
            PositionedDirectional(
              start: layout.offset.dx,
              top: layout.top,
              bottom: layout.bottom,
              child: _buildModalContainer(
                width: modalWidth,
                maxHeight: layout.availableHeight,
                child: dialogContent,
              ),
            ),
          ],
        ),
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
          child: ValueListenableBuilder<dartz.Either<Failure, Success>>(
            valueListenable: _state,
            builder: (_, state, __) {
              return state.fold(
                (_) => AiScribeSuggestionError(
                  imagePaths: widget.imagePaths,
                ),
                (value) {
                  if (value is GenerateAITextSuccess) {
                    return AiScribeSuggestionSuccess(
                      imagePaths: widget.imagePaths,
                      suggestionText: value.response.result,
                      onSelectAction: widget.onSelectAiScribeSuggestionAction,
                    );
                  }

                  return AiScribeSuggestionLoading(
                    imagePaths: widget.imagePaths,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModalContainer({
    required double width,
    required double maxHeight,
    required Widget child,
  }) {
    return Container(
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
    );
  }

  bool get _hasAnchor =>
      widget.buttonPosition != null && widget.buttonSize != null;

  void _handleClickOutside() {
    final result = _state.value.getOrElse(() => UIState.idle);
    if (result is GenerateAITextSuccess || result is GenerateAITextFailure) {
      Navigator.of(context).pop();
    }
  }
}
