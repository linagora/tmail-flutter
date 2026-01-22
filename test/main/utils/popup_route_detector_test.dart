import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/popup_route_detector.dart';

void main() {
  group('PopupRouteDetector', () {
    group('extractEmailIdFromUrl', () {
      test('should extract email ID from valid popup URL with hash', () {
        const url = 'https://mail.example.com/#/popup/abc123';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, equals('abc123'));
      });

      test('should extract email ID from valid popup URL without hash', () {
        const url = 'https://mail.example.com/popup/abc123';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, equals('abc123'));
      });

      test('should extract email ID with complex characters', () {
        const url = 'https://mail.example.com/#/popup/M1234abcd-5678';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, equals('M1234abcd-5678'));
      });

      test('should extract email ID and ignore query parameters', () {
        const url = 'https://mail.example.com/#/popup/abc123?param=value';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, equals('abc123'));
      });

      test('should extract email ID and ignore fragment', () {
        const url = 'https://mail.example.com/popup/abc123#section';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, equals('abc123'));
      });

      test('should return null for non-popup URL', () {
        const url = 'https://mail.example.com/#/dashboard';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, isNull);
      });

      test('should return null for home URL', () {
        const url = 'https://mail.example.com/';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, isNull);
      });

      test('should return null for URL with popup but no ID', () {
        const url = 'https://mail.example.com/#/popup/';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, isNull);
      });

      test('should return null for empty URL', () {
        const url = '';
        final result = PopupRouteDetector.extractEmailIdFromUrl(url);
        expect(result, isNull);
      });
    });

    group('isValidSessionHandoff', () {
      test('should return true for fresh session data', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        final sessionData = jsonEncode({
          'type': 'session_handoff',
          'emailId': 'abc123',
          'sessionJson': {'key': 'value'},
          'accountId': 'account123',
          'timestamp': currentTimestamp - 5000, // 5 seconds ago
        });

        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, isTrue);
      });

      test('should return true for session data at boundary (30 seconds)', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        final sessionData = jsonEncode({
          'timestamp': currentTimestamp - 30000, // exactly 30 seconds ago
        });

        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, isTrue);
      });

      test('should return false for stale session data (>30 seconds)', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        final sessionData = jsonEncode({
          'timestamp': currentTimestamp - 31000, // 31 seconds ago
        });

        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, isFalse);
      });

      test('should return false for very old session data', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        final sessionData = jsonEncode({
          'timestamp': currentTimestamp - 60000, // 60 seconds ago
        });

        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, isFalse);
      });

      test('should return false for null session data', () {
        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: null,
          getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
        );

        expect(result, isFalse);
      });

      test('should return false for empty session data', () {
        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: '',
          getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
        );

        expect(result, isFalse);
      });

      test('should return false for session data without timestamp', () {
        final sessionData = jsonEncode({
          'type': 'session_handoff',
          'emailId': 'abc123',
        });

        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: sessionData,
          getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
        );

        expect(result, isFalse);
      });

      test('should return false for invalid JSON', () {
        const sessionData = 'not valid json';

        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: sessionData,
          getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
        );

        expect(result, isFalse);
      });

      test('should return false for timestamp with wrong type', () {
        final sessionData = jsonEncode({
          'timestamp': 'not a number',
        });

        final result = PopupRouteDetector.isValidSessionHandoff(
          sessionDataStr: sessionData,
          getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
        );

        expect(result, isFalse);
      });
    });

    group('detectFromUrlAndStorage', () {
      test('should return popup route when URL and session are valid', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        const url = 'https://mail.example.com/#/popup/email123';
        final sessionData = jsonEncode({
          'timestamp': currentTimestamp - 5000,
        });

        final result = PopupRouteDetector.detectFromUrlAndStorage(
          currentUrl: url,
          getSessionData: () => sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, equals('/popup/email123'));
      });

      test('should return null when URL is not popup route', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        const url = 'https://mail.example.com/#/dashboard';
        final sessionData = jsonEncode({
          'timestamp': currentTimestamp - 5000,
        });

        final result = PopupRouteDetector.detectFromUrlAndStorage(
          currentUrl: url,
          getSessionData: () => sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, isNull);
      });

      test('should return null when session is stale', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        const url = 'https://mail.example.com/#/popup/email123';
        final sessionData = jsonEncode({
          'timestamp': currentTimestamp - 60000, // 60 seconds ago
        });

        final result = PopupRouteDetector.detectFromUrlAndStorage(
          currentUrl: url,
          getSessionData: () => sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, isNull);
      });

      test('should return null when no session data exists', () {
        const url = 'https://mail.example.com/#/popup/email123';

        final result = PopupRouteDetector.detectFromUrlAndStorage(
          currentUrl: url,
          getSessionData: () => null,
          getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
        );

        expect(result, isNull);
      });

      test('should return null when session data is empty', () {
        const url = 'https://mail.example.com/#/popup/email123';

        final result = PopupRouteDetector.detectFromUrlAndStorage(
          currentUrl: url,
          getSessionData: () => '',
          getCurrentTimestamp: () => DateTime.now().millisecondsSinceEpoch,
        );

        expect(result, isNull);
      });

      test('should handle complex email ID', () {
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        const emailId = 'M12345-abcd-6789-efgh';
        const url = 'https://mail.example.com/#/popup/$emailId';
        final sessionData = jsonEncode({
          'timestamp': currentTimestamp - 1000,
        });

        final result = PopupRouteDetector.detectFromUrlAndStorage(
          currentUrl: url,
          getSessionData: () => sessionData,
          getCurrentTimestamp: () => currentTimestamp,
        );

        expect(result, equals('/popup/$emailId'));
      });
    });

    group('sessionValidityMs constant', () {
      test('should be 30 seconds', () {
        expect(PopupRouteDetector.sessionValidityMs, equals(30000));
      });
    });

    group('sessionStorageKey constant', () {
      test('should be tmail_popup_session', () {
        expect(
          PopupRouteDetector.sessionStorageKey,
          equals('tmail_popup_session'),
        );
      });
    });
  });
}
