
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/empty_emails_widget.dart';

class EmptySearchEmailWidget extends StatelessWidget {

  final Either<Failure, Success> resultSearchViewState;
  final Either<Failure, Success> suggestionViewState;
  final bool isNetworkConnectionAvailable;

  const EmptySearchEmailWidget({
    super.key,
    required this.resultSearchViewState,
    required this.suggestionViewState,
    required this.isNetworkConnectionAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return resultSearchViewState.fold(
      (failure) => _suggestionViewStateToUI(suggestionViewState),
      (success) {
        if (success is SearchingState) {
          return const SizedBox.shrink();
        } else {
          return _suggestionViewStateToUI(suggestionViewState);
        }
      }
    );
  }

  Widget _suggestionViewStateToUI(Either<Failure, Success> viewState) {
    return viewState.fold(
      (failure) => EmptyEmailsWidget(
        key: const Key('empty_search_email_view'),
        isNetworkConnectionAvailable: isNetworkConnectionAvailable,
        isSearchActive: true
      ),
      (success) {
        if (success is LoadingState) {
          return const SizedBox.shrink();
        } else {
          return EmptyEmailsWidget(
            key: const Key('empty_search_email_view'),
            isNetworkConnectionAvailable: isNetworkConnectionAvailable,
            isSearchActive: true
          );
        }
      }
    );
  }
}