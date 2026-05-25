import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/data/datasource/calendar_event_datasource.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/repository/calendar_event_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

import 'calendar_event_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<CalendarEventDataSource>(),
  MockSpec<HtmlDataSource>(),
])
void main() {
  final calendarEventNetworkDataSource = MockCalendarEventDataSource();
  final htmlDatasource = MockHtmlDataSource();
  final calendarEventDataSource = {
    DataSourceType.network: calendarEventNetworkDataSource};
  final calendarEventRepository = CalendarEventRepositoryImpl(
    calendarEventDataSource,
    htmlDatasource,
  );
  final accountId = AccountId(Id('123'));
  final blobId = Id('blobId');
  const language = 'en';

  group('calendar event repository test:', () {
    final calendarEventAcceptResponseresponse = CalendarEventAcceptResponse(
      accountId,
      null,
      accepted: [EventId(blobId.value)]);

    test('should return response when data source return response', () async {
      // arrange
      when(calendarEventNetworkDataSource.acceptEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventAcceptResponseresponse);

      // act
      final response = await calendarEventRepository.acceptEventInvitation(accountId, {blobId}, language);
      
      // assert
      expect(response, calendarEventAcceptResponseresponse);
    });

    test('should throw exception when data source throw exception', () {
      // arrange
      when(calendarEventNetworkDataSource.acceptEventInvitation(any, any, any))
        .thenThrow(NotAcceptableCalendarEventException());
      
      // assert
      expect(
        () => calendarEventRepository.acceptEventInvitation(accountId, {blobId}, language),
        throwsA(isA<NotAcceptableCalendarEventException>()));
    });
  });

  group('calendar event maybe repository test:', () {
    final calendarEventMaybeResponse = CalendarEventMaybeResponse(
      accountId,
      null,
      maybe: [EventId(blobId.value)]);

    test('should return response when data source return response', () async {
      // arrange
      when(calendarEventNetworkDataSource.maybeEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventMaybeResponse);

      // act
      final response = await calendarEventRepository.maybeEventInvitation(accountId, {blobId}, language);
      
      // assert
      expect(response, calendarEventMaybeResponse);
    });

    test('should throw exception when data source throw exception', () {
      // arrange
      when(calendarEventNetworkDataSource.maybeEventInvitation(any, any, any))
        .thenThrow(NotMaybeableCalendarEventException());
      
      // assert
      expect(
        () => calendarEventRepository.maybeEventInvitation(accountId, {blobId}, language),
        throwsA(isA<NotMaybeableCalendarEventException>()));
    });
  });

  group('calendar event reject repository test:', () {
    final calendarEventRejectResponseresponse = CalendarEventRejectResponse(
      accountId,
      null,
      rejected: [EventId(blobId.value)]);

    test('should return response when data source return response', () async {
      // arrange
      when(calendarEventNetworkDataSource.rejectEventInvitation(any, any, any))
        .thenAnswer((_) async => calendarEventRejectResponseresponse);

      // act
      final response = await calendarEventRepository.rejectEventInvitation(accountId, {blobId}, language);
      
      // assert
      expect(response, calendarEventRejectResponseresponse);
    });

    test('should throw exception when data source throw exception', () {
      // arrange
      when(calendarEventNetworkDataSource.rejectEventInvitation(any, any, any))
        .thenThrow(NotRejectableCalendarEventException());
      
      // assert
      expect(
        () => calendarEventRepository.rejectEventInvitation(accountId, {blobId}, language),
        throwsA(isA<NotRejectableCalendarEventException>()));
    });
  });

  group('transformCalendarEventDescription:', () {
    final transformConfiguration = TransformConfiguration.forCalendarEvent();

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

    group('_transformCalendarEventDescription — description skipping:', () {
      test('should keep null description and never call htmlDataSource', () async {
        // act
        final result = await transformSingle(CalendarEvent(description: null, title: 'Meeting'));

        // assert
        verifyNever(htmlDatasource.transformHtmlEmailContent(any, any));
        expect(result.first.calendarEventList.first.description, isNull);
        expect(result.first.calendarEventList.first.title, 'Meeting');
      });

      test('should keep empty description and never call htmlDataSource', () async {
        // act
        final result = await transformSingle(CalendarEvent(description: ''));

        // assert
        verifyNever(htmlDatasource.transformHtmlEmailContent(any, any));
        expect(result.first.calendarEventList.first.description, isEmpty);
      });

      test('should keep whitespace-only description and never call htmlDataSource', () async {
        // act
        final result = await transformSingle(CalendarEvent(description: '   '));

        // assert
        verifyNever(htmlDatasource.transformHtmlEmailContent(any, any));
        expect(result.first.calendarEventList.first.description, '   ');
      });
    });

    group('_transformCalendarEventDescription — description transformation:', () {
      test('should call htmlDataSource with the raw description', () async {
        // arrange
        const rawDescription = 'Join the meeting at https://meet.example.com';
        when(htmlDatasource.transformHtmlEmailContent(any, any))
          .thenAnswer((_) async => '<body>transformed</body>');

        // act
        await transformSingle(CalendarEvent(description: rawDescription));

        // assert
        verify(htmlDatasource.transformHtmlEmailContent(rawDescription, transformConfiguration)).called(1);
      });

      test('should replace description with the result returned by htmlDataSource', () async {
        // arrange
        const transformed = '<body><p>Team standup</p></body>';
        when(htmlDatasource.transformHtmlEmailContent(any, any))
          .thenAnswer((_) async => transformed);

        // act
        final result = await transformSingle(CalendarEvent(description: 'Team standup'));

        // assert
        expect(result.first.calendarEventList.first.description, transformed);
      });

      test('should preserve non-description CalendarEvent fields after transformation', () async {
        // arrange
        when(htmlDatasource.transformHtmlEmailContent(any, any))
          .thenAnswer((_) async => '<body>Quarterly review</body>');

        // act
        final result = await transformSingle(CalendarEvent(
          description: 'Quarterly review',
          title: 'Q4 Review',
          location: 'Conference Room A',
        ));

        // assert
        final resultEvent = result.first.calendarEventList.first;
        expect(resultEvent.title, 'Q4 Review');
        expect(resultEvent.location, 'Conference Room A');
      });
    });

    group('_transformCalendarEventDescription — XSS and nested HTML descriptions:', () {
      // Sanitization correctness is covered in calendar_event_description_transform_test.dart.

      test('should delegate <script> injection to htmlDataSource and store sanitized result', () async {
        await expectDelegated(
          raw: 'Notes: <script>document.cookie</script>',
          sanitized: '<body>Notes: </body>',
        );
      });

      test('should delegate event-handler injection to htmlDataSource and store sanitized result', () async {
        await expectDelegated(
          raw: '<img src="x" onerror="alert(1)"> Team photo',
          sanitized: '<body>Team photo</body>',
        );
      });

      test('should delegate javascript: href to htmlDataSource and store sanitized result', () async {
        await expectDelegated(
          raw: '<a href="javascript:alert(1)">click here</a>',
          sanitized: '<body><a href="">click here</a></body>',
        );
      });

      test('should delegate deeply nested HTML to htmlDataSource and store result', () async {
        await expectDelegated(
          raw: '<div><p><span><b>Important:</b> quarterly budget</span></p></div>',
          sanitized: '<body><div><p><span><b>Important:</b> quarterly budget</span></p></div></body>',
        );
      });

      test('should delegate mixed XSS + plain text to htmlDataSource and store sanitized result', () async {
        await expectDelegated(
          raw: 'Agenda:\n1. Budget <script>stealData()</script>\n2. Planning <img src=x onerror="xss()">',
          sanitized: '<body>Agenda:<br>1. Budget <br>2. Planning </body>',
        );
      });

      test('should delegate description with HTML entities to htmlDataSource and store result', () async {
        await expectDelegated(
          raw: 'Status: a &lt; b &amp;&amp; b &gt; 0',
          sanitized: '<body>Status: a &lt; b &amp;&amp; b &gt; 0</body>',
        );
      });
    });

    group('_transformCalendarEventDescription — ADR-0089 backslash-hex regression:', () {
      // ADR-0089 documents a bug in dart-neats/sanitize_html: the regex
      // RegExp(r'\\[0-9a-f]{2}') matches any single \XX pair (e.g. \DA in
      // \Sabre\DAV), stripping the entire text node and producing blank output.
      // Non-blank output for these inputs is verified in calendar_event_description_transform_test.dart.

      test('should forward PHP namespace path description to htmlDataSource and store result', () async {
        // \Corp\DAV\Server\Exception\Forbidden — \DA triggers unicodeEscapeReg
        await expectDelegated(
          raw: r'Meeting exception: \Corp\DAV\Server\Exception\Forbidden — contact IT',
          sanitized: r'<body>Meeting exception: \Corp\DAV\Server\Exception\Forbidden — contact IT</body>',
        );
      });

      test('should forward Windows file path description to htmlDataSource and store result', () async {
        // C:\Users\Admin\Documents — \Us, \Ad, \Do each match \XX
        await expectDelegated(
          raw: r'Attachment saved at: C:\Users\Admin\Documents\invite.pdf',
          sanitized: r'<body>Attachment saved at: C:\Users\Admin\Documents\invite.pdf</body>',
        );
      });

      test('should forward Go package path description to htmlDataSource and store result', () async {
        // \github.com\org\repo\pkg\handler\main.go — multiple \XX pairs
        await expectDelegated(
          raw: r'Build error in \github.com\org\repo\pkg\handler\main.go line 42',
          sanitized: r'<body>Build error in \github.com\org\repo\pkg\handler\main.go line 42</body>',
        );
      });

      test('should forward mixed backslash-hex path + URL + newline description and store result', () async {
        // Combines the three ADR-0089 trigger scenarios in one description.
        await expectDelegated(
          raw: r'Error \App\DB\Exception\AuthFailed' '\n'
              r'See https://jira.example.com/ISSUE-99',
          sanitized: r'<body>Error \App\DB\Exception\AuthFailed<br>'
              '<a href="https://jira.example.com/ISSUE-99">https://jira.example.com/ISSUE-99</a></body>',
        );
      });
    });

    group('transformCalendarEventDescription — list handling:', () {
      test('should return empty list when input is empty', () async {
        // act
        final result = await calendarEventRepository.transformCalendarEventDescription(
          [],
          transformConfiguration,
        );

        // assert
        verifyNever(htmlDatasource.transformHtmlEmailContent(any, any));
        expect(result, isEmpty);
      });

      test('should process all CalendarEvents within a single BlobCalendarEvent', () async {
        // arrange
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

        // act
        final result = await calendarEventRepository.transformCalendarEventDescription(
          [blob],
          transformConfiguration,
        );

        // assert — only the two non-null descriptions trigger a call
        verify(htmlDatasource.transformHtmlEmailContent(any, any)).called(2);
        expect(result.first.calendarEventList.length, 3);
        expect(result.first.calendarEventList[2].description, isNull);
      });

      test('should process all BlobCalendarEvents in the list', () async {
        // arrange
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

        // act
        final result = await calendarEventRepository.transformCalendarEventDescription(
          [blob1, blob2],
          transformConfiguration,
        );

        // assert
        expect(result.length, 2);
        verify(htmlDatasource.transformHtmlEmailContent(any, any)).called(2);
      });

      test('should preserve BlobCalendarEvent metadata fields', () async {
        // arrange
        final blob = BlobCalendarEvent(
          blobId: blobId,
          calendarEventList: [CalendarEvent(description: 'Some description')],
          isFree: false,
          attendanceStatus: AttendanceStatus.accepted,
        );

        when(htmlDatasource.transformHtmlEmailContent(any, any))
          .thenAnswer((_) async => '<body>Some description</body>');

        // act
        final result = await calendarEventRepository.transformCalendarEventDescription(
          [blob],
          transformConfiguration,
        );

        // assert
        expect(result.first.blobId, blobId);
        expect(result.first.isFree, false);
        expect(result.first.attendanceStatus, AttendanceStatus.accepted);
      });
    });
  });
}