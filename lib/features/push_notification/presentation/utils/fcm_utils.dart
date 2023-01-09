
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:jmap_dart_client/jmap/push/type_state.dart';

class FcmUtils {
  FcmUtils._internal();

  static final FcmUtils _instance = FcmUtils._internal();

  static FcmUtils get instance => _instance;

  static const String hashCodeKey = 'TeamMail';

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
    if (BuildUtils.isWeb) {
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
}