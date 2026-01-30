import 'package:core/utils/app_logger.dart';
import 'package:core/utils/config/app_config_loader.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_keyword_config_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_keywords_configuration_parser.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_text_detector.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/attachment_keyword_config.dart';

import 'attachment_text_detector_test.mocks.dart';

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

@GenerateMocks([AppConfigLoader])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Replicates the exact pipeline inside [validateAttachmentReminder]:
  ///   1. Concatenate subject + body
  ///   2. Strip HTML (removes blockquotes, scripts, styles, tmail-signature)
  ///   3. Run keyword detection with config include/exclude lists
  Future<List<String>> runPipeline({
    required String subject,
    required String body,
    List<String> includeList = const [],
    List<String> excludeList = const [],
  }) async {
    final fullContent = '$subject $body';
    final plainText = HtmlUtils.extractPlainText(fullContent);
    return AttachmentTextDetector.matchedKeywordsUnique(
      plainText,
      includeList: includeList,
      excludeList: excludeList,
      forceSync: true,
    );
  }

  late MockAppConfigLoader mockLoader;

  setUp(() {
    AttachmentKeywordConfigManager().clearCache();
    mockLoader = MockAppConfigLoader();
    AttachmentKeywordConfigManager().injectLoader(mockLoader);
    AttachmentTextDetector.clearPatternCache();
  });

  group('AttachmentTextDetector.matchedKeywordsUnique', () {
    test('should return unique matches across multiple languages', () async {
      const email = """
        Please see the attached document.
        Vui lòng xem tài liệu đính kèm.
        Смотрите приложение с отчетом.
      """;

      final matches = await AttachmentTextDetector.matchedKeywordsUnique(email);

      expect(matches, containsAll(['tài liệu', 'đính kèm', 'приложение']));
      expect(matches.toSet().length, matches.length,
          reason: 'No duplicates allowed');
    });

    test('should return unique matches even if repeated multiple times',
        () async {
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
  });

  /// Test performance and memory edge cases
  group('AttachmentTextDetector Performance Edge Cases', () {
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
    test('matchedKeywordsUnique should return unique Arabic keywords only',
        () async {
      const text = 'مرفق ملف مرفق تقرير ملف';
      final result = await AttachmentTextDetector.matchedKeywordsUnique(text);

      expect(result, containsAll(['مرفق', 'ملف', 'تقرير']));
      // Ensure no duplicates
      expect(result.length, equals(3));
    });

    test(
        'matchedKeywordsUnique should return unique keywords from all languages',
        () async {
      const text =
          'Attached báo cáo مرفق pièce jointe file مستند attach đính kèm';

      final result = await AttachmentTextDetector.matchedKeywordsUnique(text);

      expect(
          result,
          containsAll([
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
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'Check file123 now.');
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
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            'See attachment.');

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
      test('Large Text Performance: Should process 100k chars under 50ms',
          () async {
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
      final result = await AttachmentTextDetector.matchedKeywordsUnique(
          'Check file attachment');
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
          'IncludeList: Should strictly accept listed tokens and reject others',
          () async {
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

      test(
          'Include List should ADD keywords to detection (Fixing previous issue)',
          () async {
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

        final stopwatch = Stopwatch()..start();

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

        final stopwatch = Stopwatch()..start();

        final result = await AttachmentTextDetector.matchedKeywordsUnique(
          bigText,
          includeList: ['file-vip'],
        );

        stopwatch.stop();
        log('Total Async Time (incl. Isolate spawn): ${stopwatch.elapsedMilliseconds}ms');

        expect(result, contains('file-vip'));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('Safety: Input with potential catastrophic backtracking', () async {
        final trickyText = "${"a" * 50000} file ${"b" * 50000}";

        final stopwatch = Stopwatch()..start();
        final result = await AttachmentTextDetector.matchedKeywordsUnique(
            trickyText,
            forceSync: true);
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

  group('validateAttachmentReminder pipeline - subject scanning', () {
    test('detects keyword in subject even when body is empty', () async {
      final result = await runPipeline(
        subject: 'Please find the attached document',
        body: '',
      );
      expect(result, contains('attached'));
    });

    test('detects keyword in body even when subject is empty', () async {
      final result = await runPipeline(
        subject: '',
        body: 'I have attached the file for your review.',
      );
      expect(result, containsAll(['attached', 'file']));
    });

    test('detects keywords from both subject and body', () async {
      final result = await runPipeline(
        subject: 'Attachment for project',
        body: 'Please see the file I mentioned.',
      );
      expect(result, containsAll(['attachment', 'file']));
    });

    test('returns empty when neither subject nor body has keywords', () async {
      final result = await runPipeline(
        subject: 'Meeting tomorrow',
        body: 'Let us discuss the agenda.',
      );
      expect(result, isEmpty);
    });
  });

  group('validateAttachmentReminder pipeline - HTML stripping', () {
    test('detects keyword wrapped in HTML tags', () async {
      final result = await runPipeline(
        subject: '',
        body: '<p>Please review the <b>attached</b> document.</p>',
      );
      expect(result, contains('attached'));
    });

    test('detects keyword inside nested HTML structure', () async {
      final result = await runPipeline(
        subject: '',
        body:
            '<div><p><span>See the <em>file</em> for details.</span></p></div>',
      );
      expect(result, contains('file'));
    });

    test('does NOT detect keyword inside blockquote (quoted reply)', () async {
      final result = await runPipeline(
        subject: '',
        body: '''
          <p>Thanks for your message.</p>
          <blockquote>
            <p>Original: please find the file attached.</p>
          </blockquote>
        ''',
      );
      // Only "Thanks for your message" is scanned — blockquote is stripped
      expect(result, isEmpty);
    });

    test('does NOT detect keyword inside tmail-signature div', () async {
      final result = await runPipeline(
        subject: '',
        body: '''
          <p>Looking forward to the meeting.</p>
          <div class="tmail-signature">
            <p>Best regards, John. Please find attached my contact card.</p>
          </div>
        ''',
      );
      // "Looking forward to the meeting" has no attachment keywords
      // signature is stripped — no false alarm
      expect(result, isEmpty);
    });

    test('detects keyword in body even when signature also has keywords',
        () async {
      final result = await runPipeline(
        subject: '',
        body: '''
          <p>I have attached the report.</p>
          <div class="tmail-signature">
            <p>Please find attached my vCard.</p>
          </div>
        ''',
      );
      // Signature stripped, but body keyword remains
      expect(result, contains('attached'));
    });
  });

  group('validateAttachmentReminder pipeline - includeList config', () {
    test('detects custom keyword from includeList', () async {
      final result = await runPipeline(
        subject: '',
        body: 'Please review the invoice I prepared.',
        includeList: ['invoice'],
      );
      expect(result, contains('invoice'));
    });

    test('does NOT detect custom keyword when not in includeList', () async {
      final result = await runPipeline(
        subject: '',
        body: 'Please review the invoice I prepared.',
        // No includeList → 'invoice' is not a default keyword
      );
      expect(result, isEmpty);
    });

    test('detects both default and custom keywords together', () async {
      final result = await runPipeline(
        subject: '',
        body: 'Please find the attached invoice.',
        includeList: ['invoice'],
      );
      expect(result, containsAll(['attached', 'invoice']));
    });
  });

  group('validateAttachmentReminder pipeline - excludeList config', () {
    test('blocks specific token matching an exclude entry', () async {
      final result = await runPipeline(
        subject: '',
        body: 'Refer to ticket file-246 for details.',
        excludeList: ['file-246'],
      );
      // "file" matched but surrounded by "-246" → token "file-246" is blocked
      expect(result, isEmpty);
    });

    test('keeps standalone keyword not matching any exclude entry', () async {
      final result = await runPipeline(
        subject: '',
        body: 'Please send the file today.',
        excludeList: ['file-246'],
      );
      // "file" is standalone — not blocked
      expect(result, contains('file'));
    });

    test('blocks excluded token but keeps other keywords in same text',
        () async {
      final result = await runPipeline(
        subject: '',
        body: 'See file-246 and also the attached document.',
        excludeList: ['file-246'],
      );
      expect(result, isNot(contains('file')));
      expect(result, contains('attached'));
    });
  });

  group('validateAttachmentReminder pipeline - config manager integration', () {
    test('uses includeList and excludeList from loaded config', () async {
      when(mockLoader.load<AttachmentKeywordConfig>(
        any,
        argThat(isA<AttachmentKeywordsConfigurationParser>()),
      )).thenAnswer((_) async => AttachmentKeywordConfig(
            includeList: ['invoice'],
            excludeList: ['file-246'],
          ));

      final config = await AttachmentKeywordConfigManager().getConfig();

      final result = await runPipeline(
        subject: '',
        body: 'See file-246 and the attached invoice.',
        includeList: config.includeList,
        excludeList: config.excludeList,
      );

      expect(result, isNot(contains('file'))); // blocked by excludeList
      expect(result, contains('invoice')); // added by includeList
      expect(result, contains('attached')); // default keyword
    });

    test('falls back to empty config when loader throws', () async {
      when(mockLoader.load<AttachmentKeywordConfig>(any, any))
          .thenThrow(Exception('config not found'));

      final config = await AttachmentKeywordConfigManager().getConfig();

      // Fallback config has empty lists — only default keywords are detected
      final result = await runPipeline(
        subject: '',
        body: 'Please find the file attached.',
        includeList: config.includeList,
        excludeList: config.excludeList,
      );

      expect(result, containsAll(['file', 'attached']));
    });
  });

  group('validateAttachmentReminder pipeline - edge cases', () {
    test('returns empty for empty subject and body', () async {
      final result = await runPipeline(subject: '', body: '');
      expect(result, isEmpty);
    });

    test('returns empty for whitespace-only content', () async {
      final result = await runPipeline(
        subject: '   ',
        body: '   \n\t  ',
      );
      expect(result, isEmpty);
    });

    test('deduplicates when keyword appears in both subject and body',
        () async {
      final result = await runPipeline(
        subject: 'File attached',
        body: '<p>The file is ready, attached for review.</p>',
      );
      expect(result.where((k) => k == 'file').length, equals(1));
      expect(result.where((k) => k == 'attached').length, equals(1));
    });
  });
}
