import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

void main() {
  group('get internal domain in session test', () {
    test('When username is valid email, internalDomain should be returns the domain', () {
      final Session session = Session(
        {},
        {},
        {},
        UserName('example@example.com'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
      );

      String result = session.internalDomain;

      expect(result, equals('example.com'));
    });

    test('When personal account name is valid email, internalDomain should be returns the domain', () {
      final Session session = Session(
        {},
        {
          AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')): Account(AccountName('example@example.com'), true, false, {})
        },
        {},
        UserName('example'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
      );

      String result = session.internalDomain;

      expect(result, equals('example.com'));
    });

    test('When neither username nor personal account name is valid email, internalDomain should be returns an empty string', () {
      final Session session = Session(
        {},
        {
          AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6')): Account(AccountName('example'), true, false, {})
        },
        {},
        UserName('example'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
      );

      String result = session.internalDomain;

      expect(result, equals(''));
    });

    test('When personalAccount throw an exception, internalDomain should be returns an empty string', () {
      final Session session = Session(
        {},
        {},
        {},
        UserName('example'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse('http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse('http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943')
      );

      final result = session.internalDomain;

      expect(result, equals(''));
    });
  });
}