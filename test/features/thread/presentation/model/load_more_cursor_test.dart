import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/load_more_cursor.dart';

void main() {
  _cursorAfterListedEmailsTests();
  _overlappingCollapsedPageTests();
}

void _cursorAfterListedEmailsTests() {
  final listedEmails = List.generate(
    9,
    (i) => PresentationEmail(id: EmailId(Id('listed-$i'))),
  );

  group('LoadMoreCursor.after', () {
    test(
      'GIVEN threads are not collapsed '
      'WHEN the cursor is built '
      'THEN it SHOULD page from the oldest listed email, without an offset',
      () {
        final cursor = LoadMoreCursor.after(
          listedEmails,
          collapseThreads: false,
        );

        expect(cursor.oldestEmail, listedEmails.last);
        expect(cursor.position, isNull);
      },
    );

    test('GIVEN threads are collapsed '
        'WHEN the cursor is built '
        'THEN it SHOULD skip the listed threads, without a date bound', () {
      final cursor = LoadMoreCursor.after(listedEmails, collapseThreads: true);

      expect(cursor.position, listedEmails.length);
      expect(cursor.oldestEmail, isNull);
    });

    test('GIVEN nothing is listed '
        'WHEN the cursor is built '
        'THEN it SHOULD start from the first email', () {
      expect(LoadMoreCursor.after([], collapseThreads: true).position, 0);
      expect(
        LoadMoreCursor.after([], collapseThreads: false).oldestEmail,
        isNull,
      );
    });

    test(
      'GIVEN a collapsed offset bias '
      'WHEN the cursor is built '
      'THEN it SHOULD skip the listed threads plus the bias',
      () {
        final cursor = LoadMoreCursor.after(
          listedEmails,
          collapseThreads: true,
          positionBias: 20,
        );

        expect(cursor.position, listedEmails.length + 20);
        expect(cursor.oldestEmail, isNull);
      },
    );
  });
}

void _overlappingCollapsedPageTests() {
  group('LoadMoreCursor.isOverlappingCollapsedPage', () {
    bool overlapping({
      bool collapseThreads = true,
      int serverEmailCount = 20,
      int appendableEmailCount = 0,
    }) => LoadMoreCursor.isOverlappingCollapsedPage(
      collapseThreads: collapseThreads,
      serverEmailCount: serverEmailCount,
      appendableEmailCount: appendableEmailCount,
      pageSize: 20,
    );

    test(
      'GIVEN a full collapsed page holding only listed rows '
      'WHEN it is checked '
      'THEN it SHOULD be overlapping, the offset no longer matches the server',
      () {
        expect(overlapping(), isTrue);
      },
    );

    test('GIVEN a collapsed page that adds rows '
        'WHEN it is checked '
        'THEN it SHOULD NOT be overlapping', () {
      expect(overlapping(appendableEmailCount: 3), isFalse);
    });

    test('GIVEN a short collapsed page without new rows '
        'WHEN it is checked '
        'THEN it SHOULD NOT be overlapping, the folder is exhausted', () {
      expect(overlapping(serverEmailCount: 7), isFalse);
      expect(overlapping(serverEmailCount: 0), isFalse);
    });

    test(
      'GIVEN threads are not collapsed '
      'WHEN a full page without new rows is checked '
      'THEN it SHOULD NOT be overlapping, date paging is not shifted by new emails',
      () {
        expect(overlapping(collapseThreads: false), isFalse);
      },
    );
  });
}
