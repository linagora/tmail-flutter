import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/home/data/extensions/session_hive_obj_extension.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

import '../../fixtures/session_fixtures.dart';

void main() {
  group('SessionHiveObj test', () {
    test('toSession() should return parsing correctly session', () {
      final sessionHiveObj = SessionFixtures.aliceSession.toHiveObj();
      final sessionParsed = sessionHiveObj.toSession();

      expect(sessionParsed.accounts.length, equals(SessionFixtures.aliceSession.accounts.length));
    });
  });
}