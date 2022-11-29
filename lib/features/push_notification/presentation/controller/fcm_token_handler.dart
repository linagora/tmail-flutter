
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_token.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_firebase_subscription_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_firebase_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_device_id_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class FcmTokenHandler {

  FcmTokenHandler._internal();

  static final FcmTokenHandler _instance = FcmTokenHandler._internal();

  static FcmTokenHandler get instance => _instance;

  StoreDeviceIdInteractor? _storeDeviceIdInteractor;
  GetFirebaseSubscriptionInteractor? _getFirebaseSubscriptionInteractor;

  FirebaseToken? _fcmToken;
  String? _deviceId;

  void initialize() {
    try {
      _storeDeviceIdInteractor = getBinding<StoreDeviceIdInteractor>();
      _getFirebaseSubscriptionInteractor = getBinding<GetFirebaseSubscriptionInteractor>();
    } catch (e) {
      logError('FcmTokenHandler::initialize(): ${e.toString()}');
    }
  }

  void handle(String? token) {
    log('FcmTokenHandler::handle():token: $token');
    if (token != null) {
      _fcmToken = FirebaseToken(token);
      _deviceId = FcmUtils.instance.hashTokenToDeviceId(token);
      log('FcmTokenHandler::handle(): fcmToken: $_fcmToken');
      log('FcmTokenHandler::handle(): deviceId: $_deviceId');
      _getFcmTokenFromBackend(_deviceId!);
    }
  }

  void _getFcmTokenFromBackend(String deviceId) {
    if (_getFirebaseSubscriptionInteractor != null) {
      _consumeState(_getFirebaseSubscriptionInteractor!.execute(deviceId));
    }
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
    if (failure is GetFirebaseSubscriptionFailure) {
      // Register new token
    }
  }

  void _handleSuccessViewState(Success success) {
    log('FcmTokenHandler::_handleSuccessViewState(): $success');
    if (success is GetFirebaseSubscriptionSuccess) {
      final token = success.firebaseSubscription.token;
      log('FcmTokenHandler::_handleSuccessViewState():token: $token');
    }
  }
}