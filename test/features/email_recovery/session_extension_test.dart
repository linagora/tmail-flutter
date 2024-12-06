
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
  });
}