import 'dart:convert';

/// A null or empty group key is kept: Android's listing has no payload, and
/// the username group also holds the personal account's notifications.
bool notificationGroupIsThisUser(String? groupKey, String userName) {
  if (userName.isEmpty) return false;
  if (groupKey == null || groupKey.isEmpty) return true;
  return groupKey == userName;
}

/// Android lists active notifications without their payload, so a delegated one also carries its account id as [tag].
bool notificationNamesAccountOrEmail({
  required String? tag,
  required String? payload,
  required String accountId,
  required Set<String> emailIds,
}) =>
    (accountId.isNotEmpty && tag == accountId) || payloadNamesAccountOrEmail(payload, accountId, emailIds);

/// A notification without a payload is kept, so the username group is not cleared.
///
/// [payload] is NotificationPayload JSON: it matches when its `accountId` is
/// [accountId] or its `emailId` is in [emailIds].
bool payloadNamesAccountOrEmail(String? payload, String accountId, Set<String> emailIds) {
  if (payload == null || payload.isEmpty) return false;
  final Object? decoded;
  try {
    decoded = jsonDecode(payload);
  } catch (_) {
    return false;
  }
  if (decoded is! Map) return false;
  if (decoded['accountId'] == accountId) return true;
  final emailId = decoded['emailId'];
  return emailId is String && emailId.isNotEmpty && emailIds.contains(emailId);
}
