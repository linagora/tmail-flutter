import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/folder_reload_on_reconnect.dart';

void main() {
  group('FolderReloadOnReconnect', () {
    late StreamController<void> internetRestored;
    late int reloadCount;
    late FolderReloadOnReconnect reloader;

    setUp(() {
      internetRestored = StreamController<void>.broadcast();
      reloadCount = 0;
      reloader = FolderReloadOnReconnect(
        internetRestored.stream,
        () => reloadCount++,
      );
    });

    tearDown(() async {
      await reloader.dispose();
      await internetRestored.close();
    });

    Future<void> restoreInternet() async {
      internetRestored.add(null);
      await pumpEventQueue();
    }

    test('Should not reload WHEN the last load did not fail', () async {
      await restoreInternet();

      expect(reloadCount, 0);
    });

    test('Should reload once WHEN the last load failed and the internet is back', () async {
      reloader.markLoadFailed();

      await restoreInternet();

      expect(reloadCount, 1);
    });

    test('Should reload again WHEN the internet is back twice and no load succeeded', () async {
      reloader.markLoadFailed();

      await restoreInternet();
      await restoreInternet();

      expect(reloadCount, 2);
    });

    test('Should not reload WHEN the folders loaded after the failure', () async {
      reloader.markLoadFailed();
      reloader.markLoaded();

      await restoreInternet();

      expect(reloadCount, 0);
    });

    test('Should reload once WHEN the internet came back before the first load failed', () async {
      await restoreInternet();
      expect(reloadCount, 0);

      reloader.markLoadFailed();

      expect(reloadCount, 1);
    });

    test('Should reload once WHEN the internet came back twice before the first load failed', () async {
      await restoreInternet();
      await restoreInternet();

      reloader.markLoadFailed();
      reloader.markLoadFailed();

      expect(reloadCount, 1);
    });

    test('Should not reload WHEN the internet came back before the first load succeeded', () async {
      await restoreInternet();

      reloader.markLoaded();
      reloader.markLoadFailed();

      expect(reloadCount, 0);
    });

    test('Should not reload WHEN it was disposed', () async {
      reloader.markLoadFailed();
      await reloader.dispose();

      await restoreInternet();

      expect(reloadCount, 0);
    });
  });
}
