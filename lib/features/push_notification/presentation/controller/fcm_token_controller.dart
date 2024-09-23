
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/fcm_token.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_expired_time.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_firebase_registration_by_device_id_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_firebase_registration_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/register_new_firebase_registration_token_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_firebase_registration_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_firebase_registration_by_device_id_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_firebase_registration_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/register_new_firebase_registration_token_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_firebase_registration_interator.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/update_firebase_registration_token_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/push_base_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class FcmTokenController extends PushBaseController {

  FcmTokenController._internal();

  static final FcmTokenController _instance = FcmTokenController._internal();

  static FcmTokenController get instance => _instance;

  static const int limitedTimeToExpire = 3;
  static const int extensionTimeExpire = 7;

  StoreFirebaseRegistrationInteractor? _storeFirebaseRegistrationInteractor;
  GetFirebaseRegistrationByDeviceIdInteractor? _getFirebaseRegistrationByDeviceIdInteractor;
  RegisterNewFirebaseRegistrationTokenInteractor? _registerNewFirebaseRegistrationTokenInteractor;
  GetStoredFirebaseRegistrationInteractor? _getStoredFirebaseRegistrationInteractor;
  UpdateFirebaseRegistrationTokenInteractor? _updateFirebaseRegistrationTokenInteractor;
  DeleteFirebaseRegistrationCacheInteractor? _deleteFirebaseRegistrationCacheInteractor;

  void initialBindingInteractor() {
    _storeFirebaseRegistrationInteractor = getBinding<StoreFirebaseRegistrationInteractor>();
    _getFirebaseRegistrationByDeviceIdInteractor = getBinding<GetFirebaseRegistrationByDeviceIdInteractor>();
    _registerNewFirebaseRegistrationTokenInteractor = getBinding<RegisterNewFirebaseRegistrationTokenInteractor>();
    _getStoredFirebaseRegistrationInteractor = getBinding<GetStoredFirebaseRegistrationInteractor>();
    _updateFirebaseRegistrationTokenInteractor = getBinding<UpdateFirebaseRegistrationTokenInteractor>();
    _deleteFirebaseRegistrationCacheInteractor = getBinding<DeleteFirebaseRegistrationCacheInteractor>();
  }

  void onFcmTokenChanged(String? newToken) {
    log('FcmTokenController::onFcmTokenChanged():newToken: $newToken');
    if (newToken != null) {
      _getFirebaseRegistrationFromServer(
        newFcmToken: FcmToken(newToken),
        deviceClientId: DeviceClientId(FcmUtils.instance.hashTokenToDeviceId(newToken))
      );
    } else {
      _getStoredFirebaseRegistrationFromCache();
    }
  }

  void _getFirebaseRegistrationFromServer({
    required DeviceClientId deviceClientId,
    FcmToken? newFcmToken
  }) {
    if (_getFirebaseRegistrationByDeviceIdInteractor != null) {
      consumeState(
        _getFirebaseRegistrationByDeviceIdInteractor!.execute(
          deviceClientId: deviceClientId,
          newFcmToken: newFcmToken
        )
      );
    } else if (newFcmToken != null) {
      _registerNewFirebaseRegistrationToken(newFcmToken);
    }
  }

  void _getStoredFirebaseRegistrationFromCache() {
    if (_getStoredFirebaseRegistrationInteractor != null) {
      consumeState(_getStoredFirebaseRegistrationInteractor!.execute());
    }
  }

  void _storeFirebaseRegistrationToCache(FirebaseRegistration firebaseRegistration){
    if (_storeFirebaseRegistrationInteractor != null) {
      consumeState(_storeFirebaseRegistrationInteractor!.execute(firebaseRegistration));
    }
  }

  bool _isFirebaseRegistrationTokenExpired(FirebaseRegistration firebaseRegistration) {
    log('FcmTokenController::_isFirebaseRegistrationTokenExpired():firebaseRegistration: $firebaseRegistration');
    if (firebaseRegistration.expires != null) {
      final expireTimeLocal = firebaseRegistration.expires!.value.value.toLocal();
      final currentTime = DateTime.now();
      log('FcmTokenController::_validateFirebaseRegistrationTokenExpired():expireTimeLocal: $expireTimeLocal | currentTime: $currentTime');
      return FcmUtils.instance.checkExpirationTimeWithinGivenPeriod(
        expiredTime: expireTimeLocal,
        currentTime: currentTime,
        limitOffsetTime: limitedTimeToExpire,
        offsetTimeUnit: BuildUtils.isDebugMode
          ? OffsetTimeUnit.minute
          : OffsetTimeUnit.day
      );
    } else {
      return true;
    }
  }

  void _updateNewExpiredTimeForFirebaseRegistration(FirebaseRegistration firebaseRegistration) {
    log('FcmTokenController::_updateNewExpiredTimeForFirebaseRegistration():firebaseRegistration: $firebaseRegistration');
    if (_updateFirebaseRegistrationTokenInteractor != null && firebaseRegistration.id != null) {
      final newExpiredTime = DateTime.now().add(const Duration(days: extensionTimeExpire));
      consumeState(
        _updateFirebaseRegistrationTokenInteractor!.execute(
          UpdateTokenExpiredTimeRequest(
            firebaseRegistration.id!,
            FirebaseRegistrationExpiredTime(UTCDate(newExpiredTime)),
          )
        )
      );
    }
  }

  void _registerNewFirebaseRegistrationToken(FcmToken fcmToken) {
    final generateCreationId = Id(const Uuid().v4());
    final firebaseRegistration = FirebaseRegistration(
      token: fcmToken,
      deviceClientId: DeviceClientId(FcmUtils.instance.hashTokenToDeviceId(fcmToken.value)),
      types: FcmUtils.defaultFirebaseRegistrationTypes
    );
    log('FcmTokenController::_registerNewFirebaseRegistrationToken():generateCreationId: $generateCreationId | firebaseRegistration: $firebaseRegistration');
    if (_registerNewFirebaseRegistrationTokenInteractor != null) {
      consumeState(
        _registerNewFirebaseRegistrationTokenInteractor!.execute(
          RegisterNewTokenRequest(
            generateCreationId,
            firebaseRegistration
          )
        )
      );
    }
  }
  
  void _deleteFirebaseRegistrationInCache() {
    if (_deleteFirebaseRegistrationCacheInteractor != null) {
      consumeState(_deleteFirebaseRegistrationCacheInteractor!.execute());
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('FcmTokenController::_handleFailureViewState(): $failure');
    if (failure is GetFirebaseRegistrationByDeviceIdFailure && failure.newFcmToken != null) {
      _registerNewFirebaseRegistrationToken(failure.newFcmToken!);
    } else if (failure is RegisterNewFirebaseRegistrationTokenFailure) {
      _deleteFirebaseRegistrationInCache();
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    log('FcmTokenController::_handleSuccessViewState(): $success');
    if (success is GetFirebaseRegistrationByDeviceIdSuccess &&
        _isFirebaseRegistrationTokenExpired(success.firebaseRegistration)) {
      _updateNewExpiredTimeForFirebaseRegistration(success.firebaseRegistration);
    } else if (success is GetStoredFirebaseRegistrationSuccess) {
      _getFirebaseRegistrationFromServer(deviceClientId: success.firebaseRegistration.deviceClientId!);
    } else if (success is RegisterNewFirebaseRegistrationTokenSuccess) {
      _storeFirebaseRegistrationToCache(success.firebaseRegistration);
    }
  }
}