
import 'package:duration/duration.dart';
import 'package:email_recovery/email_recovery/capability_deleted_messages_vault.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';

extension SessionExtension on Session {

  String getRestorationHorizonAsString() {
    String restorationHorizon = 'restorationHorizon';
    String defaultHorizon = "15 days";

    return (getCapabilityProperties(accountId, capabilityDeletedMessagesVault)
        ?.props[0] as Map<String, dynamic>?)
        ?[restorationHorizon]
        ?? defaultHorizon;
  }

  Duration getRestorationHorizonAsDuration() {
    try {
      String horizonWithCorrectFormat = getRestorationHorizonAsString()
          .replaceAll(" days", "d")
          .replaceAll(" day", "d")
          .replaceAll(" hours", "h")
          .replaceAll(" hour", "h")
          .replaceAll(" minutes", "m")
          .replaceAll(" minute", "m")
          .replaceAll(" seconds", "s")
          .replaceAll(" second", "s")
          .replaceAll(" milliseconds", "ms")
          .replaceAll(" millisecond", "ms");

      return parseDuration(horizonWithCorrectFormat, separator: ' ');
    } catch (e) {
      return const Duration(days: 15);
    }
  }

  DateTime getRestorationHorizonAsDateTime() {
    return DateTime.now().subtract(getRestorationHorizonAsDuration());
  }
}