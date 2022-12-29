
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
import 'package:tmail_ui_user/features/push_notification/domain/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_fcm_subscription_local.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_firebase_subscription_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/register_new_token_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_fcm_subscription_local_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_firebase_subscription_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/register_new_token_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_subscription_interator.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class FcmTokenHandler {

  FcmTokenHandler._internal();

  static final FcmTokenHandler _instance = FcmTokenHandler._internal();

  static FcmTokenHandler get instance => _instance;

  static const int limitedTimeToExpire = 3;
  static const int extensionTimeExpire = 7;

  StoreSubscriptionInteractor? _storeSubscriptionInteractor;
  GetFirebaseSubscriptionInteractor? _getFirebaseSubscriptionInteractor;
  RegisterNewTokenInteractor? _registerNewTokenInteractor;
  GetFCMSubscriptionLocalInteractor? _getFCMSubscriptionLocalInteractor;

  FirebaseToken? _fcmToken;
  DeviceClientId? _deviceClientId;

  void initialize() {
    try {
      _storeSubscriptionInteractor = getBinding<StoreSubscriptionInteractor>();
      _getFirebaseSubscriptionInteractor = getBinding<GetFirebaseSubscriptionInteractor>();
      _registerNewTokenInteractor = getBinding<RegisterNewTokenInteractor>();
      _getFCMSubscriptionLocalInteractor = getBinding<GetFCMSubscriptionLocalInteractor>();
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
    } else {
      _getFCMSubscriptionLocalAction();
    }
  }

  void _getFcmTokenFromBackend(String deviceId) {
    if (_getFirebaseSubscriptionInteractor != null) {
      _consumeState(_getFirebaseSubscriptionInteractor!.execute(deviceId));
    }
  }

  void _storeSubscriptionAction(FCMSubscription fcmSubscription){
    if (_storeSubscriptionInteractor != null) {
      _consumeState(_storeSubscriptionInteractor!.execute(fcmSubscription));
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
      if (_fcmToken != null && _deviceClientId != null) {
        _handleRegisterNewToken(_fcmToken!, _deviceClientId!);
      }
    }
  }

  void _handleSuccessViewState(Success success) {
    log('FcmTokenHandler::_handleSuccessViewState(): $success');
    if (success is GetFirebaseSubscriptionSuccess) {
      _deviceClientId = success.firebaseSubscription.deviceClientId;
      final expireTime = success.firebaseSubscription.expires;
      log('FcmTokenHandler::_handleSuccessViewState():_fcmToken: $_fcmToken');
      if (_isTokenExpired(expireTime))  {
        log('FcmTokenHandler::_handleSuccessViewState(): _isTokenExpired true');
        _handleWhenTokenExpired();
      }
    } else if (success is RegisterNewTokenSuccess) {
      final deviceId = success.firebaseSubscription.deviceClientId?.value;
      final subscriptionId = success.firebaseSubscription.id?.id.value;
      if (deviceId != null && subscriptionId != null) {
        _storeSubscriptionAction(FCMSubscription(deviceId, subscriptionId));
      }
    } else if (success is GetFCMSubscriptionLocalSuccess) {
      _getFcmTokenFromBackend(success.fcmSubscription.deviceId);
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
        expireTimeLocal.daysBetween(currentTime) <= limitedTimeToExpire;
    } else {
      return true;
    }
  }

  void _handleWhenTokenExpired() {
    if (_fcmToken == null || _deviceClientId == null) {
      log('FcmTokenHandler::_handleSuccessViewState():_fcmToken or _deviceClientId is null');
      return;
    }

    final generateCreationId = Id(const Uuid().v4());
    final newExpireTime = DateTime.now().add(const Duration(days: extensionTimeExpire));

    log('FcmTokenHandler::_handleSuccessViewState():newExpireTime: $newExpireTime');
    final firebaseSubscription = FirebaseSubscription(
        token: _fcmToken!,
        expires: FirebaseExpiredTime(newExpireTime.toUTCDate()!),
        deviceClientId: _deviceClientId!,
        types: [TypeName.emailType, TypeName.mailboxType, TypeName.emailDelivery]
    );

    log('FcmTokenHandler::_handleSuccessViewState():firebaseSubscription: $firebaseSubscription');
    _invokeRegisterNewTokenAction(RegisterNewTokenRequest(
      generateCreationId,
      firebaseSubscription
    ));
  }

  void _handleRegisterNewToken(FirebaseToken fcmToken, DeviceClientId deviceClientId) {
    final generateCreationId = Id(const Uuid().v4());
    final firebaseSubscription = FirebaseSubscription(
      token: fcmToken,
      deviceClientId: deviceClientId,
      types: [TypeName.emailType, TypeName.mailboxType, TypeName.emailDelivery]
    );
    log('FcmTokenHandler::_handleSuccessViewState():firebaseSubscription: $firebaseSubscription');
    _invokeRegisterNewTokenAction(RegisterNewTokenRequest(
      generateCreationId,
      firebaseSubscription
    ));
  }

  void _invokeRegisterNewTokenAction(RegisterNewTokenRequest newTokenRequest) {
    if (_registerNewTokenInteractor != null) {
      _consumeState(_registerNewTokenInteractor!.execute(newTokenRequest));
    }
  }

  void _getFCMSubscriptionLocalAction() {
    if (_getFCMSubscriptionLocalInteractor != null) {
      _consumeState(_getFCMSubscriptionLocalInteractor!.execute());
    }
  }
}