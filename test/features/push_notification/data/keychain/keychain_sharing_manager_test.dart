import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';

void main() {
  late KeychainSharingManager keychainSharingManager;
  late FlutterSecureStorage flutterSecureStorage;

  group('KeychainSharingManager:save for the same accountId', () {
    setUp(() {
      flutterSecureStorage = const FlutterSecureStorage();
      keychainSharingManager = KeychainSharingManager(flutterSecureStorage);
    });

    test('WHEN keychain have no session \n'
      'AND another session saved to keychain \n'
      'THEN keychain will have only new session', () async {
      // arrange
      final keychainSharingSession = KeychainSharingSession(
        accountId: AccountId(Id(
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')),
        userName: UserName('username@domain.com'),
        authenticationType: AuthenticationType.oidc,
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
      );

      FlutterSecureStorage.setMockInitialValues({
        keychainSharingSession.accountId.asString: jsonEncode(keychainSharingSession.toJson())
      });

      // act
      await keychainSharingManager.save(keychainSharingSession);

      // assert
      final keychainSession = await keychainSharingManager.getSharingSession(AccountId(Id(
          'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')));
      expect(keychainSession, isNotNull);
    });

    test('WHEN keychain have session \n'
        'AND another session saved to keychain \n'
        'THEN keychain will have only new session', () async {
      // arrange
      final keychainSharingSession1 = KeychainSharingSession(
        accountId: AccountId(Id(
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')),
        userName: UserName('username@domain.com'),
        authenticationType: AuthenticationType.oidc,
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
      );

      FlutterSecureStorage.setMockInitialValues({
        keychainSharingSession1.accountId.asString: jsonEncode(keychainSharingSession1.toJson())
      });

      final keychainSharingSession2 = KeychainSharingSession(
        accountId: AccountId(Id(
            'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')),
        userName: UserName('username@domain.com'),
        authenticationType: AuthenticationType.oidc,
        apiUrl: 'https://jmap.domain.com/oidc/jmap',
        tokenEndpoint: 'https://jmap.domain.com/oidc/jmap',
        oidcScopes: ['email'],
        isTWP: true,
        emailState: 'ae08b34da40b48f30ec0b94',
        tokenOIDC: TokenOIDC(
          'ae08b34da40b48f30ec0b94',
          TokenId('ae08b34da40b48f30ec0b94'),
          'ae08b34da40b48f30ec0b94',
          expiredTime: DateTime.now()
        )
      );

      // act
      await keychainSharingManager.save(keychainSharingSession2);

      // assert
      final keychainSession = await keychainSharingManager.getSharingSession(AccountId(Id(
          'ae08b34da40b48f30ec0b94db05675894262fbc5c2e278644f9517aaf25e8246')));
      expect(keychainSession, isNotNull);
      expect(keychainSession?.tokenOIDC, isNotNull);
      expect(keychainSession?.emailState, equals('ae08b34da40b48f30ec0b94'));
      expect(keychainSession?.tokenEndpoint, equals('https://jmap.domain.com/oidc/jmap',));
      expect(keychainSession?.oidcScopes, equals(['email']));
      expect(keychainSession?.isTWP, isTrue);
    });
  });
}
