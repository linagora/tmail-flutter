import 'package:core/utils/video_conference_section_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const separator = VideoConferenceSectionUtils.separator;
  const visioSection =
      '$separator\n'
      'Participer via Visio : https://meet.linagora.com/apw-gxwg-naw\n'
      '\n'
      'Veuillez ne pas modifier cette section.\n'
      '$separator';

  group('VideoConferenceSectionUtils.removeSection', () {
    test('SHOULD return description unchanged when it has no separator', () {
      const description = 'Agenda:\n1. Intro\n2. Demo';

      expect(VideoConferenceSectionUtils.removeSection(description), description);
    });

    test('SHOULD return empty string when description is empty', () {
      expect(VideoConferenceSectionUtils.removeSection(''), '');
    });

    test('SHOULD return empty string when description only contains the visio section', () {
      expect(VideoConferenceSectionUtils.removeSection(visioSection), '');
    });

    test('SHOULD strip a visio section appended after the user description', () {
      const description = 'Sprint planning\n\n$visioSection';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Sprint planning',
      );
    });

    test('SHOULD strip a visio section placed before the user description', () {
      const description = '$visioSection\n\nSprint planning';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Sprint planning',
      );
    });

    test('SHOULD strip a visio section in the middle without leaving blank lines', () {
      const description = 'Before\n\n$visioSection\n\nAfter';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD strip a visio section surrounded by <br> tags', () {
      const description = 'Before<br><br>$separator<br>Join Visio : https://meet.example.com/a-b-c<br>$separator<br>After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD strip every visio section when several are present', () {
      const description = 'A\n$visioSection\nB\n$visioSection\nC';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'A\nB\nC',
      );
    });

    test('SHOULD keep a lone separator that does not delimit a section', () {
      const description = 'Header\n$separator\nBody';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        description,
      );
    });

    test('SHOULD keep a legacy "Visio:" line outside of any section', () {
      const description = 'Visio: https://meet.example.com/a-b-c\nAgenda';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        description,
      );
    });
  });

  group('VideoConferenceSectionUtils.containsSection', () {
    test('SHOULD be true when the separator is present', () {
      expect(VideoConferenceSectionUtils.containsSection(visioSection), isTrue);
    });

    test('SHOULD be false when the separator is absent', () {
      expect(VideoConferenceSectionUtils.containsSection('plain text'), isFalse);
    });
  });
}
