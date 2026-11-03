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
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_load.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';

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

  SwitchAttemptStamp _stampShownAccountRequest() => SwitchAttemptStamp(activeAccountSource);

  /// Drops what arrives once its switch attempt ended or this controller closed.
  ShownAccountStateSubscription consumeShownAccountState(
    Stream<Either<Failure, Success>> viewResults, {
    ShownAccountLoadKind? reportAs,
  }) {
    final subscription = ShownAccountStateSubscription(
      stamp: _stampShownAccountRequest(),
      onData: onData,
      onError: onError,
      onDone: onDone,
      onStale: _reportEndedSession,
      onEnded: _shownAccountSubscriptions.remove,
    );
    _shownAccountSubscriptions.add(subscription);
    subscription.listen(viewResults);
    if (reportAs != null) {
      Get.find<ShownAccountLoadReporter>().reportLoad(reportAs, subscription.load);
    }
    return subscription;
  }

  /// The last result of [viewResults]. Once its switch attempt ended, a result or an error throws
  /// [_ShownAccountChanged] instead, which stops the caller and [onError] drops.
  Future<Either<Failure, Success>> awaitShownAccountState(Stream<Either<Failure, Success>> viewResults) async {
    final stamp = _stampShownAccountRequest();
    final Either<Failure, Success> viewResult;
    try {
      viewResult = await viewResults.last;
    } catch (error) {
      if (stamp.isCurrent) rethrow;
      _reportEndedSession(error: error);
      throw const _ShownAccountChanged();
    }
    if (stamp.isCurrent) return viewResult;
    _reportEndedSession(viewResult: viewResult);
    throw const _ShownAccountChanged();
  }

  @override
  void onError(dynamic error, StackTrace stackTrace) {
    if (error is _ShownAccountChanged) return;
    super.onError(error, stackTrace);
  }

  /// A dead session ends every account, so a stale result still logs out on it.
  void _reportEndedSession({Either<Failure, Success>? viewResult, Object? error}) {
    final staleError = error ??
        viewResult?.fold((failure) => failure is FeatureFailure ? failure.exception : null, (_) => null);
    if (staleError is AuthenticationException && validateUrgentException(staleError)) {
      handleUrgentException(exception: staleError);
    }
  }

  /// The retry stream is bound to the account of the failed request, so a tap after its attempt
  /// ended only closes the toast.
  @override
  VoidCallback retryActionOf(Stream<Either<Failure, Success>> retry) {
    final stamp = _stampShownAccountRequest();
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

/// Thrown by [ShownAccountStateConsumer.awaitShownAccountState] in place of a stale result.
class _ShownAccountChanged implements Exception {
  const _ShownAccountChanged();

  @override
  String toString() => 'ShownAccountChanged';
}
