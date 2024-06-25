import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';

abstract class ConsumeViewStateUIController extends GetxController
    with MessageDialogActionMixin, PopupContextMenuActionMixin {

  final viewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  void consumeState(Stream<Either<Failure, Success>> newStateStream) {
    newStateStream.listen(onData, onError: onError, onDone: onDone);
  }

  void dispatchState(Either<Failure, Success> newState) {
    viewState.value = newState;
  }

  void clearState() {
    viewState.value = Right(UIState.idle);
  }

  void onData(Either<Failure, Success> newState) {
    viewState.value = newState;
    viewState.value.fold(handleFailureViewState, handleSuccessViewState);
  }

  void onError(Object error, StackTrace stackTrace) {}

  void onDone() {}

  void handleFailureViewState(Failure failure);

  void handleSuccessViewState(Success success);
}