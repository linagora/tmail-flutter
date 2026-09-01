/// Removes the video-conference section that Twake Calendar appends to event
/// descriptions, delimited by [VideoConferenceSectionUtils.separator]:
///
/// ```
/// -::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-
/// Join Visio : https://meet.example.com/abc-defg-hij
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

  static final String _escapedSeparator = RegExp.escape(separator);

  /// Whitespace or `<br>` tags surrounding the section, so removing it does
  /// not leave blank lines behind.
  static const String _surroundingBreaks = r'(?:\s|<br\s*/?>)*';

  static final RegExp _sectionRegex = RegExp(
    '$_surroundingBreaks$_escapedSeparator.*?$_escapedSeparator$_surroundingBreaks',
    dotAll: true,
    caseSensitive: false,
  );

  static bool containsSection(String description) =>
      description.contains(separator);

  static String removeSection(String description) {
    if (!containsSection(description)) return description;

    return description.replaceAll(_sectionRegex, '\n').trim();
  }
}
