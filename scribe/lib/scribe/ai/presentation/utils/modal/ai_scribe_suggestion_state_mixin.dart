import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scribe/scribe.dart';
import 'package:scribe/scribe/ai/data/network/ai_api_exception.dart';

mixin AiScribeSuggestionStateMixin<T extends StatefulWidget> on State<T> {
  GenerateAITextInteractor? get interactor => _interactor;
  GenerateAITextInteractor? _interactor;

  ValueNotifier<dartz.Either<Failure, Success>> get suggestionState => _suggestionState;
  final ValueNotifier<dartz.Either<Failure, Success>> _suggestionState =
      ValueNotifier(dartz.Right(GenerateAITextLoading()));

  AIAction get aiAction;
  String? get content;
  ImagePaths get imagePaths;
  OnSelectAiScribeSuggestionAction get onSelectAction;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<GenerateAITextInteractor>()) {
      _suggestionState.value = dartz.Left(
        GenerateAITextFailure(
          GenerateAITextInteractorIsNotRegisteredException(),
        ),
      );
      return;
    }

    _interactor = Get.find<GenerateAITextInteractor>();
    loadSuggestion();
  }

  Future<void> loadSuggestion() async {
    _suggestionState.value = dartz.Right(GenerateAITextLoading());

    final result = await _interactor!.execute(
      aiAction,
      content,
    );

    if (!mounted) return;

    result.fold(
      (failure) => _suggestionState.value = dartz.Left(failure),
      (success) => _suggestionState.value = dartz.Right(success),
    );
  }

  Widget buildStateContent(
    BuildContext context,
    ScribeLocalizations localizations,
  ) {
    return ValueListenableBuilder<dartz.Either<Failure, Success>>(
      valueListenable: _suggestionState,
      builder: (_, stateValue, __) {
        return stateValue.fold(
          (failure) => buildErrorState(localizations),
          (value) {
            if (value is GenerateAITextSuccess) {
              final hasContent = content?.trim().isNotEmpty == true;

              return buildSuccessState(
                value.response.result,
                hasContent,
                localizations,
              );
            }
            return buildLoadingState(localizations);
          },
        );
      },
    );
  }

  Widget buildLoadingState(ScribeLocalizations localizations) {
    return AiScribeSuggestionLoading(
      imagePaths: imagePaths,
    );
  }

  Widget buildErrorState(ScribeLocalizations localizations) {
    return AiScribeSuggestionError(
      imagePaths: imagePaths,
    );
  }

  Widget buildSuccessState(
    String suggestionText,
    bool hasContent,
    ScribeLocalizations localizations,
  ) {
    return AiScribeSuggestionSuccess(
      imagePaths: imagePaths,
      suggestionText: suggestionText,
      hasContent: hasContent,
      onSelectAction: onSelectAction,
    );
  }

  @override
  void dispose() {
    _suggestionState.dispose();
    super.dispose();
  }
}
