import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subaddressing_action.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('MailboxAPI.updateRightsForSubaddressing tests', () {
    const postingRight = 'p';
    final mailboxAPI = MailboxAPI(HttpClient(Dio()), const Uuid());

    test('should add postingRight when action is allow and currentRights is empty', () {
      final result = mailboxAPI.updateRightsForSubaddressing(MailboxSubaddressingAction.allow, []);
      expect(result, contains(postingRight));
      expect(result.length, 1);
    });

    test('should add postingRight when action is allow and currentRights does not contain postingRight', () {
      final result = mailboxAPI.updateRightsForSubaddressing(MailboxSubaddressingAction.allow, ['r', 'w']);
      expect(result, contains(postingRight));
      expect(result.length, 3);
    });

    test('should not add postingRight if action is allow and postingRight already present', () {
      final result = mailboxAPI.updateRightsForSubaddressing(MailboxSubaddressingAction.allow, ['r', postingRight, 'w']);
      expect(result.where((right) => right == postingRight).length, 1);
      expect(result.length, 3);
    });

    test('should remove postingRight if present and action is disallow', () {
      final result = mailboxAPI.updateRightsForSubaddressing(MailboxSubaddressingAction.disallow, ['r', postingRight, 'w']);
      expect(result, isNot(contains(postingRight)));
      expect(result.length, 2);
    });

    test('should do nothing if postingRight is not present and action is disallow', () {
      final result = mailboxAPI.updateRightsForSubaddressing(MailboxSubaddressingAction.disallow, ['r', 'w']);
      expect(result, isNot(contains(postingRight)));
      expect(result.length, 2);
    });

    test('should return empty list if action is disallow and currentRights is null', () {
      final result = mailboxAPI.updateRightsForSubaddressing(MailboxSubaddressingAction.disallow, null);
      expect(result, isEmpty);
    });

    test('should return list with only postingRight if action is allow and currentRights is null', () {
      final result = mailboxAPI.updateRightsForSubaddressing(MailboxSubaddressingAction.allow, null);
      expect(result, contains(postingRight));
      expect(result.length, 1);
    });
  });
}
