import 'dart:math';

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

  static String removeSection(String description) =>
      _EventDescription(description).withoutVideoConferenceSections();
}

/// The description being cleaned, held as a whole so every step below works on
/// offsets into [text] instead of on `(text, offset)` argument pairs.
class _EventDescription {
  _EventDescription(this.text);

  final String text;

  static const String _marker = VideoConferenceSectionUtils.separator;

  /// One run of line breaks: `\r\n` / `\n` / `\r`, or `<br>` / `<br/>` in any
  /// casing. Tag-internal whitespace before the optional slash is at most 32
  /// HTML whitespace characters (space, tab, LF, FF, CR — Dart/JS `\s`). A
  /// malformed `<br` then fails in one pass instead of backtracking (ADR 0069).
  static final RegExp _breakRunPattern = RegExp(
    r'(?:\r\n|[\n\r]|<br\s{0,32}/?>)+',
    caseSensitive: false,
  );

  /// Every break run of [text], collected in the single pass both indexes below
  /// share.
  late final List<RegExpMatch> _breakRuns =
      _breakRunPattern.allMatches(text).toList();

  /// Where the break run ending at a given offset starts.
  late final Map<int, int> _runStartByEnd = {
    for (final run in _breakRuns) run.end: run.start,
  };

  /// Where the break run starting at a given offset ends.
  late final Map<int, int> _runEndByStart = {
    for (final run in _breakRuns) run.start: run.end,
  };

  String withoutVideoConferenceSections() {
    final sections = _sections(_markerOffsets());
    if (sections.isEmpty) return text;

    return _render(_keptRanges(sections));
  }

  /// Every separator occurrence, in order, searched without overlap.
  List<int> _markerOffsets() {
    final offsets = <int>[];
    var at = text.indexOf(_marker);
    while (at != -1) {
      offsets.add(at);
      at = text.indexOf(_marker, at + _marker.length);
    }
    return offsets;
  }

  /// The ranges to drop: each pair of markers grown over the break run hugging
  /// it on either side, so a removed section leaves neither a blank line nor a
  /// half-open one. A separator without a closing partner delimits nothing and
  /// stays in the text.
  List<_Range> _sections(List<int> markerOffsets) {
    final sections = <_Range>[];
    for (var pair = 0; pair + 1 < markerOffsets.length; pair += 2) {
      final open = markerOffsets[pair];
      final afterClose = markerOffsets[pair + 1] + _marker.length;
      sections.add(_Range(
        _runStartByEnd[open] ?? open,
        _runEndByStart[afterClose] ?? afterClose,
      ));
    }
    return sections;
  }

  /// The ranges left around [sections]. Two sections parted by nothing but a
  /// break run both grow over that run, hence the clamp: a kept range never
  /// starts before the section ahead of it ended.
  List<_Range> _keptRanges(List<_Range> sections) {
    final kept = <_Range>[];
    var cursor = 0;
    for (final section in sections) {
      kept.add(_Range(cursor, max(cursor, section.start)));
      cursor = section.end;
    }
    kept.add(_Range(cursor, text.length));
    return kept;
  }

  /// Renders [ranges] separated by exactly one newline, whatever the dropped
  /// sections looked like: a pair with no break on either side would otherwise
  /// weld the surrounding text into a single token.
  String _render(List<_Range> ranges) => ranges
      .map((range) => text.substring(range.start, range.end))
      .where((slice) => slice.isNotEmpty)
      .join('\n');
}

/// A `[start, end)` slice of a description.
class _Range {
  const _Range(this.start, this.end);

  final int start;
  final int end;
}
