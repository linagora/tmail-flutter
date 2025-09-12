import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

mixin SaaSPremiumMixin {
  bool isPremiumAvailable({Session? session, AccountId? accountId}) {
    if (accountId == null || session == null) {
      return false;
    }
    final saasAccount = session.getSaaSAccountCapability(accountId);
    return saasAccount?.isPremiumAvailable ?? false;
  }

  bool isAlreadyHighestSubscription({Session? session, AccountId? accountId}) {
    if (accountId == null || session == null) {
      return false;
    }
    final saasAccount = session.getSaaSAccountCapability(accountId);
    return saasAccount?.isAlreadyHighestSubscription ?? false;
  }
}
