import 'package:core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_text_detector.dart';

/// Helper: generate email about [targetLength] characters long
String generateLongEmail(int targetLength, {bool includeKeywords = true}) {
  final buffer = StringBuffer();
  const sample = "This is a random paragraph with no attachments. ";
  while (buffer.length < targetLength) {
    buffer.write(sample);
  }
  if (includeKeywords) {
    buffer.write("Here is the pièce jointe and báo cáo attached.");
  }
  return buffer.toString();
}

void main() {
  group('AttachmentTextDetector.containsAttachmentKeyword', () {
    test('English - should detect "attach" and "attachment"', () {
      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Please see the attached document for details.",
          lang: 'en',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "No attachments here.",
          lang: 'en',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Nothing relevant",
          lang: 'en',
        ),
        isFalse,
      );
    });

    test('French - should detect common attachment words', () {
      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Veuillez trouver la pièce jointe.",
          lang: 'fr',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Ci-joint le fichier joint pour votre examen.",
          lang: 'fr',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Aucun document ici",
          lang: 'fr',
        ),
        isFalse,
      );
    });

    test('Russian - should detect common attachment words', () {
      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Смотрите приложение с отчетом.",
          lang: 'ru',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Документ прикрепить ниже.",
          lang: 'ru',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Текст без вложений",
          lang: 'ru',
        ),
        isFalse,
      );
    });

    test('Vietnamese - should detect common attachment words', () {
      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Vui lòng xem tài liệu đính kèm.",
          lang: 'vi',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Đây là một file rất quan trọng.",
          lang: 'vi',
        ),
        isTrue,
      );

      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Không có gì cần gửi thêm.",
          lang: 'vi',
        ),
        isFalse,
      );
    });

    test('Unsupported language should return false', () {
      expect(
        AttachmentTextDetector.containsAttachmentKeyword(
          "Some random text",
          lang: 'de',
        ),
        isFalse,
      );
    });
  });

  group('AttachmentTextDetector.matchedKeywords', () {
    test('should return matched keywords for Vietnamese', () {
      final matches = AttachmentTextDetector.matchedKeywords(
        "Đây là báo cáo và tài liệu đính kèm.",
        lang: 'vi',
      );

      expect(matches, containsAll(['báo cáo', 'tài liệu', 'đính kèm']));
    });

    test('should return empty list when no keywords found', () {
      final matches = AttachmentTextDetector.matchedKeywords(
        "Nội dung không có gì liên quan",
        lang: 'vi',
      );

      expect(matches, isEmpty);
    });

    test('should return matched keywords for English', () {
      final matches = AttachmentTextDetector.matchedKeywords(
        "Please check the attachment and attach your signature.",
        lang: 'en',
      );

      expect(matches, containsAll(['attachment', 'attach']));
    });
  });

  group('AttachmentTextDetector.containsAnyAttachmentKeyword', () {
    test('should detect when email contains English keyword', () {
      expect(
        AttachmentTextDetector.containsAnyAttachmentKeyword(
          "Please see the ATTACHed document.",
        ),
        isTrue,
      );
    });

    test('should detect when email contains Vietnamese keyword', () {
      expect(
        AttachmentTextDetector.containsAnyAttachmentKeyword(
          "Đây là tài liệu đính kèm.",
        ),
        isTrue,
      );
    });

    test('should detect when email contains Russian keyword', () {
      expect(
        AttachmentTextDetector.containsAnyAttachmentKeyword(
          "Документ прикрепить ниже.",
        ),
        isTrue,
      );
    });

    test('should detect when email contains French keyword', () {
      expect(
        AttachmentTextDetector.containsAnyAttachmentKeyword(
          "Veuillez trouver la pièce jointe.",
        ),
        isTrue,
      );
    });

    test('should return false when no keywords found', () {
      expect(
        AttachmentTextDetector.containsAnyAttachmentKeyword(
          "This email has nothing special.",
        ),
        isFalse,
      );
    });

    test('should detect when email contains multiple languages', () {
      const email = """
        Please see the attached document.
        Vui lòng xem tài liệu đính kèm.
        Смотрите приложение.
      """;

      expect(
        AttachmentTextDetector.containsAnyAttachmentKeyword(email),
        isTrue,
      );
    });
  });

  group('AttachmentTextDetector.matchedKeywordsAll', () {
    test('should return matches for multiple languages', () {
      const email = """
        Please see the attached document.
        Vui lòng xem tài liệu đính kèm.
        Смотрите приложение с отчётом.
      """;

      final matches = AttachmentTextDetector.matchedKeywordsAll(email);

      expect(matches.keys, containsAll(['en', 'vi', 'ru']));
      expect(matches['en'], contains('attach'));
      expect(matches['vi'], containsAll(['tài liệu', 'đính kèm']));
      expect(matches['ru'], containsAll(['приложение', 'отчёт']));
    });

    test('should return matches only for one language', () {
      const email = "Veuillez trouver la pièce jointe.";

      final matches = AttachmentTextDetector.matchedKeywordsAll(email);

      expect(matches.keys, equals(['fr']));
      expect(matches['fr'], contains('pièce jointe'));
    });

    test('should return empty map when no keywords found', () {
      const email = "Completely unrelated text.";

      final matches = AttachmentTextDetector.matchedKeywordsAll(email);

      expect(matches, isEmpty);
    });

    test('should be case-insensitive', () {
      const email = "ATTACHMENT and PiÈce Jointe included.";

      final matches = AttachmentTextDetector.matchedKeywordsAll(email);

      expect(matches['en'], contains('attachment'));
      expect(matches['fr'], contains('pièce jointe'));
    });
  });

  group('AttachmentTextDetector.matchedKeywordsUnique', () {
    test('should return unique matches across multiple languages', () {
      const email = """
        Please see the attached document.
        Vui lòng xem tài liệu đính kèm.
        Смотрите приложение с отчетом.
      """;

      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);

      expect(matches, containsAll(['attach', 'tài liệu', 'đính kèm', 'приложение']));
      expect(matches.toSet().length, matches.length, reason: 'No duplicates allowed');
    });

    test('should return unique matches even if repeated multiple times', () {
      const email = """
        file file file attach attach attach 
        đính kèm đính kèm 
        приложение приложение
      """;

      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);

      expect(matches, containsAll(['file', 'attach', 'đính kèm', 'приложение']));
      expect(matches.toSet().length, matches.length, reason: 'Duplicates must be removed');
    });

    test('should return empty list if no keywords present', () {
      const email = "This email does not mention anything related to document.";
      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, isEmpty);
    });

    test('should match Russian word with both ё and е', () {
      const email = "Вот наш отчёт и вот наш снова.";
      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);

      expect(matches, containsAll(['отчёт']));
    });
  });

  /// Measure performance when detecting long emails, e.g. several thousand characters
  group('AttachmentTextDetector Benchmark', () {
    late String longEmail;

    setUp(() {
      // Generate email ~50,000 characters long (many unrelated paragraphs)
      final buffer = StringBuffer();
      const sample = "This is a random paragraph with no attachments. ";
      for (int i = 0; i < 1000; i++) {
        buffer.write(sample);
      }
      // Insert some keywords in the middle
      buffer.write("Here is the pièce jointe and báo cáo attached.");
      longEmail = buffer.toString();
    });

    test('Benchmark containsAnyAttachmentKeyword', () {
      final sw = Stopwatch()..start();
      final result =
          AttachmentTextDetector.containsAnyAttachmentKeyword(longEmail);
      sw.stop();

      log(
        'containsAnyAttachmentKeyword -> result=$result, elapsed=${sw.elapsedMicroseconds}µs',
      );
      expect(result, isTrue);
    });

    test('Benchmark matchedKeywordsAll', () {
      final sw = Stopwatch()..start();
      final matches = AttachmentTextDetector.matchedKeywordsAll(longEmail);
      sw.stop();

      log(
        'matchedKeywordsAll -> found=${matches.keys}, elapsed=${sw.elapsedMicroseconds}µs',
      );
      expect(matches.isNotEmpty, isTrue);
    });
  });

  /// Compare time when email is 100K, 500K, 1M characters long
  group('AttachmentTextDetector Stress Benchmark', () {
    final sizes = [100000, 500000, 1000000]; // 100K, 500K, 1M characters

    for (final size in sizes) {
      test('Benchmark size=$size containsAnyAttachmentKeyword', () {
        final email = generateLongEmail(size);
        final sw = Stopwatch()..start();
        final result =
            AttachmentTextDetector.containsAnyAttachmentKeyword(email);
        sw.stop();

        log(
          'containsAnyAttachmentKeyword(size=$size) -> result=$result, elapsed=${sw.elapsedMilliseconds}ms',
        );
        expect(result, isTrue);
      });

      test('Benchmark size=$size matchedKeywordsAll', () {
        final email = generateLongEmail(size);
        final sw = Stopwatch()..start();
        final matches = AttachmentTextDetector.matchedKeywordsAll(email);
        sw.stop();

        log(
          'matchedKeywordsAll(size=$size) -> found=${matches.keys}, elapsed=${sw.elapsedMilliseconds}ms',
        );
        expect(matches.isNotEmpty, isTrue);
      });
    }
  });
}
