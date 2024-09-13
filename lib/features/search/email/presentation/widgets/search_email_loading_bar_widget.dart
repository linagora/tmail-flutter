
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';

class SearchEmailLoadingBarWidget extends StatelessWidget with AppLoaderMixin {

  final Either<Failure, Success> resultSearchViewState;
  final Either<Failure, Success> suggestionViewState;

  const SearchEmailLoadingBarWidget({
    super.key,
    required this.resultSearchViewState,
    required this.suggestionViewState
  });

  @override
  Widget build(BuildContext context) {
    return resultSearchViewState.fold(
      (failure) {
        return suggestionViewState.fold(
          (failure) => const SizedBox.shrink(),
          (success) => success is LoadingState
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: loadingWidget
              )
            : const SizedBox.shrink()
        );
      },
      (success) {
        if (success is SearchingState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: loadingWidget
          );
        } else {
          return suggestionViewState.fold(
            (failure) => const SizedBox.shrink(),
            (success) => success is LoadingState
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: loadingWidget
                )
              : const SizedBox.shrink()
          );
        }
      }
    );
  }
}