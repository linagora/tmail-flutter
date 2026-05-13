import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/calendar_event_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/error_type_handler/unknown_address_exception.dart';
import 'package:model/error_type_handler/unknown_uri_exception.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/principals/capability_principals.dart';

void main() {
  final accountId = AccountId(Id('123abc'));

  Session makeSession({
    Uri? apiUrl,
    Uri? downloadUrl,
    Uri? uploadUrl,
  }) =>
      Session(
        {},
        {accountId: Account(AccountName('name'), true, true, {})},
        {},
        UserName('user@example.com'),
        apiUrl ?? Uri.parse('http://localhost/jmap'),
        downloadUrl ?? Uri.parse('http://localhost/download/{accountId}/{blobId}?type={type}&name={name}'),
        uploadUrl ?? Uri.parse('http://localhost/upload/{accountId}'),
        Uri.parse('http://localhost/eventSource'),
        State(''),
      );

  group('getUploadUri', () {
    test('should normalize double slashes when server returns path with //', () {
      final session = makeSession(uploadUrl: Uri.parse('http://localhost//upload/{accountId}'));
      expect(session.getUploadUri(accountId).toString(), 'http://localhost/upload/123abc');
    });

    test('should produce correct upload URI when path has single slash', () {
      expect(makeSession().getUploadUri(accountId).toString(), 'http://localhost/upload/123abc');
    });

    test('should resolve relative uploadUrl using jmapUrl', () {
      final session = makeSession(
        apiUrl: Uri.parse('http://example.com/jmap'),
        uploadUrl: Uri.parse('/upload/{accountId}'),
      );
      expect(
        session.getUploadUri(accountId, jmapUrl: 'http://example.com').toString(),
        'http://example.com/upload/123abc',
      );
    });

    test('should throw UnknownUriException when uploadUrl has no origin and jmapUrl is not provided', () {
      final session = makeSession(uploadUrl: Uri.parse('/upload/{accountId}'));
      expect(
        () => session.getUploadUri(accountId),
        throwsA(isA<UnknownUriException>()),
      );
    });
  });

  group('getDownloadUrl', () {
    test('should normalize double slashes when server returns path with //', () {
      final session = makeSession(
        downloadUrl: Uri.parse('http://localhost//download/{accountId}/{blobId}?type={type}&name={name}'),
      );
      expect(
        session.getDownloadUrl(),
        'http://localhost/download/{accountId}/{blobId}?type={type}&name={name}',
      );
    });

    test('should produce correct download URL when path has single slash', () {
      expect(
        makeSession().getDownloadUrl(),
        'http://localhost/download/{accountId}/{blobId}?type={type}&name={name}',
      );
    });

    test('should resolve relative downloadUrl using jmapUrl', () {
      final session = makeSession(
        apiUrl: Uri.parse('http://example.com/jmap'),
        downloadUrl: Uri.parse('/download/{accountId}/{blobId}?type={type}&name={name}'),
      );
      expect(
        session.getDownloadUrl(jmapUrl: 'http://example.com'),
        'http://example.com/download/{accountId}/{blobId}?type={type}&name={name}',
      );
    });

    test('should throw UnknownUriException when downloadUrl has no origin and jmapUrl is not provided', () {
      final session = makeSession(
        downloadUrl: Uri.parse('/download/{accountId}/{blobId}?type={type}&name={name}'),
      );
      expect(
        () => session.getDownloadUrl(),
        throwsA(isA<UnknownUriException>()),
      );
    });

    test('should preserve port number while normalizing download URL', () {
      final session = makeSession(
        apiUrl: Uri.parse('http://localhost:9000/jmap'),
        downloadUrl: Uri.parse('http://localhost:9000//download/{accountId}/{blobId}?type={type}&name={name}'),
      );
      expect(
        session.getDownloadUrl(),
        'http://localhost:9000/download/{accountId}/{blobId}?type={type}&name={name}',
      );
    });
  });

  group('getSafetyDownloadUrl', () {
    test('should return empty string when downloadUrl has no origin and jmapUrl is not provided', () {
      final session = makeSession(
        downloadUrl: Uri.parse('/download/{accountId}/{blobId}?type={type}&name={name}'),
      );
      expect(session.getSafetyDownloadUrl(), '');
    });

    test('should return normalized URL when downloadUrl is valid', () {
      final session = makeSession(
        downloadUrl: Uri.parse('http://localhost//download/{accountId}/{blobId}?type={type}&name={name}'),
      );
      expect(
        session.getSafetyDownloadUrl(),
        'http://localhost/download/{accountId}/{blobId}?type={type}&name={name}',
      );
    });
  });

  group('validate calendar event capability test:', () {
    final account = Account(AccountName('name'), true, true, {});

    test(
      'should return isAvailable is false '
      'and calendarEventCapability is null '
      'when there is no such capability',
    () {
      // arrange
      final session = Session(
        {},
        {accountId: account},
        {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

      // act
      final result = session.validateCalendarEventCapability(accountId);

      // assert
      expect(result.isAvailable, false);
      expect(result.calendarEventCapability, null);
    });

    test(
      'should return isAvailable is true '
      'and calendarEventCapability is not null '
      'when calendar event capability is available',
    () {
      // arrange
      final calendarEventCapability = CalendarEventCapability();
      final session = Session(
        {CapabilityIdentifier.jamesCalendarEvent: calendarEventCapability},
        {accountId: account},
        {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

      // act
      final result = session.validateCalendarEventCapability(AccountId(Id('123abc')));

      // assert
      expect(result.isAvailable, true);
      expect(result.calendarEventCapability, calendarEventCapability);
    });
  });

  group('get language for calendar event test:', () {
    test(
      'should return null '
      'when calendar event capability is not supported',
    () {
      // arrange
      const currentLocale = Locale('en', 'US');
      final session = Session(
        {CapabilityIdentifier.jamesCalendarEvent: EmptyCapability()},
        {}, {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

      // act
      final calendarEventLanguage = session.getLanguageForCalendarEvent(
        currentLocale,
        accountId);
      
      // assert
      expect(calendarEventLanguage, null);
    });

    test(
      'should return null '
      'when calendar event capability supports no language',
    () {
      // arrange
      final calendarEventCapability = CalendarEventCapability();
      const currentLocale = Locale('en', 'US');
      final session = Session(
        {CapabilityIdentifier.jamesCalendarEvent: calendarEventCapability},
        {}, {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

      // act
      final calendarEventLanguage = session.getLanguageForCalendarEvent(
        currentLocale,
        accountId);
      
      // assert
      expect(calendarEventLanguage, null);
    });

    test(
      'should return current locale language '
      'when calendar event capability supports current locale',
    () {
      // arrange
      final calendarEventCapability = CalendarEventCapability(
        replySupportedLanguage: ['en', 'fr'],
      );
      const currentLocale = Locale('en', 'US');
      final session = Session(
        {CapabilityIdentifier.jamesCalendarEvent: calendarEventCapability},
        {}, {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

      // act
      final calendarEventLanguage = session.getLanguageForCalendarEvent(
        currentLocale,
        accountId);

      // assert
      expect(calendarEventLanguage, currentLocale.languageCode);
    });

    test(
      'should return English language '
      'when calendar event capability doesn\'t support current locale, '
      'but supports English',
    () {
      // arrange
      final calendarEventCapability = CalendarEventCapability(
        replySupportedLanguage: ['en'],
      );
      const currentLocale = Locale('fr', 'FR');
      final session = Session(
        {CapabilityIdentifier.jamesCalendarEvent: calendarEventCapability},
        {}, {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

      // act
      final calendarEventLanguage = session.getLanguageForCalendarEvent(
        currentLocale,
        accountId);

      // assert
      expect(calendarEventLanguage, 'en');
    });

    test(
      'should return first supported language '
      'when calendar event capability doesn\'t support both English and current locale',
    () {
      // arrange
      final calendarEventCapability = CalendarEventCapability(
        replySupportedLanguage: ['vi'],
      );
      const currentLocale = Locale('fr', 'FR');
      final session = Session(
        {CapabilityIdentifier.jamesCalendarEvent: calendarEventCapability},
        {}, {}, UserName(''), Uri(), Uri(), Uri(), Uri(), State(''));

      // act
      final calendarEventLanguage = session.getLanguageForCalendarEvent(
        currentLocale,
        accountId);

      // assert
      expect(calendarEventLanguage, 'vi');
    });
  });

  group('getOwnEmailAddress test:', () {
    test(
      'should return username.value '
      'when it is a valid email and principals capability is absent',
    () {
      // arrange
      final session = Session({}, {}, {}, UserName('test@example.com'), Uri(), Uri(), Uri(), Uri(), State(''),);

      // act
      final emailAddress = session.getOwnEmailAddress();

      // assert
      expect(emailAddress, 'test@example.com');
    });

    test(
      'should return username.value'
      'when it is a valid email and principals capability is present but has no address',
    () {
      // arrange
      final session = Session(
        {capabilityPrincipals: DefaultCapability({})},
        {}, {}, UserName('test@example.com'), Uri(), Uri(), Uri(), Uri(), State(''),
      );

      // act
      final emailAddress = session.getOwnEmailAddress();

      // assert
      expect(emailAddress, 'test@example.com');
    });

    test(
      'should return username.value'
      'when it is a valid email and principals capability is present with an address',
    () {
      // arrange
      final session = Session(
        {capabilityPrincipals: DefaultCapability({'key': {'subKey': 'mailto:another@example.com'}})},
        {}, {}, UserName('test@example.com'), Uri(), Uri(), Uri(), Uri(), State(''),
      );

      // act
      final emailAddress = session.getOwnEmailAddress();

      // assert
      expect(emailAddress, 'test@example.com');
    });

    test(
      'should throw exception'
      'when username is not a valid email and principals capability is absent',
    () {
      // arrange
      final session = Session({}, {}, {}, UserName('notAnEmail'), Uri(), Uri(), Uri(), Uri(), State(''));

      // assert
      expect(() => session.getOwnEmailAddress(), throwsA(isA<UnknownAddressException>()));
    });

    test(
      'should return null'
      'when username is not a valid email and principals capability is present but has no address',
    () {
      // arrange
      final session = Session(
        {capabilityPrincipals: DefaultCapability({})},
        {}, {}, UserName('notAnEmail'), Uri(), Uri(), Uri(), Uri(), State(''),
      );

      // assert
      expect(() => session.getOwnEmailAddress(), throwsA(isA<UnknownAddressException>()));
    });

    test(
      'should return null'
      'when username is not a valid email and principals capability is present but has no valid address',
    () {
      // arrange
      final session = Session(
        {capabilityPrincipals: DefaultCapability({'key': {'subKey': 'test@example.com'}})},
        {}, {}, UserName('notAnEmail'), Uri(), Uri(), Uri(), Uri(), State(''),
      );

      // assert
      expect(() => session.getOwnEmailAddress(), throwsA(isA<UnknownAddressException>()));
    });

    test(
      'should return email address from principals capability'
      'when username is not a valid email and principals capability is present with an address',
    () {
      // arrange
      final capability = DefaultCapability({
        "currentUserPrincipalId": "bob",
        "urn:ietf:params:jmap:calendars": {
          "accountId": "bob",
          "account": null,
          "mayGetAvailability": true,
          "sendTo": {
            "imip": "mailto:bob@example.com"
          }
        }
      });

      final session = Session(
        {capabilityPrincipals: capability},
        {}, {}, UserName('notAnEmail'), Uri(), Uri(), Uri(), Uri(), State(''),
      );

      // act
      final emailAddress = session.getOwnEmailAddress();

      // assert
      expect(emailAddress, 'bob@example.com');
    });
  });
}