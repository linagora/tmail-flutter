import 'package:core/utils/video_conference_section_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'redos_test_utils.dart';

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

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        description,
      );
    });

    test('SHOULD return empty string when description is empty', () {
      expect(VideoConferenceSectionUtils.removeSection(''), '');
    });

    test(
      'SHOULD return empty string when description only contains the visio section',
      () {
        expect(VideoConferenceSectionUtils.removeSection(visioSection), '');
      },
    );

    test(
      'SHOULD strip a visio section appended after the user description',
      () {
        const description = 'Sprint planning\n\n$visioSection';

        expect(
          VideoConferenceSectionUtils.removeSection(description),
          'Sprint planning',
        );
      },
    );

    test('SHOULD strip a visio section placed before the user description', () {
      const description = '$visioSection\n\nSprint planning';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Sprint planning',
      );
    });

    test(
      'SHOULD strip a visio section in the middle without leaving blank lines',
      () {
        const description = 'Before\n\n$visioSection\n\nAfter';

        expect(
          VideoConferenceSectionUtils.removeSection(description),
          'Before\nAfter',
        );
      },
    );

    test('SHOULD strip a visio section surrounded by <br> tags', () {
      const description =
          'Before<br><br>$separator<br>Join Visio : https://meet.example.com/a-b-c<br>$separator<br>After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD strip a visio section surrounded by <br /> tags', () {
      const description =
          'Before<br />$separator<br />Join Visio : https://meet.example.com/a-b-c<br />$separator<br />After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD strip a visio section surrounded by uppercase <BR> tags', () {
      const description =
          'Before<BR>$separator<BR>Join Visio : https://meet.example.com/a-b-c<BR>$separator<BR>After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD strip a visio section that uses CRLF line endings', () {
      const description =
          'Sprint planning\r\n\r\n'
          '$separator\r\n'
          'Join Visio : https://meet.example.com/a-b-c\r\n'
          '\r\n'
          'Please do not edit this section.\r\n'
          '$separator';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Sprint planning',
      );
    });

    test(
      'SHOULD leave wrapping HTML tags when the visio section is the only content inside them',
      () {
        const description = '<p>$visioSection</p>';

        expect(
          VideoConferenceSectionUtils.removeSection(description),
          '<p>\n</p>',
        );
      },
    );

    test('SHOULD preserve user-authored leading and trailing whitespace', () {
      const description = '  Sprint planning  \n\n$visioSection';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        '  Sprint planning  ',
      );
    });

    test(
      'SHOULD return a large malformed payload unchanged within the ReDoS budget',
      () {
        final description = '${'\n' * 10000}$separator';

        final result = expectFastResult(
          () => VideoConferenceSectionUtils.removeSection(description),
          reason:
              'Malformed visio markers must stay linear (ADR 0069 ReDoS budget)',
        );

        expect(result, description);
      },
    );

    test(
      'SHOULD strip a pair buried in a huge break run within the ReDoS budget',
      () {
        final description =
            'Before${'<br>' * 50000}$visioSection${'<br>' * 50000}After';

        final result = expectFastResult(
          () => VideoConferenceSectionUtils.removeSection(description),
          reason:
              'Break stripping around a removed pair must stay linear '
              '(ADR 0069 ReDoS budget)',
        );

        expect(result, 'Before\nAfter');
      },
    );

    test(
      'SHOULD reject an unterminated <br> run adjacent to a pair within the '
      'ReDoS budget',
      () {
        final description =
            'Before$visioSection<br${' ' * 100000}After';

        final result = expectFastResult(
          () => VideoConferenceSectionUtils.removeSection(description),
          reason:
              'A malformed tag must fail in one pass, not per offset '
              '(ADR 0069 ReDoS budget)',
        );

        expect(result, description.replaceFirst(visioSection, '\n'));
      },
    );

    test(
      'SHOULD return the same instance when no complete visio pair exists',
      () {
        const description = 'Header\n$separator\nBody';

        expect(
          identical(
            VideoConferenceSectionUtils.removeSection(description),
            description,
          ),
          isTrue,
        );
      },
    );

    test('SHOULD strip an empty visio pair with no interior text', () {
      const description = 'Hello$separator${separator}World';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Hello\nWorld',
      );
    });

    test(
      'SHOULD NOT splice text across a removed section into one autolinkable URL',
      () {
        const description =
            'Join here: https://meet.linagora.com'
            '$visioSection'
            '.attacker.tld/login';

        expect(
          VideoConferenceSectionUtils.removeSection(description),
          'Join here: https://meet.linagora.com\n.attacker.tld/login',
        );
      },
    );

    test(
      'SHOULD join the surrounding lines when only the text before the section '
      'ends with a line break',
      () {
        const description = 'Before\n$visioSection' 'After';

        expect(
          VideoConferenceSectionUtils.removeSection(description),
          'Before\nAfter',
        );
      },
    );

    test(
      'SHOULD join the surrounding lines when only the text before the section '
      'ends with a <br> tag',
      () {
        const description = 'Before<br>$visioSection' 'After';

        expect(
          VideoConferenceSectionUtils.removeSection(description),
          'Before\nAfter',
        );
      },
    );

    test('SHOULD strip <br> tags holding whitespace before the slash', () {
      const description =
          'Before<br  />$separator<br\t/>Join Visio : https://meet.example.com/a-b-c<br \n/>$separator<br  />After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD strip a <br> tag broken by a newline', () {
      const description = 'Before<br\n>$visioSection' 'After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD keep a non-<br> tag adjacent to the section', () {
      const description = 'Before<b>$visioSection</b>After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before<b>\n</b>After',
      );
    });

    test('SHOULD strip a visio section surrounded by mixed-case <Br> tags', () {
      const description =
          'Before<Br>$separator<bR>Join Visio : https://meet.example.com/a-b-c<br/>$separator<BR />After';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Before\nAfter',
      );
    });

    test('SHOULD keep leftover text after an unpaired third separator', () {
      const description = 'Notes\n$visioSection\nMore\n$separator\nTail';

      expect(
        VideoConferenceSectionUtils.removeSection(description),
        'Notes\nMore\n$separator\nTail',
      );
    });

    test('SHOULD strip every visio section when several are present', () {
      const description = 'A\n$visioSection\nB\n$visioSection\nC';

      expect(VideoConferenceSectionUtils.removeSection(description), 'A\nB\nC');
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
}
