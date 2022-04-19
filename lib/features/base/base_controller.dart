import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';

abstract class BaseController extends GetxController with MessageDialogActionMixin, PopupContextMenuActionMixin {
  final viewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final connectivityResult = Rxn<ConnectivityResult>();
  FpsCallback? fpsCallback;

  void consumeState(Stream<Either<Failure, Success>> newStateStream) async {
    newStateStream.listen(
      (state) => onData(state),
      onError: (error) => onError(error),
      onDone: () => onDone()
    );
  }

  void dispatchState(Either<Failure, Success> newState) {
    viewState.value = newState;
  }

  void setNetworkConnectivityState(ConnectivityResult newConnectivityResult) {
    connectivityResult.value = newConnectivityResult;
  }

  bool isNetworkConnectionAvailable() {
    return connectivityResult.value != ConnectivityResult.none;
  }

  void getState(Future<Either<Failure, Success>> newStateStream) async {
    final state = await newStateStream;
    state.fold(
      (failure) => onError(failure),
      (success) => onData(state)
    );
  }

  void clearState() {
    viewState.value = Right(UIState.idle);
  }

  void onData(Either<Failure, Success> newState) {
    viewState.value = newState;
  }

  void onError(dynamic error);

  void onDone();

  void startFpsMeter() {
    FpsManager().start();
    fpsCallback = (fpsInfo) {
      log('BaseController::startFpsMeter(): $fpsInfo');
    };
    if (fpsCallback != null) {
      FpsManager().addFpsCallback(fpsCallback!);
    }
  }

  void stopFpsMeter() {
    FpsManager().stop();
    if (fpsCallback != null) {
      FpsManager().removeFpsCallback(fpsCallback!);
    }
  }
}