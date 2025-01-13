
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_preview_email_content_shared_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_preview_email_eml_content_shared_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class EmailPreviewerController extends BaseController {

  final GetPreviewEmailEMLContentSharedInteractor _getPreviewEmailEMLContentSharedInteractor;

  EmailPreviewerController(
    this._getPreviewEmailEMLContentSharedInteractor,
  );

  @override
  void onReady() {
    super.onReady();
    _getPreviewEmailEMLContentShared();
  }

  void _getPreviewEmailEMLContentShared() {
    final parameters = Get.parameters;

    if (parameters.isEmpty) {
      consumeState(Stream.value(Left(GetPreviewEmailEMLContentSharedFailure(
          NotFoundBlobIdException([])))));
      return;
    }

    final keyStored = parameters[RouteUtils.paramID];
    if (keyStored?.trim().isNotEmpty == true) {
      consumeState(_getPreviewEmailEMLContentSharedInteractor.execute(keyStored!));
    } else {
      consumeState(Stream.value(Left(GetPreviewEmailEMLContentSharedFailure(
          NotFoundBlobIdException([])))));
    }
  }
}