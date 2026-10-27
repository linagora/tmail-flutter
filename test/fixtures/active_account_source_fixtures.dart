import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/riverpod_active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

class ActiveAccountSourceFixtures {
  /// Registers a [RiverpodActiveAccountSource] on [container], or on its own container disposed after
  /// the test, that shows [shownAccountId] of [session], or my own account when it is null.
  static RiverpodActiveAccountSource put(
    Session session, {
    AccountId? shownAccountId,
    ProviderContainer? container,
  }) {
    final sourceContainer = container ?? newContainer();
    final source = RiverpodActiveAccountSource(sourceContainer)..applySession(session);
    if (shownAccountId != null) {
      sourceContainer.read(activeAccountProvider.notifier).select(shownAccountId);
    }
    _register(source, source);
    return source;
  }

  /// Registers a [RiverpodActiveAccountSource] on its own container that shows no account yet, like
  /// the one a new dashboard starts from.
  static RiverpodActiveAccountSource putEmpty() {
    final source = RiverpodActiveAccountSource(newContainer());
    _register(source, source);
    return source;
  }

  /// Registers a [FakeActiveAccountSource] that only carries [accountId], for a test whose session
  /// does not list that account.
  static FakeActiveAccountSource putShowing(AccountId? accountId) {
    final source = FakeActiveAccountSource(accountId);
    _register(source, source);
    return source;
  }

  /// Shows [accountId] until the end of the current test, then registers the source shown before.
  static void showForThisTest(AccountId accountId) {
    final previousSource = Get.find<ActiveAccountSource>();
    final previousWriter = Get.find<ActiveAccountWriter>();
    putShowing(accountId);
    addTearDown(() => _register(previousSource, previousWriter));
  }

  static void unregister() {
    Get.delete<ActiveAccountSource>(force: true);
    Get.delete<ActiveAccountWriter>(force: true);
  }

  static ProviderContainer newContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  /// Replaces a source left registered by an earlier test, which [Get.put] would keep.
  static void _register(ActiveAccountSource source, ActiveAccountWriter writer) {
    unregister();
    Get.put<ActiveAccountSource>(source);
    Get.put<ActiveAccountWriter>(writer);
  }
}

/// Shows an account the session may not list. It has an [activeAccount] only for my own account of
/// an applied session.
class FakeActiveAccountSource implements ActiveAccountSource, ActiveAccountWriter {
  final _watchers = <OnShownAccount>[];

  AccountId? _accountId;
  ActiveAccount? _activeAccount;

  FakeActiveAccountSource(this._accountId);

  @override
  AccountId? get accountId => _accountId;

  @override
  ActiveAccount? get activeAccount => _activeAccount;

  @override
  void applySession(Session session) => _show(session.accountId, ActiveAccount.personal(session));

  @override
  void clear() {
    _accountId = null;
    _activeAccount = null;
  }

  @override
  CancelShownAccountWatch watchShown(OnShownAccount onShown) {
    _watchers.add(onShown);
    final shownAccountId = _accountId;
    if (shownAccountId != null) onShown(shownAccountId);
    return () => _watchers.remove(onShown);
  }

  void show(AccountId accountId) => _show(accountId, null);

  void _show(AccountId accountId, ActiveAccount? activeAccount) {
    _activeAccount = activeAccount;
    if (_accountId == accountId) return;
    _accountId = accountId;
    for (final onShown in List.of(_watchers)) {
      onShown(accountId);
    }
  }
}
