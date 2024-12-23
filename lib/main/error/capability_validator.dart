import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/main/error/request_error.dart';

void requireCapability(Session session, AccountId accountId, List<CapabilityIdentifier> requiredCapabilities) {
  final account = session.accounts[accountId];
  if (account == null) {
    throw const InvalidCapability();
  }

  final matchedCapabilities = account.accountCapabilities.keys
      .fold<Set<CapabilityIdentifier>>(
        <CapabilityIdentifier>{},
        (previousValue, element) {
          if (requiredCapabilities.contains(element)) {
            previousValue.add(element);
          }
          return previousValue;
        }
      );
  final missingCapabilities = requiredCapabilities.toSet().difference(matchedCapabilities);
  if (missingCapabilities.isNotEmpty) {
    throw SessionMissingCapability(missingCapabilities);
  }
}

extension ListCapabilityIdentifierExtension on List<CapabilityIdentifier> {

  bool isSupported(Session session, AccountId accountId) {
    try {
      requireCapability(session, accountId, this);
      return true;
    } catch (error) {
      logError('ListCapabilityIdentifierExtension::isSupported(): $error');
      return false;
    }
  }
}

extension CapabilityIdentifierExtension on CapabilityIdentifier {

  static const int defaultMaxCallsInRequest = 1;
  static const int defaultMaxObjectsInSet = 50;

  bool isSupported(Session session, AccountId accountId) {
    try {
      requireCapability(session, accountId, [this]);
      return true;
    } catch (error) {
      logError('CapabilityIdentifierExtension::isSupported(): $error');
      return false;
    }
  }
}

extension CapabilityIdentifierSetExtension on Set<CapabilityIdentifier> {

  Set<CapabilityIdentifier> toCapabilitiesSupportTeamMailboxes(Session session, AccountId accountId) {
    try {
      requireCapability(session, accountId, [CapabilityIdentifier.jmapTeamMailboxes]);
      add(CapabilityIdentifier.jmapTeamMailboxes);
      return this;
    } catch (error) {
      logError('CapabilityIdentifierExtension::toCapabilitiesSupportTeamMailboxes(): $error');
      return this;
    }
  }
}