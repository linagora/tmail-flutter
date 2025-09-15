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

      expect(matches,
          containsAll(['attach', 'tài liệu', 'đính kèm', 'приложение']));
      expect(matches.toSet().length, matches.length,
          reason: 'No duplicates allowed');
    });

    test('should return unique matches even if repeated multiple times', () {
      const email = """
        file file file attach attach attach 
        đính kèm đính kèm 
        приложение приложение
      """;

      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);

      expect(
          matches, containsAll(['file', 'attach', 'đính kèm', 'приложение']));
      expect(matches.toSet().length, matches.length,
          reason: 'Duplicates must be removed');
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

  /// Test input validation and edge cases
  group('AttachmentTextDetector Input Validation', () {
    test('should handle empty input gracefully', () {
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword(''), isFalse);
      expect(AttachmentTextDetector.matchedKeywordsUnique(''), isEmpty);
      expect(AttachmentTextDetector.matchedKeywordsAll(''), isEmpty);
    });

    test('should handle special characters and symbols', () {
      const email = "attach@#\$%^&*()_+ pièce jointe!@#\$%";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, containsAll(['attach', 'pièce jointe']));
    });

    test('should handle whitespace-only input', () {
      const email = "   \n\t\r   ";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isFalse);
      expect(AttachmentTextDetector.matchedKeywordsUnique(email), isEmpty);
    });

    test('should handle newlines and tabs in content', () {
      const email = "Please\nsee\tthe\r\nattached\tdocument.";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
    });
  });

  /// Test language code edge cases and validation
  group('AttachmentTextDetector Language Code Validation', () {
    test('should handle invalid language codes', () {
      expect(
          AttachmentTextDetector.containsAttachmentKeyword("attach", lang: ""),
          isFalse);
      expect(
          AttachmentTextDetector.containsAttachmentKeyword("attach",
              lang: "invalid"),
          isFalse);
      expect(
          AttachmentTextDetector.containsAttachmentKeyword("attach",
              lang: "xyz"),
          isFalse);
    });

    test('should handle language code case variations', () {
      expect(
          AttachmentTextDetector.containsAttachmentKeyword("attach",
              lang: "EN"),
          isTrue);
      expect(
          AttachmentTextDetector.containsAttachmentKeyword("attach",
              lang: "En"),
          isTrue);
      expect(
          AttachmentTextDetector.containsAttachmentKeyword("pièce jointe",
              lang: "FR"),
          isTrue);
      expect(
          AttachmentTextDetector.containsAttachmentKeyword("pièce jointe",
              lang: "Fr"),
          isTrue);
    });

    test('should return empty results for unsupported languages', () {
      expect(AttachmentTextDetector.matchedKeywords("attach", lang: "de"),
          isEmpty);
      expect(AttachmentTextDetector.matchedKeywords("attach", lang: "es"),
          isEmpty);
      expect(AttachmentTextDetector.matchedKeywords("attach", lang: "ja"),
          isEmpty);
    });
  });

  /// Test boundary conditions and word matching
  group('AttachmentTextDetector Boundary Conditions', () {
    test('should handle keywords at text boundaries', () {
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attach"),
          isTrue);
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attachment."),
          isTrue);
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword(".attach"),
          isTrue);
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword("(attachment)"),
          isTrue);
    });

    test('should handle partial word matches correctly', () {
      // Should NOT match "attach" in words where it's just a substring
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("detachment"),
          isFalse);
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword("reattachment"),
          isTrue); // contains "attachment"
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attachments"),
          isTrue); // contains "attachment"
    });

    test('should handle keywords with punctuation', () {
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attach,"),
          isTrue);
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attach;"),
          isTrue);
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attach:"),
          isTrue);
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attach?"),
          isTrue);
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("attach!"),
          isTrue);
    });

    test('should handle single character boundaries', () {
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("a"), isFalse);
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword("file"),
          isTrue); // Vietnamese keyword
    });
  });

  /// Test Unicode and encoding edge cases
  group('AttachmentTextDetector Unicode Handling', () {
    test('should handle emoji and special Unicode characters', () {
      const email = "📎 attachment 📄 file 🔗 pièce jointe";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, containsAll(['attachment', 'file', 'pièce jointe']));
    });

    test('should handle mixed Unicode scripts', () {
      const email = "文档 attachment документ pièce jointe تقرير";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
    });

    test('should handle Unicode normalization variations', () {
      // Test composed vs decomposed Unicode characters for French
      const email1 = "pièce jointe"; // é as single character (NFC)
      const email2 =
          "pie\u0300ce jointe"; // é as e + combining grave accent (NFD)
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email1), isTrue);
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email2), isTrue);
    });

    test('should handle zero-width characters', () {
      const email = "attach\u200Bment"; // Zero-width space
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
    });
  });

  /// Test real-world scenarios and integration cases
  group('AttachmentTextDetector Real-World Scenarios', () {
    test('should handle common email signatures and footers', () {
      const email = """
        Please review the attached document.
        
        Best regards,
        John Doe
        
        This email and any attachments are confidential and may be privileged.
      """;
      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, containsAll(['attach', 'attachment']));
    });

    test('should handle HTML-like content', () {
      const email =
          "Please see the <b>attached</b> document in the &lt;file&gt; section.";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
    });

    test('should handle quoted email content', () {
      const email = """
        Hi John,
        
        Please find the attachment below.
        
        > On Mon, Jan 1, 2024, Jane wrote:
        > I need the document attached to your previous email.
        > Can you resend the file?
        
        Thanks!
      """;
      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, containsAll(['attachment', 'attach', 'file']));
    });

    test('should handle multiple languages in single email', () {
      const email = """
        English: Please see the attached file.
        French: Veuillez voir le fichier joint.
        Vietnamese: Vui lòng xem tài liệu đính kèm.
        Russian: Пожалуйста, смотрите приложение.
      """;
      final matchesAll = AttachmentTextDetector.matchedKeywordsAll(email);
      expect(matchesAll.keys, containsAll(['en', 'fr', 'vi', 'ru']));

      final matchesUnique = AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(
          matchesUnique,
          containsAll([
            'attach',
            'file',
            'fichier joint',
            'joint',
            'tài liệu',
            'đính kèm',
            'приложение'
          ]));
    });

    test('should handle email threading and forwarding markers', () {
      const email = """
        FW: Important Document
        
        Please see attached report.
        
        -----Original Message-----
        From: sender@example.com
        The attachment contains sensitive information.
      """;
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
    });
  });

  /// Test performance and memory edge cases
  group('AttachmentTextDetector Performance Edge Cases', () {
    test('should handle extremely large input without memory issues', () {
      // Test with 5MB+ content
      final hugeEmail = generateLongEmail(5000000, includeKeywords: false);
      expect(
          () => AttachmentTextDetector.containsAnyAttachmentKeyword(hugeEmail),
          returnsNormally);
    });

    test('should handle repeated keyword patterns efficiently', () {
      final email = "attach " * 10000; // 10K repetitions
      final sw = Stopwatch()..start();
      final result = AttachmentTextDetector.matchedKeywordsUnique(email);
      sw.stop();

      expect(result, equals(['attach']));
      expect(sw.elapsedMilliseconds, lessThan(100)); // Should complete quickly
    });

    test('should handle very long single line efficiently', () {
      final longLine = "word " * 100000 + "attachment"; // 100K words + keyword
      final sw = Stopwatch()..start();
      final result =
          AttachmentTextDetector.containsAnyAttachmentKeyword(longLine);
      sw.stop();

      expect(result, isTrue);
      expect(sw.elapsedMilliseconds,
          lessThan(500)); // Should complete within 500ms
    });

    test('should handle many different keywords in large text', () {
      final email = """
        attach attachment file document report
        pièce jointe fichier joint document joint
        приложение документ файл отчёт вложение
        đính kèm tài liệu tệp báo cáo
      """ *
          1000; // Repeat 1000 times

      final sw = Stopwatch()..start();
      final matches = AttachmentTextDetector.matchedKeywordsUnique(email);
      sw.stop();

      expect(matches.length, greaterThan(10));
      expect(sw.elapsedMilliseconds,
          lessThan(1000)); // Should complete within 1 second
    });
  });
}
