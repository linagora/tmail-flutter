import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';

void main() {
  group('ComposerPersistentCache', () {
    ComposerPersistentCache makeCache({
      String composerId = 'session-uuid-123',
      Email? email,
      bool? isCleanClose,
      int? timestampMs,
    }) {
      return ComposerPersistentCache(
        composerId: composerId,
        email: email,
        isCleanClose: isCleanClose,
        timestampMs: timestampMs,
      );
    }

    ComposerPersistentCache makeSerializableCache() {
      return ComposerPersistentCache(
        composerId: 'uuid-test',
        isCleanClose: true,
        timestampMs: 1700000000000, // Fixed timestamp for determinism
      );
    }

    void expectCacheEquals(
      ComposerPersistentCache actual,
      ComposerPersistentCache expected,
    ) {
      expect(actual.composerId, expected.composerId);
      expect(actual.email, expected.email);
      expect(actual.isCleanClose, expected.isCleanClose);
      expect(actual.timestampMs, expected.timestampMs);
    }

    void expectCopyPreservesBaseFields(
      ComposerPersistentCache copy,
      ComposerPersistentCache original,
    ) {
      expect(copy.composerId, original.composerId);
    }

    group('isRestorable', () {
      test('returns false when isCleanClose is true', () {
        final cache = makeCache(
          isCleanClose: true,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect(cache.isRestorable, isFalse);
      });

      test('returns false when cache is empty', () {
        final cache = makeCache(
          isCleanClose: false,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect(cache.isEmpty, isTrue);
        expect(cache.isRestorable, isFalse);
      });

      test('evaluates guard conditions correctly', () {
        final cache = makeCache(
          isCleanClose: null,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect(cache.isCleanClose, isNull);
        expect(cache.isExpired, isFalse);
        expect(cache.isEmpty, isTrue);
        expect(cache.isRestorable, isFalse);
      });
    });

    group('isExpired', () {
      test('returns false when timestampMs is null', () {
        expect(makeCache().isExpired, isFalse);
      });

      test('returns false when timestampMs is recent', () {
        final cache = makeCache(
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect(cache.isExpired, isFalse);
      });

      test('returns true when timestampMs is older than 24 hours', () {
        final cache = makeCache(
          timestampMs: DateTime.now()
              .subtract(const Duration(hours: 25))
              .millisecondsSinceEpoch,
        );

        expect(cache.isExpired, isTrue);
      });
    });

    group('isEmpty', () {
      test('returns true when email is null', () {
        expect(makeCache(email: null).isEmpty, isTrue);
      });

      test('returns false when email is not null', () {
        expect(makeCache(email: Email()).isEmpty, isFalse);
      });
    });

    group('copyWith', () {
      final testCases = [
        (
          description: 'updates isCleanClose while preserving other fields',
          verify: () {
            final original = makeCache(
              isCleanClose: false,
              timestampMs: DateTime.now().millisecondsSinceEpoch,
            );

            final copy = original.copyWith(
              isCleanClose: true,
            );

            expect(copy.isCleanClose, isTrue);
            expect(copy.timestampMs, original.timestampMs);
            expectCopyPreservesBaseFields(copy, original);
          },
        ),
        (
          description: 'updates timestampMs while preserving other fields',
          verify: () {
            final original = makeCache(
              isCleanClose: false,
            );

            final newTimestamp = DateTime.now().millisecondsSinceEpoch;

            final copy = original.copyWith(
              timestampMs: newTimestamp,
            );

            expect(copy.timestampMs, newTimestamp);
            expect(
              copy.isCleanClose,
              original.isCleanClose,
            );
            expectCopyPreservesBaseFields(copy, original);
          },
        ),
      ];

      for (final testCase in testCases) {
        test(
          testCase.description,
          testCase.verify,
        );
      }
    });

    group('JSON serialisation', () {
      test('toJson / fromJson round-trip preserves all fields', () {
        final original = makeSerializableCache();

        final restored = ComposerPersistentCache.fromJson(
          original.toJson(),
        );

        expectCacheEquals(restored, original);
      });

      test('omits nullable fields when they are null', () {
        final cache = ComposerPersistentCache(
          composerId: 'uuid-xyz',
        );

        final json = cache.toJson();

        expect(
          json.containsKey('isCleanClose'),
          isFalse,
        );
        expect(
          json.containsKey('timestampMs'),
          isFalse,
        );
      });

      test('supports JSON string encode and decode', () {
        final original = makeSerializableCache();

        final jsonString = jsonEncode(
          original.toJson(),
        );

        final decoded = ComposerPersistentCache.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );

        expectCacheEquals(decoded, original);
      });

      test('toJson / fromJson round-trip preserves email field', () {
        final original = ComposerPersistentCache(
          composerId: 'uuid-email-test',
          email: Email(),
          isCleanClose: false,
          timestampMs: 1700000000000,
        );

        final restored = ComposerPersistentCache.fromJson(original.toJson());

        expect(restored.email, isNotNull);
      });
    });
  });
}
