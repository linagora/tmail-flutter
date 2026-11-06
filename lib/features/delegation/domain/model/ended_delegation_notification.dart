/// A null or empty group key is kept: Android's listing has no payload, and
/// the username group also holds the personal account's notifications.
bool notificationGroupIsThisUser(String? groupKey, String userName) {
  if (userName.isEmpty) return false;
  if (groupKey == null || groupKey.isEmpty) return true;
  return groupKey == userName;
}

/// A notification without a payload is kept. Android's active listing does
/// not return one, so the username group is not cleared.
bool payloadNamesAccountOrEmail(
  String? payload,
  String accountId,
  Set<String> emailIds,
) {
  if (accountId.isEmpty || payload == null || payload.isEmpty) return false;
  if (payload.contains(accountId)) return true;
  for (final emailId in emailIds) {
    if (emailId.isNotEmpty && payload.contains(emailId)) return true;
  }
  return false;
}
