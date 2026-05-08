import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
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
      test('returns true when email is set, not expired, and not a clean close', () {
        final cache = makeCache(
          email: Email(),
          isCleanClose: false,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect(cache.isRestorable, isTrue);
      });

      test('returns true when isCleanClose is null (involuntary kill)', () {
        final cache = makeCache(
          email: Email(),
          isCleanClose: null,
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect(cache.isRestorable, isTrue);
      });

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

      test('returns false when cache is expired', () {
        final cache = makeCache(
          email: Email(),
          isCleanClose: false,
          timestampMs: DateTime.now()
              .subtract(const Duration(hours: 25))
              .millisecondsSinceEpoch,
        );

        expect(cache.isRestorable, isFalse);
      });

      test('returns false when timestampMs is null — treated as expired', () {
        final cache = makeCache(
          email: Email(),
          isCleanClose: false,
          timestampMs: null,
        );

        expect(cache.isExpired, isTrue);
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
      test('returns true when timestampMs is null — no anchor means unsafe to restore', () {
        expect(makeCache().isExpired, isTrue);
      });

      test('returns false when timestampMs is recent', () {
        final cache = makeCache(
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect(cache.isExpired, isFalse);
      });

      test('returns false when timestampMs is exactly at the 24-hour boundary', () {
        // Implementation uses strict >, so exactly 24h is not yet expired.
        final cache = makeCache(
          timestampMs: DateTime.now()
              .subtract(const Duration(hours: 24))
              .millisecondsSinceEpoch,
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

    group('newestLocalCache extension', () {
      test('returns null when iterable is empty', () {
        expect(<ComposerPersistentCache>[].newestLocalCache, isNull);
      });

      test('returns the single entry when there is only one', () {
        final cache = makeCache(
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect([cache].newestLocalCache, same(cache));
      });

      test('returns the entry with the highest timestampMs', () {
        final older = makeCache(
          timestampMs: DateTime.now()
              .subtract(const Duration(hours: 2))
              .millisecondsSinceEpoch,
        );
        final newer = makeCache(
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect([older, newer].newestLocalCache, same(newer));
        expect([newer, older].newestLocalCache, same(newer));
      });

      test('ignores plain ComposerCache entries and picks the newest ComposerPersistentCache', () {
        final plainCache = ComposerCache(email: Email());
        final persistent = makeCache(
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect([plainCache, persistent].newestLocalCache, same(persistent));
      });

      test('returns null when iterable contains only plain ComposerCache entries', () {
        final plain = ComposerCache(email: Email());
        expect([plain].newestLocalCache, isNull);
      });

      test('treats null timestampMs as 0 when comparing', () {
        final noTimestamp = makeCache(timestampMs: null);
        final withTimestamp = makeCache(
          timestampMs: DateTime.now().millisecondsSinceEpoch,
        );

        expect([noTimestamp, withTimestamp].newestLocalCache, same(withTimestamp));
      });
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

      // draftEmailId is read back during kill+restore to sync emailIdEditing
      // and avoid using stale blobIds from the destroyed draft.
      test('toJson / fromJson round-trip preserves draftEmailId', () {
        final draftId = EmailId(Id('draft-id-abc-123'));
        final original = ComposerPersistentCache(
          composerId: 'uuid-draft-test',
          email: Email(),
          draftEmailId: draftId,
          timestampMs: 1700000000000,
        );

        final restored = ComposerPersistentCache.fromJson(original.toJson());

        expect(restored.draftEmailId, isNotNull);
        expect(restored.draftEmailId!.id.value, draftId.id.value);
      });

      test('draftEmailId is omitted from JSON when null', () {
        final cache = ComposerPersistentCache(composerId: 'uuid-no-draft');

        expect(cache.toJson().containsKey('draftEmailId'), isFalse);
      });
    });
  });
}
