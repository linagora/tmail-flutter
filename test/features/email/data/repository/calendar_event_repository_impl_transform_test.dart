import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/data/repository/calendar_event_repository_impl.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

import 'calendar_event_repository_impl_test.mocks.dart';

void main() {
  final htmlDatasource = MockHtmlDataSource();
  final calendarEventRepository = CalendarEventRepositoryImpl(
    {DataSourceType.network: MockCalendarEventDataSource()},
    htmlDatasource,
  );
  final blobId = Id('blobId');
  final transformConfiguration = TransformConfiguration.forCalendarEvent();
  const visioSection =
      '-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-\n'
      'Participer via Visio : https://meet.linagora.com/apw-gxwg-naw\n'
      '\n'
      'Veuillez ne pas modifier cette section.\n'
      '-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-';

  setUp(() => reset(htmlDatasource));

  Future<List<BlobCalendarEvent>> transformSingle(CalendarEvent event) =>
      calendarEventRepository.transformCalendarEventDescription(
        [BlobCalendarEvent(blobId: blobId, calendarEventList: [event])],
        transformConfiguration,
      );

  Future<void> expectDelegated({
    required String raw,
    required String sanitized,
  }) async {
    when(htmlDatasource.transformHtmlEmailContent(any, any))
      .thenAnswer((_) async => sanitized);
    final result = await transformSingle(CalendarEvent(description: raw));
    verify(htmlDatasource.transformHtmlEmailContent(raw, transformConfiguration)).called(1);
    expect(result.first.calendarEventList.first.description, sanitized);
  }

  group('html transformation:', () {
    test('should call htmlDataSource with the raw description', () async {
      const rawDescription = 'Join the meeting at https://meet.example.com';
      when(htmlDatasource.transformHtmlEmailContent(any, any))
        .thenAnswer((_) async => '<body>transformed</body>');

      await transformSingle(CalendarEvent(description: rawDescription));

      verify(htmlDatasource.transformHtmlEmailContent(rawDescription, transformConfiguration)).called(1);
    });

    test('should replace description with the result returned by htmlDataSource', () async {
      const transformed = '<body><p>Team standup</p></body>';
      when(htmlDatasource.transformHtmlEmailContent(any, any))
        .thenAnswer((_) async => transformed);

      final result = await transformSingle(CalendarEvent(description: 'Team standup'));

      expect(result.first.calendarEventList.first.description, transformed);
    });

    test('should preserve non-description CalendarEvent fields after transformation', () async {
      when(htmlDatasource.transformHtmlEmailContent(any, any))
        .thenAnswer((_) async => '<body>Quarterly review</body>');

      final result = await transformSingle(CalendarEvent(
        description: 'Quarterly review',
        title: 'Q4 Review',
        location: 'Conference Room A',
      ));

      final resultEvent = result.first.calendarEventList.first;
      expect(resultEvent.title, 'Q4 Review');
      expect(resultEvent.location, 'Conference Room A');
    });

    test('should delegate XSS payload to htmlDataSource and store sanitized result', () async {
      await expectDelegated(
        raw: 'Notes: <script>document.cookie</script>',
        sanitized: '<body>Notes: </body>',
      );
    });

    test('should forward ADR-0089 backslash-hex description to htmlDataSource', () async {
      await expectDelegated(
        raw: r'Error \App\DB\Exception\AuthFailed' '\n'
            r'See https://jira.example.com/ISSUE-99',
        sanitized: r'<body>Error \App\DB\Exception\AuthFailed<br>'
            '<a href="https://jira.example.com/ISSUE-99">https://jira.example.com/ISSUE-99</a></body>',
      );
    });
  });

  group('list handling:', () {
    test('should return empty list when input is empty', () async {
      final result = await calendarEventRepository.transformCalendarEventDescription(
        [],
        transformConfiguration,
      );

      verifyNever(htmlDatasource.transformHtmlEmailContent(any, any));
      expect(result, isEmpty);
    });

    test('should sanitize each CalendarEvent independently', () async {
      when(htmlDatasource.transformHtmlEmailContent(any, any))
        .thenAnswer((invocation) async {
          final raw = invocation.positionalArguments.first as String;
          return '<body>$raw</body>';
        });

      final blob = BlobCalendarEvent(
        blobId: blobId,
        calendarEventList: [
          CalendarEvent(description: 'keep me'),
          CalendarEvent(description: visioSection),
          CalendarEvent(description: null),
        ],
      );

      final result = await calendarEventRepository.transformCalendarEventDescription(
        [blob],
        transformConfiguration,
      );

      verify(htmlDatasource.transformHtmlEmailContent('keep me', transformConfiguration)).called(1);
      verifyNever(htmlDatasource.transformHtmlEmailContent(visioSection, transformConfiguration));
      expect(result.first.calendarEventList[0].description, '<body>keep me</body>');
      expect(result.first.calendarEventList[1].description, isEmpty);
      expect(result.first.calendarEventList[2].description, isNull);
    });

    test('should process all CalendarEvents within a single BlobCalendarEvent', () async {
      const transformed = '<body>transformed</body>';
      final blob = BlobCalendarEvent(
        blobId: blobId,
        calendarEventList: [
          CalendarEvent(description: 'Event A'),
          CalendarEvent(description: 'Event B'),
          CalendarEvent(description: null),
        ],
      );

      when(htmlDatasource.transformHtmlEmailContent(any, any))
        .thenAnswer((_) async => transformed);

      final result = await calendarEventRepository.transformCalendarEventDescription(
        [blob],
        transformConfiguration,
      );

      verify(htmlDatasource.transformHtmlEmailContent(any, any)).called(2);
      expect(result.first.calendarEventList.length, 3);
      expect(result.first.calendarEventList[2].description, isNull);
    });

    test('should process all BlobCalendarEvents in the list', () async {
      const transformed = '<body>transformed</body>';
      final blob1 = BlobCalendarEvent(
        blobId: Id('blob1'),
        calendarEventList: [CalendarEvent(description: 'Description 1')],
      );
      final blob2 = BlobCalendarEvent(
        blobId: Id('blob2'),
        calendarEventList: [CalendarEvent(description: 'Description 2')],
      );

      when(htmlDatasource.transformHtmlEmailContent(any, any))
        .thenAnswer((_) async => transformed);

      final result = await calendarEventRepository.transformCalendarEventDescription(
        [blob1, blob2],
        transformConfiguration,
      );

      expect(result.length, 2);
      verify(htmlDatasource.transformHtmlEmailContent(any, any)).called(2);
    });

    test('should preserve BlobCalendarEvent metadata fields', () async {
      final blob = BlobCalendarEvent(
        blobId: blobId,
        calendarEventList: [CalendarEvent(description: 'Some description')],
        isFree: false,
        attendanceStatus: AttendanceStatus.accepted,
      );

      when(htmlDatasource.transformHtmlEmailContent(any, any))
        .thenAnswer((_) async => '<body>Some description</body>');

      final result = await calendarEventRepository.transformCalendarEventDescription(
        [blob],
        transformConfiguration,
      );

      expect(result.first.blobId, blobId);
      expect(result.first.isFree, false);
      expect(result.first.attendanceStatus, AttendanceStatus.accepted);
    });
  });
}
