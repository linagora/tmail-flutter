import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/exclude_list_filter.dart';

/// Helper: simulate a regex [Match] at [start]..[end] within [text].
Match _fakeMatch(String text, int start, int end) {
  final regex = RegExp(RegExp.escape(text.substring(start, end)));
  return regex.allMatches(text).firstWhere((m) => m.start == start);
}

void main() {
  group('ExcludeListFilter.isValid', () {
    test('returns true when excludeList is empty', () {
      final filter = ExcludeListFilter([]);
      const text ='See the file attached.';
      final match = _fakeMatch(text, 8, 12); // "file"
      expect(filter.isValid(text, match), isTrue);
    });

    test('blocks token that exactly matches an exclude entry', () {
      final filter = ExcludeListFilter(['file-246']);
      const text ='Please find file-246 here.';
      final match = _fakeMatch(text, 12, 16); // "file"
      expect(filter.isValid(text, match), isFalse);
    });

    test('blocks token with trailing punctuation (e.g. "file-246.")', () {
      final filter = ExcludeListFilter(['file-246']);
      const text ='Check file-246.';
      final match = _fakeMatch(text, 6, 10); // "file"
      expect(filter.isValid(text, match), isFalse);
    });

    test('blocks token with leading punctuation (e.g. "(file-246")', () {
      final filter = ExcludeListFilter(['file-246']);
      const text ='See (file-246 for details.';
      final match = _fakeMatch(text, 5, 9); // "file"
      expect(filter.isValid(text, match), isFalse);
    });

    test('allows token not in the exclude list', () {
      final filter = ExcludeListFilter(['invoice-draft']);
      const text ='Please attach the file.';
      final match = _fakeMatch(text, 18, 22); // "file"
      expect(filter.isValid(text, match), isTrue);
    });

    test('matching is case-insensitive', () {
      final filter = ExcludeListFilter(['File-246']);
      const text ='See file-246 here.';
      final match = _fakeMatch(text, 4, 8); // "file"
      expect(filter.isValid(text, match), isFalse);
    });

    test('allows a standalone keyword not surrounded by exclude context', () {
      final filter = ExcludeListFilter(['file-246']);
      const text ='Please attach the file here.';
      final match = _fakeMatch(text, 18, 22); // "file"
      expect(filter.isValid(text, match), isTrue);
    });
  });
}
