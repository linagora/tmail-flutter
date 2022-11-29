
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_token.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_device_id_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';

class FcmTokenHandler {

  FcmTokenHandler._internal();

  static final FcmTokenHandler _instance = FcmTokenHandler._internal();

  static FcmTokenHandler get instance => _instance;

  StoreDeviceIdInteractor? _storeDeviceIdInteractor;

  void initialize() {
    try {
      _storeDeviceIdInteractor = Get.find<StoreDeviceIdInteractor>();
    } catch (e) {
      logError('FcmTokenHandler::initialize(): ${e.toString()}');
    }
  }

  void handle(String token) {
    log('FcmTokenHandler::handle():token: $token');
    final fcmToken = FirebaseToken(token);
    final deviceId = FcmUtils.instance.hashTokenToDeviceId(token);
    log('FcmTokenHandler::handle(): fcmToken: $fcmToken');
    log('FcmTokenHandler::handle(): deviceId: $deviceId');
    _storeDeviceIdAction(deviceId);
  }

  void _storeDeviceIdAction(String deviceId) {
    if (_storeDeviceIdInteractor != null) {
      _consumeState(_storeDeviceIdInteractor!.execute(deviceId));
    }
  }

  void _consumeState(Stream<Either<Failure, Success>> newStateStream) {
    newStateStream.listen(
      _handleStateStream,
      onError: (error, stackTrace) {
        logError('FcmTokenHandler::consumeState():onError:error: $error');
        logError('FcmTokenHandler::consumeState():onError:stackTrace: $stackTrace');
      }
    );
  }

  void _handleStateStream(Either<Failure, Success> newState) {
    newState.fold(_handleFailureViewState, _handleSuccessViewState);
  }

  void _handleFailureViewState(Failure failure) {
    log('FcmTokenHandler::_handleFailureViewState(): $failure');
  }

  void _handleSuccessViewState(Success success) {
    log('FcmTokenHandler::_handleSuccessViewState(): $success');
  }
}