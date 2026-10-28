import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/shown_account_state_subscription.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/switch_attempt_stamp.dart';

/// For a GetX class that reads the shown mailbox. Settings and other personal areas use my own
/// account and never mix it in. See ADR-0114.
mixin ActiveAccountReader {
  ActiveAccountSource get activeAccountSource => Get.find<ActiveAccountSource>();

  AccountId? get activeAccountId => activeAccountSource.accountId;

  /// Personal-only actions, such as an email rule filter, are hidden while this is true.
  bool get isDelegatedAccountShown => activeAccountSource.activeAccount?.isDelegated == true;
}

/// For a controller that loads the shown mailbox into its view.
mixin ShownAccountStateConsumer on BaseController, ActiveAccountReader {
  final _shownAccountSubscriptions = <ShownAccountStateSubscription>{};

  SwitchAttemptStamp stampShownAccountRequest() => SwitchAttemptStamp(activeAccountSource);

  /// Drops what arrives once its switch attempt ended or this controller closed.
  ShownAccountStateSubscription consumeShownAccountState(Stream<Either<Failure, Success>> viewResults) {
    final subscription = ShownAccountStateSubscription(
      stamp: stampShownAccountRequest(),
      onData: onData,
      onError: onError,
      onDone: onDone,
      onEnded: _shownAccountSubscriptions.remove,
    );
    _shownAccountSubscriptions.add(subscription);
    subscription.listen(viewResults);
    return subscription;
  }

  /// The retry stream is bound to the account of the failed request, so a tap after its attempt
  /// ended only closes the toast.
  @override
  VoidCallback retryActionOf(Stream<Either<Failure, Success>> retry) {
    final stamp = stampShownAccountRequest();
    return () {
      if (stamp.isCurrent) consumeShownAccountState(retry);
    };
  }

  @override
  void onClose() {
    for (final subscription in List.of(_shownAccountSubscriptions)) {
      subscription.cancel();
    }
    _shownAccountSubscriptions.clear();
    super.onClose();
  }
}
