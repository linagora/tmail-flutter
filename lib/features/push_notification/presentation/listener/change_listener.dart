
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';

abstract class ChangeListener {
  void dispatchActions(List<Action> actions);

  void consumeState(Stream<Either<Failure, Success>> newStateStream) {
    newStateStream.listen(
      _handleStateStream,
      onError: (error, stackTrace) {
        logError('ChangeListener::consumeState():onError:error: $error');
        logError('ChangeListener::consumeState():onError:stackTrace: $stackTrace');
      }
    );
  }

  void _handleStateStream(Either<Failure, Success> newState) {
    newState.fold(handleFailureViewState, handleSuccessViewState);
  }

  void handleFailureViewState(Failure failure) {}

  void handleSuccessViewState(Success success) {}
}