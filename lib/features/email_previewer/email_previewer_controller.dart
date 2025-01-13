
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_email_eml_content_shared_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_eml_content_in_memory_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_eml_content_in_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_preview_eml_content_from_persistent_to_memory_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/remove_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class EmailPreviewerController extends BaseController {

  final GetPreviewEmailEMLContentSharedInteractor _getPreviewEmailEMLContentSharedInteractor;
  final MovePreviewEmlContentFromPersistentToMemoryInteractor _movePreviewEmlContentFromPersistentToMemoryInteractor;
  final RemovePreviewEmailEmlContentSharedInteractor _removePreviewEmailEmlContentSharedInteractor;
  final GetPreviewEmlContentInMemoryInteractor _getPreviewEmlContentInMemoryInteractor;

  final emlContentViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  EmailPreviewerController(
    this._getPreviewEmailEMLContentSharedInteractor,
    this._movePreviewEmlContentFromPersistentToMemoryInteractor,
    this._removePreviewEmailEmlContentSharedInteractor,
    this._getPreviewEmlContentInMemoryInteractor,
  );

  @override
  void onInit() {
    consumeState(Stream.value(Right(GettingPreviewEmailEMLContentShared())));
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _getPreviewEmailEMLContentShared();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GettingPreviewEmailEMLContentShared ||
        success is GettingPreviewEMLContentInMemory ||
        success is GetPreviewEMLContentInMemorySuccess) {
      emlContentViewState.value = Right(success);
    } else if (success is GetPreviewEmailEMLContentSharedSuccess) {
      emlContentViewState.value = Right(success);
      _movePreviewEmlContentFromPersistentToMemory(
          success.keyStored,
          success.previewEMLContent);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetPreviewEmailEMLContentSharedFailure) {
      emlContentViewState.value = Left(failure);

      if (failure.keyStored == null) return;

      if (failure.exception is NotFoundDataWithThisKeyException) {
        _getPreviewEMLContentInMemory(failure.keyStored!);
      } else {
        _removePreviewEmlContentShared(failure.keyStored!);
      }
    } else if (failure is GetPreviewEMLContentInMemoryFailure) {
      emlContentViewState.value = Left(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  void _getPreviewEmailEMLContentShared() {
    final parameters = Get.parameters;

    if (parameters.isEmpty) {
      consumeState(Stream.value(Left(GetPreviewEmailEMLContentSharedFailure(
          exception: NotFoundBlobIdException([])))));
      return;
    }

    final keyStored = parameters[RouteUtils.paramID];
    if (keyStored?.trim().isNotEmpty == true) {
      consumeState(_getPreviewEmailEMLContentSharedInteractor.execute(keyStored!));
    } else {
      consumeState(Stream.value(Left(GetPreviewEmailEMLContentSharedFailure(
          exception: NotFoundBlobIdException([])))));
    }
  }

  void _movePreviewEmlContentFromPersistentToMemory(
    String keyStored,
    String content,
  ) {
    consumeState(
      _movePreviewEmlContentFromPersistentToMemoryInteractor.execute(
        keyStored,
        content,
      ),
    );
  }

  void _removePreviewEmlContentShared(String keyStored) {
    consumeState(_removePreviewEmailEmlContentSharedInteractor.execute(keyStored));
  }

  void _getPreviewEMLContentInMemory(String keyStored) {
    consumeState(_getPreviewEmlContentInMemoryInteractor.execute(keyStored));
  }
}