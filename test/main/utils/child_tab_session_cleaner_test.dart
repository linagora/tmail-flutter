import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/child_tab_browser_platform.dart';
import 'package:tmail_ui_user/main/utils/child_tab_session_cleaner.dart';

class _FakeChildTabBrowser implements ChildTabBrowser {
  _FakeChildTabBrowser({this.opener = true, this.openerThrows = false});

  bool opener;
  final bool openerThrows;
  final Map<String, String> storage = {};

  @override
  bool get hasOpener {
    if (openerThrows) throw StateError('cross-origin opener');
    return opener;
  }

  @override
  void detachOpener() => opener = false;

  @override
  List<String> get sessionStorageKeys => storage.keys.toList();

  @override
  void removeSessionStorageKey(String key) => storage.remove(key);
}

void main() {
  const composerKey = 'reopenComposerBrowser|account|user|composer-1';
  const identityKey = 'identityCreatorSessionStorage|account|user';
  const keptKeys = ['authenticationInfoCache', 'basicAuthSignOutTag', 'auth_info', 'other'];

  _FakeChildTabBrowser browserWithCopiedStorage({
    bool opener = true,
    bool openerThrows = false,
  }) {
    final browser = _FakeChildTabBrowser(opener: opener, openerThrows: openerThrows);
    browser.storage
      ..[composerKey] = 'draft'
      ..[identityKey] = 'identity'
      ..addEntries(keptKeys.map((k) => MapEntry(k, 'v')));
    return browser;
  }

  group('ChildTabSessionCleaner', () {
    test('with an opener removes only composer and identity snapshots and detaches it', () {
      final browser = browserWithCopiedStorage();
      ChildTabSessionCleaner(browser).run();

      expect(browser.storage.keys, unorderedEquals(keptKeys));
      expect(browser.opener, isFalse);
    });

    test('without an opener removes nothing', () {
      final browser = browserWithCopiedStorage(opener: false);
      ChildTabSessionCleaner(browser).run();

      expect(browser.storage.keys, containsAll([composerKey, identityKey, ...keptKeys]));
    });

    test('a reload after detaching keeps the draft the tab created itself', () {
      final browser = browserWithCopiedStorage();
      ChildTabSessionCleaner(browser).run();
      const ownDraftKey = 'reopenComposerBrowser|account|user|composer-2';
      browser.storage[ownDraftKey] = 'own draft';

      ChildTabSessionCleaner(browser).run();

      expect(browser.storage.containsKey(ownDraftKey), isTrue);
    });

    test('an opener that cannot be inspected neither crashes nor removes anything', () {
      final browser = browserWithCopiedStorage(openerThrows: true);

      expect(() => ChildTabSessionCleaner(browser).run(), returnsNormally);
      expect(browser.storage.keys, containsAll([composerKey, identityKey, ...keptKeys]));
    });

    test('the platform browser used by default reports no opener outside the web build', () {
      expect(PlatformChildTabBrowser().hasOpener, isFalse);
      expect(() => ChildTabSessionCleaner().run(), returnsNormally);
    });
  });
}
