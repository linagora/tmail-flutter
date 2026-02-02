import 'package:core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_text_detector.dart';
import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();
  
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
    test('should return unique matches across multiple languages', () async {
      const email = """
        Please see the attached document.
        Vui lòng xem tài liệu đính kèm.
        Смотрите приложение с отчетом.
      """;

      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);

      expect(matches,
          containsAll(['tài liệu', 'đính kèm', 'приложение']));
      expect(matches.toSet().length, matches.length,
          reason: 'No duplicates allowed');
    });

    test('should return unique matches even if repeated multiple times', () async {
      const email = """
        file file file attach attach attach 
        đính kèm đính kèm 
        приложение приложение
      """;

      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);

      expect(
          matches, containsAll(['file', 'attach', 'đính kèm', 'приложение']));
      expect(matches.toSet().length, matches.length,
          reason: 'Duplicates must be removed');
    });

    test('should return empty list if no keywords present', () async {
      const email = "This email does not mention anything related to document.";
      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, isEmpty);
    });

    test('should match Russian word with both ё and е', () async {
      const email = "Вот наш отчёт и вот наш снова.";
      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);

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
    test('should handle empty input gracefully', () async {
      expect(AttachmentTextDetector.containsAnyAttachmentKeyword(''), isFalse);
      expect((await AttachmentTextDetector.matchedKeywordsUnique('')), isEmpty);
      expect(AttachmentTextDetector.matchedKeywordsAll(''), isEmpty);
    });

    test('should handle special characters and symbols', () async {
      const email = "attach@#\$%^&*()_+ pièce jointe!@#\$%";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, containsAll(['attach', 'pièce jointe']));
    });

    test('should handle whitespace-only input', () async {
      const email = "   \n\t\r   ";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isFalse);
      expect((await AttachmentTextDetector.matchedKeywordsUnique(email)), isEmpty);
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
    test('should handle emoji and special Unicode characters', () async {
      const email = "📎 attachment 📄 file 🔗 pièce jointe";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);
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
    test('should handle common email signatures and footers', () async {
      const email = """
        Please review the attached document.
        
        Best regards,
        John Doe
        
        This email and any attachments are confidential and may be privileged.
      """;
      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, containsAll(['attached', 'attachments']));
    });

    test('should handle HTML-like content', () {
      const email =
          "Please see the <b>attached</b> document in the &lt;file&gt; section.";
      expect(
          AttachmentTextDetector.containsAnyAttachmentKeyword(email), isTrue);
    });

    test('should handle quoted email content', () async {
      const email = """
        Hi John,
        
        Please find the attachment below.
        
        > On Mon, Jan 1, 2024, Jane wrote:
        > I need the document attached to your previous email.
        > Can you resend the file?
        
        Thanks!
      """;
      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(matches, containsAll(['attachment', 'attached', 'file']));
    });

    test('should handle multiple languages in single email', () async {
      const email = """
        English: Please see the attached file.
        French: Veuillez voir le fichier joint.
        Vietnamese: Vui lòng xem tài liệu đính kèm.
        Russian: Пожалуйста, смотрите приложение.
      """;
      final matchesAll = AttachmentTextDetector.matchedKeywordsAll(email);
      expect(matchesAll.keys, containsAll(['en', 'fr', 'vi', 'ru']));

      final matchesUnique = await AttachmentTextDetector.matchedKeywordsUnique(email);
      expect(
          matchesUnique,
          containsAll([
            'attached',
            'file',
            'fichier joint',
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

    test('should handle repeated keyword patterns efficiently', () async {
      final email = "attach " * 10000; // 10K repetitions, ~70k chars
      final sw = Stopwatch()..start();
      final result = await AttachmentTextDetector.matchedKeywordsUnique(
        email,
        forceSync: true,
      );
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

    test('should handle many different keywords in large text', () async {
      final email = """
        attach attachment file document report
        pièce jointe fichier joint document joint
        приложение документ файл отчёт вложение
        đính kèm tài liệu tệp báo cáo
      """ *
          1000; // Repeat 1000 times, ~200,000 chars

      final sw = Stopwatch()..start();
      final matches = await AttachmentTextDetector.matchedKeywordsUnique(
        email,
        forceSync: true,
      );
      sw.stop();

      expect(matches.length, greaterThan(10));
      expect(sw.elapsedMilliseconds, lessThan(3000));
    });
  });

  /// Test edge cases in Arabic language
  group('AttachmentTextDetector Arabic Tests', () {
    const lang = LanguageCodeConstants.arabic;

    test('containsAttachmentKeyword should return true when Arabic keyword exists', () {
      const text = 'الرجاء مراجعة المستند المرفق';
      final result = AttachmentTextDetector.containsAttachmentKeyword(text, lang: lang);
      expect(result, isTrue);
    });

    test('containsAttachmentKeyword should return false when no Arabic keyword exists', () {
      const text = 'مرحبا كيف حالك اليوم؟';
      final result = AttachmentTextDetector.containsAttachmentKeyword(text, lang: lang);
      expect(result, isFalse);
    });

    test('matchedKeywords should return matched Arabic keywords', () {
      const text = 'تم إرسال ملف تقرير مرفق مع الرسالة';
      final result = AttachmentTextDetector.matchedKeywords(text, lang: lang);
      expect(result, containsAll(['ملف', 'تقرير', 'مرفق']));
    });

    test('matchedKeywords matches singular when plural form appears (e.g., مرفقات contains مرفق)', () {
      const text = 'هذه مجرد رسالة عادية بدون أي مرفقات';
      final result = AttachmentTextDetector.matchedKeywords(text, lang: LanguageCodeConstants.arabic);
      expect(result, contains('مرفق'));
      expect(result, isNotEmpty);
    });

    test('matchedKeywords should return empty list when no Arabic keywords exist', () {
      const text = 'هذه رسالة للتجربة فقط بدون أي صور أو روابط.';
      final result = AttachmentTextDetector.matchedKeywords(text, lang: LanguageCodeConstants.arabic);
      expect(result, isEmpty);
    });

    test('containsAnyAttachmentKeyword should detect Arabic keyword among all languages', () {
      const text = 'مرفق هام موجود في هذه الرسالة';
      final result = AttachmentTextDetector.containsAnyAttachmentKeyword(text);
      expect(result, isTrue);
    });

    test('matchedKeywordsAll should return only Arabic matches', () {
      const text = 'إليك المستند مرفق للعرض';
      final result = AttachmentTextDetector.matchedKeywordsAll(text);

      expect(result.keys, contains(lang));
      expect(result[lang], containsAll(['مستند', 'مرفق']));
      // Make sure there are no other languages
      expect(result.keys.length, equals(1));
    });

    test('matchedKeywordsUnique should return unique Arabic keywords only', () async {
      const text = 'مرفق ملف مرفق تقرير ملف';
      final result = await AttachmentTextDetector.matchedKeywordsUnique(text);

      expect(result, containsAll(['مرفق', 'ملف', 'تقرير']));
      // Ensure no duplicates
      expect(result.length, equals(3));
    });

    test('containsAnyAttachmentKeyword detects keywords across multiple languages', () {
      const text = 'Please see the attached document. '
          'الرجاء مراجعة المستند المرفق. '
          'Vui lòng xem tài liệu đính kèm.';

      final result = AttachmentTextDetector.containsAnyAttachmentKeyword(text);
      expect(result, isTrue);
    });

    test('matchedKeywordsAll should return matches grouped by language', () {
      const text = 'Here is the attachment. '
          'إليك ملف تقرير مرفق. '
          'Vui lòng xem báo cáo đính kèm. '
          'pièce jointe est incluse.';

      final result = AttachmentTextDetector.matchedKeywordsAll(text);

      expect(result.keys, containsAll([
        LanguageCodeConstants.english,
        LanguageCodeConstants.arabic,
        LanguageCodeConstants.vietnamese,
        LanguageCodeConstants.french,
      ]));

      expect(result[LanguageCodeConstants.english], contains('attachment'));
      expect(result[LanguageCodeConstants.arabic], containsAll(['ملف', 'تقرير', 'مرفق']));
      expect(result[LanguageCodeConstants.vietnamese], containsAll(['báo cáo', 'đính kèm']));
      expect(result[LanguageCodeConstants.french], contains('pièce jointe'));
    });

    test('matchedKeywordsUnique should return unique keywords from all languages', () async {
      const text = 'Attached báo cáo مرفق pièce jointe file مستند attach đính kèm';

      final result = await AttachmentTextDetector.matchedKeywordsUnique(text);

      expect(result, containsAll([
        'attach',
        'pièce jointe',
        'đính kèm',
        'báo cáo',
        'file',
        'مرفق',
        'مستند'
      ]));

      // Ensure no duplicates
      expect(result.length, equals(result.toSet().length));
    });
  });

  group('AttachmentTextDetector.matchedKeywordsUnique', () {
    group('Logic Tests', () {
      test('Basic Match: Should detect simple keywords', () async {
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'Please find the attachment.');
        expect(result, contains('attachment'));
      });

      test('Case Insensitivity: Should detect mixed case keywords', () async {
        final result =
            await AttachmentTextDetector.matchedKeywordsUnique('FiLe is here');
        expect(result, contains('file'));
      });

      test('Unique Results: Should not return duplicates', () async {
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'File here, file there, FILE everywhere.');
        expect(result.length, 1);
        expect(result, contains('file'));
      });

      test('Multiple Keywords: Should detect different keywords', () async {
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'See file and attachment');
        expect(result, containsAll(['file', 'attachment']));
      });
    });

    group('Suffix & Boundary Tests (Crucial)', () {
      test(
          'Invalid Suffix: Should IGNORE words extended by letters (e.g., filetage)',
          () async {
        // "filetage" contains "file", but followed by 't' (letter) -> Should fail
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'This is a filetage system.');
        expect(result, isEmpty);
      });

      test(
          'Valid Suffix (Number): Should ACCEPT words followed by numbers (e.g., file123)',
          () async {
        final result =
            await AttachmentTextDetector.matchedKeywordsUnique('Check file123 now.');
        expect(result, contains('file'));
      });

      test(
          'Valid Suffix (Punctuation): Should ACCEPT words followed by punctuation',
          () async {
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'Is this a file? Yes, file.');
        expect(result, contains('file'));
      });

      test('Valid Suffix (Whitespace): Should ACCEPT words followed by space',
          () async {
        final result =
            await AttachmentTextDetector.matchedKeywordsUnique('file name');
        expect(result, contains('file'));
      });

      test('Valid Suffix (End of String): Should ACCEPT word at the very end',
          () async {
        final result =
            await AttachmentTextDetector.matchedKeywordsUnique('Open file');
        expect(result, contains('file'));
      });
    });

    group('Complex & Unicode Tests', () {
      test(
          'Longest Match Priority: Should match "attachment" instead of "attach"',
          () async {
        // Because we sort by length desc, "attachment" comes before "attach" in regex
        final result =
            await AttachmentTextDetector.matchedKeywordsUnique('See attachment.');

        expect(result, contains('attachment'));
        // Note: "attachment" contains "attach", but since it consumes the text,
        // "attach" usually won't be reported separately if they overlap fully,
        // dependent on regex engine. In our logic, it matches the longest token.
        expect(result, isNot(contains('attach')));
      });

      test('Vietnamese Support: Should detect keywords with accents', () async {
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'Gửi tài liệu đính kèm.');
        expect(result, containsAll(['tài liệu', 'đính kèm']));
      });

      test('Russian Support: Should detect Cyrillic characters', () async {
        final result =
            await AttachmentTextDetector.matchedKeywordsUnique('Это файл.');
        expect(result, contains('файл'));
      });

      test('Arabic Support: Should detect Arabic characters', () async {
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'هذا ملف مهم'); // "This is an important file"
        expect(result, contains('ملف'));
      });
    });

    group('Performance Benchmark', () {
      test('Large Text Performance: Should process 100k chars under 50ms', () async {
        // Generate a large text (~100k characters)
        final buffer = StringBuffer();
        for (int i = 0; i < 5000; i++) {
          buffer.write('This is some random text without keywords. ');
          if (i % 100 == 0) {
            buffer.write('file '); // Insert keyword occasionally
          }
          if (i % 150 == 0) buffer.write('filetage '); // Insert trap word
        }
        final largeText = buffer.toString(); // ~215k chars

        // Measure execution time
        final stopwatch = Stopwatch()..start();
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          largeText,
          forceSync: true,
        );
        stopwatch.stop();

        log('Performance result: Found ${result.length} keywords in ${stopwatch.elapsedMilliseconds}ms for ${largeText.length} chars.');

        // Assertions
        expect(result, contains('file'));
        expect(result, isNot(contains('filetage'))); // Ensure trap didn't work

        // Typical optimized regex should be VERY fast (<10ms for 100k chars on modern CPU)
        // Setting 50ms as a safe upper bound for CI environments.
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });
  });

  group('AttachmentTextDetector with exclude filter', () {
    test('Basic detection without filters', () async {
      final result =
          await AttachmentTextDetector.matchedKeywordsUnique('Check file attachment');
      expect(result, containsAll(['file', 'attachment']));
    });

    test('Exclude Filter: Should exclude blacklisted tokens', () async {
      final result = await AttachmentTextDetector.matchedKeywordsUnique(
        'Check file-246 and my_file please.',
        excludeList: ['file-246', 'my_file'],
      );

      expect(result, isEmpty);
    });

    test('Exclude Filter: Should NOT exclude partial matches', () async {
      final result = await AttachmentTextDetector.matchedKeywordsUnique(
        'Check file-999.',
        excludeList: ['file-246'],
      );

      expect(result, contains('file'));
    });

    test('Multiple Filters Integration (Future Proof)', () async {
      final result = await AttachmentTextDetector.matchedKeywordsUnique(
        'file-good vs file-bad',
        excludeList: ['file-bad'],
      );

      expect(result, contains('file'));
      expect(result, isNot(contains('file-bad')));
    });
  });

  group('AttachmentTextDetector Sync vs Async Logic', () {
    test('Should run SYNC for short text and detect keywords', () async {
      const shortText = "Please check the attached file for details.";

      expect(shortText.length, lessThan(20000));

      final result =
          await AttachmentTextDetector.matchedKeywordsUnique(shortText);

      expect(result, containsAll(['attached', 'file']));
    });

    test('Should run ASYNC (via compute) for large text', () async {
      final sb = StringBuffer();
      sb.write("nonsense " * 3000);
      sb.write(" attachment ");
      sb.write("garbage " * 1000);

      final longText = sb.toString();

      expect(longText.length, greaterThan(20000));

      final result =
          await AttachmentTextDetector.matchedKeywordsUnique(longText);

      expect(result, contains('attachment'));
      expect(result, isNot(contains('nonsense')));
    });

    test(
        'Should apply Filters correctly even when running in Isolate (Long text)',
        () async {
      final sb = StringBuffer();
      sb.write("padding " * 3000);
      sb.write(" file-246 ");
      sb.write(" file-ok ");
      sb.write("padding " * 1000);

      final longText = sb.toString();

      final result = await AttachmentTextDetector.matchedKeywordsUnique(
        longText,
        excludeList: ['file-246'],
      );

      expect(result, contains('file'));
    });

    test('Should handle multiple async calls concurrently', () async {
      final longText = "file " * 4000; // ~20k chars

      final futures = List.generate(
          10, (_) => AttachmentTextDetector.matchedKeywordsUnique(longText));

      final results = await Future.wait(futures);

      for (final res in results) {
        expect(res, contains('file'));
      }
    });
  });

  group('AttachmentTextDetector (Include/Exclude) filters', () {
    group('Strict Logic Tests (Include/Exclude)', () {
      test(
          'IncludeList: Should strictly accept listed tokens and reject others', () async {
        const text = "Please see attachment-vip and delete file-trash.";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['attachment-vip'],
          forceSync: true,
        );

        expect(result, contains('attachment-vip'));
      });

      test('Edge Case: Punctuation & Case Sensitivity', () async {
        const text = "Check FILE-VIP. Also check file-vip, and\nfile-vip!";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['file-vip'],
          forceSync: true,
        );

        expect(result, contains('file-vip'));
        expect(result.length, 1);
      });

      test('Edge Case: Conflict (Include vs Exclude)', () async {
        const text = "This is a file-report.";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['file-report'],
          excludeList: ['file-report'],
          forceSync: true,
        );

        expect(result, isEmpty);
      });

      test('Edge Case: Weird separators (Tabs, Double Spaces)', () async {
        const text = "Open\tfile-vip  and   file-bad";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['file-vip'],
          forceSync: true,
        );

        expect(result, contains('file'));

        const text2 = "Open\tattachment-vip  and   file-bad";
        final result2 = await AttachmentTextDetector.matchedKeywordsUnique(
          text2,
          includeList: ['attachment-vip'],
          forceSync: true,
        );

        expect(result2, contains('attachment-vip'));
      });

      test('Include List should ADD keywords to detection (Fixing previous issue)', () async {
        const text = "Please check the invoice-2024.";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['invoice'],
          forceSync: true,
        );

        expect(result, contains('invoice'));
      });

      test('Logic Flow: Include List (Add) -> Exclude List (Block)', () async {
        const text = "This is a secret-code.";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['secret'],
          excludeList: ['secret-code'],
          forceSync: true,
        );

        expect(result, isEmpty);
      });

      test('Logic Flow: Include List (Add) -> Exclude List (Pass)', () async {
        const text = "This is a secret-message.";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['secret'],
          excludeList: ['secret-code'],
          forceSync: true,
        );

        expect(result, contains('secret'));
      });
    });

    group('Performance & Load Tests', () {
      test('Benchmark: 100k chars with complex filters (Force Sync)', () async {
        final sb = StringBuffer();
        for (int i = 0; i < 5000; i++) {
          sb.write("random text ");
          if (i % 100 == 0) sb.write("file-vip ");
          if (i % 100 == 1) sb.write("file-trash ");
        }
        final bigText = sb.toString();

        final stopwatch = Stopwatch()
          ..start();

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          bigText,
          includeList: ['file-vip'],
          forceSync: true,
        );

        stopwatch.stop();
        log('Algorithm Time (100k chars): ${stopwatch.elapsedMilliseconds}ms');

        expect(result, contains('file'));
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('Integration: Large Text via Isolate (Async)', () async {
        final bigText = "file-vip " * 5000; // ~45k chars (> 20k threshold)

        final stopwatch = Stopwatch()
          ..start();

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          bigText,
          includeList: ['file-vip'],
        );

        stopwatch.stop();
        log('Total Async Time (incl. Isolate spawn): ${stopwatch
            .elapsedMilliseconds}ms');

        expect(result, contains('file-vip'));
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
      });

      test('Safety: Input with potential catastrophic backtracking', () async {
        final trickyText = "${"a" * 50000} file ${"b" * 50000}";

        final stopwatch = Stopwatch()
          ..start();
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            trickyText, forceSync: true);
        stopwatch.stop();

        expect(result, contains('file'));
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Real-world Context Tests', () {
      test(
          'IncludeList: Should only highlight official documents (e.g., invoice-2024)',
          () async {
        const text =
            "Please review the invoice-2024 and ignore the invoice-draft.";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          includeList: ['invoice-2024'],
          forceSync: true,
        );

        expect(result, contains('invoice-2024'));
      });

      test('ExcludeList: Should ignore false positives like email signatures',
          () async {
        const text = "See attached image. Best regards, signature-logo.";

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          text,
          excludeList: ['signature-logo'],
          forceSync: true,
        );

        expect(result, containsAll(['attached']));

        const textOnlySignature = "Best regards, signature-logo.";
        final resultSignature =
            await AttachmentTextDetector.matchedKeywordsUnique(
          textOnlySignature,
          excludeList: ['signature-logo'],
          forceSync: true,
        );
        expect(resultSignature, isEmpty);
      });

      test('Benchmark: Processing large email logs', () async {
        final sb = StringBuffer();
        for (int i = 0; i < 5000; i++) {
          sb.write("System check... ");
          if (i % 50 == 0) sb.write("contract-signed ");
          if (i % 50 == 1) sb.write("css-style-v2 ");
        }
        final bigLog = sb.toString();

        final stopwatch = Stopwatch()..start();

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          bigLog,
          includeList: ['contract-signed'],
          excludeList: ['css-style-v2'],
          forceSync: true,
        );

        stopwatch.stop();

        log('Processing Time: ${stopwatch.elapsedMilliseconds}ms');

        expect(result, contains('contract-signed'));
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}
