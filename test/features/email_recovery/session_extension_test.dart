
import 'package:email_recovery/email_recovery/capability_deleted_messages_vault.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/session_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

void main() {

  group('session extension test:', () {
    test(
        'getRestorationHorizonAsDuration() should return the horizon as a duration when 15 days',
            () {
          // arrange
          final session = Session({}, {AccountId(Id("1")): Account(AccountName("name"), true, false,
              {capabilityDeletedMessagesVault: DefaultCapability({"restorationHorizon": "15 days"})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final horizon = session.getRestorationHorizonAsDuration();

          // assert
          expect(horizon, const Duration(days: 15));
        });

    test(
        'getRestorationHorizonAsDuration() should return the horizon as a duration when 1 hour',
            () {
          // arrange
          final session = Session({}, {AccountId(Id("1")): Account(AccountName("name"), true, false,
              {capabilityDeletedMessagesVault: DefaultCapability({"restorationHorizon": "1 hour"})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final horizon = session.getRestorationHorizonAsDuration();

          // assert
          expect(horizon, const Duration(hours: 1));
        });

    test(
        'getRestorationHorizonAsDuration() should return the horizon as a duration when 45 minutes',
            () {
          // arrange
          final session = Session({}, {AccountId(Id("1")): Account(AccountName("name"), true, false,
              {capabilityDeletedMessagesVault: DefaultCapability({"restorationHorizon": "45 minutes"})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final horizon = session.getRestorationHorizonAsDuration();

          // assert
          expect(horizon, const Duration(minutes: 45));
        });

    test(
        'getRestorationHorizonAsDuration() should return default horizon as a duration when invalid horizon',
            () {
          // arrange
          final session = Session({}, {AccountId(Id("1")): Account(AccountName("name"), true, false,
              {capabilityDeletedMessagesVault: DefaultCapability({"restorationHorizon": "invalid"})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final horizon = session.getRestorationHorizonAsDuration();

          // assert
          expect(horizon, const Duration(days: 15));
        });

    test(
        'getRestorationHorizonAsString should return the horizon as a String',
            () {
          // arrange
          final session = Session({}, {AccountId(Id("1")): Account(AccountName("name"), true, false,
              {capabilityDeletedMessagesVault: DefaultCapability({"restorationHorizon": "15 days"})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final horizon = session.getRestorationHorizonAsString();

          // assert
          expect(horizon, "15 days");
        });

    test(
        'getRestorationHorizonAsString should return the default horizon as a String when invalid session attribute',
            () {
          // arrange
          final session = Session({}, {AccountId(Id("1")): Account(AccountName("name"), true, false,
              {capabilityDeletedMessagesVault: DefaultCapability({"invalid": "15 days"})})},
              {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

          // act
          final horizon = session.getRestorationHorizonAsString();

          // assert
          expect(horizon, "15 days");
        });

    Session sessionWithHorizon(Map<String, dynamic> props) => Session(
        {},
        {AccountId(Id("1")): Account(AccountName("name"), true, false,
            {capabilityDeletedMessagesVault: DefaultCapability(props)})},
        {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

    test('getRestorationHorizonInDays should return 15 when 15 days', () {
      final session = sessionWithHorizon({"restorationHorizon": "15 days"});
      expect(session.getRestorationHorizonInDays(), 15);
    });

    test('getRestorationHorizonInDays should round 1 hour up to 1', () {
      final session = sessionWithHorizon({"restorationHorizon": "1 hour"});
      expect(session.getRestorationHorizonInDays(), 1);
    });

    test('getRestorationHorizonInDays should return 1 when 0 days', () {
      final session = sessionWithHorizon({"restorationHorizon": "0 days"});
      expect(session.getRestorationHorizonInDays(), 1);
    });

    test('getRestorationHorizonInDays should return 1 when 24 hours', () {
      final session = sessionWithHorizon({"restorationHorizon": "24 hours"});
      expect(session.getRestorationHorizonInDays(), 1);
    });

    test('getRestorationHorizonInDays should round 25 hours up to 2', () {
      final session = sessionWithHorizon({"restorationHorizon": "25 hours"});
      expect(session.getRestorationHorizonInDays(), 2);
    });

    test('getRestorationHorizonInDays should round 36 hours up to 2', () {
      final session = sessionWithHorizon({"restorationHorizon": "36 hours"});
      expect(session.getRestorationHorizonInDays(), 2);
    });

    test('getRestorationHorizonInDays should return 15 when capability key is missing', () {
      final session = sessionWithHorizon({"invalid": "15 days"});
      expect(session.getRestorationHorizonInDays(), 15);
    });

    test('recover description does not duplicate the day unit', () {
      final session = sessionWithHorizon({"restorationHorizon": "15 days"});

      final text = AppLocalizations().dialogRecoverDeletedMessagesDescription(
          session.getRestorationHorizonInDays().toString());

      expect(text, contains('within the last 15 days.'));
      expect(text, isNot(contains('days days')));
    });
  });
}