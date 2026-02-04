import 'dart:math' hide log;

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

mixin SessionMixin {
  int getMaxObjectsInSetMethod(Session session, AccountId accountId) {
    final coreCapability = session.getCapabilityProperties<CoreCapability>(
      accountId,
      CapabilityIdentifier.jmapCore,
    );
    final maxObjectsInSetMethod =
        coreCapability?.maxObjectsInSet?.value.toInt() ??
            CapabilityIdentifierExtension.defaultMaxObjectsInSet;

    final minOfMaxObjectsInSetMethod = min(
      maxObjectsInSetMethod,
      CapabilityIdentifierExtension.defaultMaxObjectsInSet,
    );
    log('$runtimeType::getMaxObjectsInSetMethod:minOfMaxObjectsInSetMethod = $minOfMaxObjectsInSetMethod');
    return minOfMaxObjectsInSetMethod;
  }

  int getMaxObjectsInGetMethod(Session session, AccountId accountId) {
    final maxObjectsInGetMethod =
        session.getMaxObjectsInGet(accountId)?.value.toInt() ??
            CapabilityIdentifierExtension.defaultMaxObjectsInGet;

    final minOfMaxObjectsInGetMethod = min(
      maxObjectsInGetMethod,
      CapabilityIdentifierExtension.defaultMaxObjectsInGet,
    );
    log('$runtimeType::getMaxObjectsInGetMethod:minOfMaxObjectsInGetMethod = $minOfMaxObjectsInGetMethod');
    return minOfMaxObjectsInGetMethod;
  }
}
