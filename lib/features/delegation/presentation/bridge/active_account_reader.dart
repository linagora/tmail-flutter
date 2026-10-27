import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';

/// For a GetX class that reads the shown mailbox. Settings and other personal areas use my own
/// account and never mix it in. See ADR-0114.
mixin ActiveAccountReader {
  ActiveAccountSource get activeAccountSource => Get.find<ActiveAccountSource>();

  AccountId? get activeAccountId => activeAccountSource.accountId;
}
