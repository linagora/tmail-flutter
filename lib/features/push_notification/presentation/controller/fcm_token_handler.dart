
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_expired_time.dart';
import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/firebase_token.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_firebase_subscription_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_firebase_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/register_new_token_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_device_id_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class FcmTokenHandler {

  FcmTokenHandler._internal();

  static final FcmTokenHandler _instance = FcmTokenHandler._internal();

  static FcmTokenHandler get instance => _instance;

  StoreDeviceIdInteractor? _storeDeviceIdInteractor;
  GetFirebaseSubscriptionInteractor? _getFirebaseSubscriptionInteractor;
  RegisterNewTokenInteractor? _registerNewTokenInteractor;

  FirebaseToken? _fcmToken;
  DeviceClientId? _deviceClientId;

  void initialize() {
    try {
      _storeDeviceIdInteractor = getBinding<StoreDeviceIdInteractor>();
      _getFirebaseSubscriptionInteractor = getBinding<GetFirebaseSubscriptionInteractor>();
      _registerNewTokenInteractor = getBinding<RegisterNewTokenInteractor>();
    } catch (e) {
      logError('FcmTokenHandler::initialize(): ${e.toString()}');
    }
  }

  void handle(String? token) {
    log('FcmTokenHandler::handle():token: $token');
    if (token != null) {
      _fcmToken = FirebaseToken(token);
      final deviceId = FcmUtils.instance.hashTokenToDeviceId(token);
      _deviceClientId = DeviceClientId(deviceId);
      log('FcmTokenHandler::handle(): fcmToken: $_fcmToken');
      log('FcmTokenHandler::handle(): deviceId: $deviceId');
      _getFcmTokenFromBackend(deviceId);
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
      _fcmToken = success.firebaseSubscription.token;
      _deviceClientId = success.firebaseSubscription.deviceClientId;
      final expireTime = success.firebaseSubscription.expires;
      log('FcmTokenHandler::_handleSuccessViewState():_fcmToken: $_fcmToken');
      if (_isTokenExpired(expireTime))  {
        _handleWhenTokenExpired(_fcmToken!, _deviceClientId!);
      }
    }
  }

  bool _isTokenExpired(FirebaseExpiredTime? expireTime) {
    log('FcmTokenHandler::_isTokenExpired():expireTime: $expireTime');
    if (expireTime != null) {
      final expireTimeLocal = expireTime.value.value.toLocal();
      final currentTime = DateTime.now();

      log('FcmTokenHandler::_isTokenExpired():expireTimeLocal: $expireTimeLocal');
      log('FcmTokenHandler::_isTokenExpired():currentTime: $currentTime');

      return currentTime.isBefore(expireTimeLocal) &&
        expireTimeLocal.daysBetween(currentTime) == 3;
    } else {
      return true;
    }
  }

  void _handleWhenTokenExpired(FirebaseToken fcmToken, DeviceClientId deviceClientId) {
    final generateCreationId = Id(const Uuid().v4());
    final newExpireTime = DateTime.now().add(const Duration(days: 7));

    log('FcmTokenHandler::_handleSuccessViewState():newExpireTime: $newExpireTime');
    final firebaseSubscription = FirebaseSubscription(
        token: fcmToken,
        expires: FirebaseExpiredTime(newExpireTime.toUTCDate()!),
        deviceClientId: deviceClientId,
        types: [TypeName.emailType, TypeName.mailboxType, TypeName.emailDelivery]
    );

    log('FcmTokenHandler::_handleSuccessViewState():firebaseSubscription: $firebaseSubscription');
    _registerNewTokenAction(RegisterNewTokenRequest(
        generateCreationId,
        firebaseSubscription
    ));
  }

  void _registerNewTokenAction(RegisterNewTokenRequest newTokenRequest) {
    if (_registerNewTokenInteractor != null) {
      _consumeState(_registerNewTokenInteractor!.execute(newTokenRequest));
    }
  }
}