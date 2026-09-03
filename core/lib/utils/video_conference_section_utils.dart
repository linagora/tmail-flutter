/// Removes the video-conference section that Twake Calendar appends to event
/// descriptions, delimited by [separator]:
///
/// ```
/// -::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-
/// Join visio : https://meet.example.com/abc-defg-hij
///
/// Please do not edit this section.
/// -::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-
/// ```
///
/// The meeting link is already rendered by the invitation email body, so the
/// section is pure noise when the ICS description is displayed on its own.
/// Mirrors `removeVideoConferenceFromDescription` in twake-calendar-frontend.
class VideoConferenceSectionUtils {
  VideoConferenceSectionUtils._();

  static const String separator =
      '-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-';

  static String removeSection(String description) {
    const markerLength = separator.length;
    var cursor = 0;
    var removedPair = false;
    StringBuffer? result;

    while (true) {
      final open = description.indexOf(separator, cursor);
      if (open == -1) break;

      final close = description.indexOf(separator, open + markerLength);
      if (close == -1) break;

      result ??= StringBuffer();
      _writeKept(
        result,
        description.substring(cursor, open),
        stripLeading: removedPair,
        stripTrailing: true,
      );
      removedPair = true;
      cursor = close + markerLength;
    }

    if (result == null) return description;

    _writeKept(
      result,
      description.substring(cursor),
      stripLeading: true,
      stripTrailing: false,
    );
    return result.toString();
  }

  /// Writes [chunk] into [buffer] without the breaks that hugged a removed
  /// section, separated from what came before by exactly one newline.
  ///
  /// The separator is written whatever the dropped section looked like: a pair
  /// with no break on either side would otherwise weld the surrounding text
  /// into a single token.
  static void _writeKept(
    StringBuffer buffer,
    String chunk, {
    required bool stripLeading,
    required bool stripTrailing,
  }) {
    var kept = chunk;
    if (stripTrailing) kept = _stripTrailingBreaks(kept);
    if (stripLeading) kept = _stripLeadingBreaks(kept);
    if (kept.isEmpty) return;

    if (buffer.isNotEmpty) buffer.write('\n');
    buffer.write(kept);
  }

  static String _stripLeadingBreaks(String text) {
    var start = 0;
    while (start < text.length) {
      final length = _breakLengthStartingAt(text, start);
      if (length == 0) break;
      start += length;
    }
    return start == 0 ? text : text.substring(start);
  }

  static String _stripTrailingBreaks(String text) {
    var end = text.length;
    while (end > 0) {
      final length = _breakLengthEndingAt(text, end);
      if (length == 0) break;
      end -= length;
    }
    return end == text.length ? text : text.substring(0, end);
  }

  static int _breakLengthStartingAt(String text, int index) {
    if (index >= text.length) return 0;
    if (text.startsWith('\r\n', index)) return 2;
    if (text[index] == '\n' || text[index] == '\r') return 1;
    return _brTagLengthAt(text, index);
  }

  static int _breakLengthEndingAt(String text, int end) {
    if (end <= 0) return 0;
    if (end >= 2 && text.startsWith('\r\n', end - 2)) return 2;
    if (text[end - 1] == '\n' || text[end - 1] == '\r') return 1;
    return _brTagLengthEndingAt(text, end);
  }

  /// Length of the `<br>` tag starting at [index], or 0 when there is none.
  /// Accepts `<br>`, `<br/>` and any casing, with whitespace before the slash.
  static int _brTagLengthAt(String text, int index) {
    if (index + 3 >= text.length || text[index] != '<') return 0;
    if (!_isLetter(text.codeUnitAt(index + 1), _letterB)) return 0;
    if (!_isLetter(text.codeUnitAt(index + 2), _letterR)) return 0;

    var cursor = index + 3;
    while (cursor < text.length && _isTagWhitespace(text[cursor])) {
      cursor++;
    }
    if (cursor < text.length && text[cursor] == '/') cursor++;
    if (cursor < text.length && text[cursor] == '>') {
      return cursor - index + 1;
    }
    return 0;
  }

  /// Right-to-left mirror of [_brTagLengthAt], so both directions accept the
  /// same tags instead of a backward scan guessing at candidate lengths.
  static int _brTagLengthEndingAt(String text, int end) {
    if (text[end - 1] != '>') return 0;

    var cursor = end - 2;
    if (cursor >= 0 && text[cursor] == '/') cursor--;
    while (cursor >= 0 && _isTagWhitespace(text[cursor])) {
      cursor--;
    }
    if (cursor < 2) return 0;
    if (!_isLetter(text.codeUnitAt(cursor), _letterR)) return 0;
    if (!_isLetter(text.codeUnitAt(cursor - 1), _letterB)) return 0;
    if (text[cursor - 2] != '<') return 0;

    return end - (cursor - 2);
  }

  static const int _letterB = 0x62;
  static const int _letterR = 0x72;

  /// Case-insensitive match against a lowercase ASCII [letter].
  static bool _isLetter(int codeUnit, int letter) =>
      (codeUnit | 0x20) == letter;

  static bool _isTagWhitespace(String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';
}
