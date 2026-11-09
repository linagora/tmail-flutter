import 'dart:convert';

/// A null or empty group key is kept: Android's listing has no payload, and
/// the username group also holds the personal account's notifications.
bool notificationGroupIsThisUser(String? groupKey, String userName) {
  if (userName.isEmpty) return false;
  if (groupKey == null || groupKey.isEmpty) return true;
  return groupKey == userName;
}

/// A notification without a payload is kept. Android's active listing does
/// not return one, so the username group is not cleared.
///
/// [payload] is NotificationPayload JSON (`emailId`, `newState` only).
bool payloadNamesEmail(String? payload, Set<String> emailIds) {
  if (payload == null || payload.isEmpty) return false;
  final Object? decoded;
  try {
    decoded = jsonDecode(payload);
  } catch (_) {
    return false;
  }
  if (decoded is! Map) return false;
  final emailId = decoded['emailId'];
  return emailId is String && emailId.isNotEmpty && emailIds.contains(emailId);
}
