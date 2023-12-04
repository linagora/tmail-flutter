
import 'dart:io';

import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:jmap_dart_client/jmap/push/type_state.dart';

enum OffsetTimeUnit {
  year,
  month,
  day,
  hour,
  minute,
  second
}

class FcmUtils {
  FcmUtils._internal();

  static final FcmUtils _instance = FcmUtils._internal();

  static FcmUtils get instance => _instance;

  static const String hashCodeKey = 'TeamMail';
  static final List<TypeName> defaultFirebaseRegistrationTypes = [
    TypeName.emailType,
    TypeName.mailboxType,
    TypeName.emailDelivery
  ];

  StateChange? convertFirebaseDataMessageToStateChange(Map<String, dynamic> dataMessage) {
    log('FcmUtils::convertFirebaseDataMessageToStateChange():dataMessage: $dataMessage');
    Map<String, dynamic> mapData;
    if (dataMessage.containsKey('data')) {
      mapData = dataMessage['data'];
    } else {
      mapData = dataMessage;
    }

    final listKeys = mapData.keys;
    Map<AccountId, TypeState> mapTypeStateChanged = {};

    for (var key in listKeys) {
      final tupleKey = _parseFromKeyFirebaseDataMessage(key);
      final accountId = tupleKey.value1;
      final typeName = tupleKey.value2;
      final value = mapData[key];

      if (accountId == null || typeName == null || isEmpty(value)) {
        log('FcmUtils::convertFirebaseDataMessageToStateChange(): key or value is null');
        continue;
      }

      if (mapTypeStateChanged.containsKey(accountId)) {
        mapTypeStateChanged[accountId]!.typeState[typeName.value] = value;
      } else {
        mapTypeStateChanged[accountId] = TypeState({typeName.value: value});
      }
    }

    if (mapTypeStateChanged.isEmpty) {
      return null;
    } else {
      return StateChange('StateChange', mapTypeStateChanged);
    }
  }

  Tuple2<AccountId?, TypeName?> _parseFromKeyFirebaseDataMessage(String key) {
    if (_keyFirebaseDataMessageIsValid(key)) {
      final listObject = key.split(':');
      final accountId = AccountId(Id(listObject.first));
      final typeName = TypeName(listObject.last);
      return Tuple2(accountId, typeName);
    } else {
      return const Tuple2(null, null);
    }
  }

  bool _keyFirebaseDataMessageIsValid(String key) {
    if (key.contains(':')) {
      return key.split(':').length == 2;
    } else {
      return false;
    }
  }

  bool isEmpty(dynamic object) {
    return object == null || (object is String && object.isEmpty);
  }

  String get platformOS {
    var platformName = '';
    if (PlatformInfo.isWeb) {
      platformName = 'Web';
    } else {
      if (Platform.isAndroid) {
        platformName = 'Android';
      } else if (Platform.isIOS) {
        platformName = 'IOS';
      } else if (Platform.isFuchsia) {
        platformName = 'Fuchsia';
      } else if (Platform.isLinux) {
        platformName = 'Linux';
      } else if (Platform.isMacOS) {
        platformName = 'MacOS';
      } else if (Platform.isWindows) {
        platformName = 'Windows';
      }
    }
    log('FcmUtils::platformOS():$platformName');
    return platformName;
  }

  String hashTokenToDeviceId(String token) {
    final tokenHashCode = token.hashCode.toString();
    final deviceId = '$hashCodeKey-$platformOS-$tokenHashCode';
    log('FcmUtils::hashCodeTokenToDeviceId():deviceId: $deviceId');
    return deviceId;
  }

  bool get isMobileAndroid => PlatformInfo.isMobile && Platform.isAndroid;

  bool checkExpirationTimeWithinGivenPeriod({
    required DateTime expiredTime,
    required DateTime currentTime,
    required int limitOffsetTime,
    required OffsetTimeUnit offsetTimeUnit
  }) {
    if (currentTime.isBefore(expiredTime)) {
      log('FcmUtils::checkExpiredTimeWithOffsetTime: currentTime BEFORE expiredTime');
      int offsetTime = 0;
      switch(offsetTimeUnit) {
        case OffsetTimeUnit.minute:
          offsetTime = expiredTime.minutesBetween(currentTime);
          break;
        case OffsetTimeUnit.day:
          offsetTime = expiredTime.daysBetween(currentTime);
          break;
        default:
          break;
      }
      log('FcmUtils::checkExpiredTimeWithOffsetTime:offsetTime: $offsetTime');
      return offsetTime <= limitOffsetTime;
    } else {
      log('FcmUtils::checkExpiredTimeWithOffsetTime: currentTime AFTER expiredTime');
      return true;
    }
  }
}