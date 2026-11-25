import 'package:core/utils/app_logger.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/identity_creator/data/datasource_impl/local_identity_creator_data_source_impl.dart';
import 'package:tmail_ui_user/main/utils/child_tab_browser.dart';
import 'package:tmail_ui_user/main/utils/child_tab_browser_platform.dart';

export 'package:tmail_ui_user/main/utils/child_tab_browser.dart';

/// A tab opened by the app inherits a copy of its opener's sessionStorage.
/// This drops the copied composer and identity drafts, then detaches the opener
/// so a later reload of this tab keeps the drafts the tab creates itself.
class ChildTabSessionCleaner {
  // Key prefixes, as built by the composer and identity creator caches (TupleKey joins with '|').
  static final List<String> copiedDraftKeyPrefixes = [
    '${EmailActionType.reopenComposerBrowser.name}|',
    '${LocalIdentityCreatorDataSourceImpl.sessionStorageKeyword}|',
  ];

  ChildTabSessionCleaner([ChildTabBrowser? browser])
      : _browser = browser ?? PlatformChildTabBrowser();

  final ChildTabBrowser _browser;

  void run() {
    try {
      if (!_browser.hasOpener) return;
      for (final key in _browser.sessionStorageKeys) {
        if (copiedDraftKeyPrefixes.any(key.startsWith)) {
          _browser.removeSessionStorageKey(key);
        }
      }
      _browser.detachOpener();
    } catch (e) {
      logWarning('ChildTabSessionCleaner::run: $e');
    }
  }
}
