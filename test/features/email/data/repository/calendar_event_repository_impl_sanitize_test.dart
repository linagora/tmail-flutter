import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/data/repository/calendar_event_repository_impl.dart';
import 'package:tmail_ui_user/features/email/domain/repository/calendar_event_repository.dart';
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
  const separator =
      '-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-';
  const visioSection =
      '$separator\n'
      'Participer via Visio : https://meet.linagora.com/apw-gxwg-naw\n'
      '\n'
      'Veuillez ne pas modifier cette section.\n'
      '$separator';

  setUp(() => reset(htmlDatasource));

  Future<List<BlobCalendarEvent>> transformSingle(
    CalendarEvent event, {
    SanitizeCalendarEventDescription? sanitizeDescription,
  }) =>
      calendarEventRepository.transformCalendarEventDescription(
        [BlobCalendarEvent(blobId: blobId, calendarEventList: [event])],
        transformConfiguration,
        sanitizeDescription: sanitizeDescription,
      );

  Future<void> expectSkipped(
    String description, {
    SanitizeCalendarEventDescription? sanitizeDescription,
    required String reason,
  }) async {
    final result = await transformSingle(
      CalendarEvent(description: description),
      sanitizeDescription: sanitizeDescription,
    );
    verifyNever(htmlDatasource.transformHtmlEmailContent(any, any));
    expect(
      result.first.calendarEventList.first.description,
      isEmpty,
      reason: reason,
    );
  }

  Future<void> expectForwardedToHtml({
    required String description,
    required String forwarded,
    required String htmlResult,
    SanitizeCalendarEventDescription? sanitizeDescription,
    required String reason,
  }) async {
    when(htmlDatasource.transformHtmlEmailContent(any, any))
      .thenAnswer((_) async => htmlResult);
    final result = await transformSingle(
      CalendarEvent(description: description),
      sanitizeDescription: sanitizeDescription,
    );
    verify(htmlDatasource.transformHtmlEmailContent(forwarded, transformConfiguration))
      .called(1);
    expect(
      result.first.calendarEventList.first.description,
      htmlResult,
      reason: reason,
    );
  }

  test('should keep null description and never call htmlDataSource', () async {
    final result = await transformSingle(
      CalendarEvent(description: null, title: 'Meeting'),
    );

    verifyNever(htmlDatasource.transformHtmlEmailContent(any, any));
    expect(result.first.calendarEventList.first.description, isNull);
    expect(result.first.calendarEventList.first.title, 'Meeting');
  });

  test('should skip htmlDataSource when leftover is empty', () async {
    final skipped = <({
      String name,
      String description,
      SanitizeCalendarEventDescription? sanitizeDescription,
    })>[
      (name: 'empty description', description: '', sanitizeDescription: null),
      (name: 'whitespace-only description', description: '   ', sanitizeDescription: null),
      (name: 'visio-only description', description: visioSection, sanitizeDescription: null),
      (
        name: 'visio-only wrapped in HTML tags',
        description: '<p>$visioSection</p>',
        sanitizeDescription: null,
      ),
      (
        name: 'leftover wrappers that only hold NBSP',
        description: '<p>\u00a0$visioSection</p>',
        sanitizeDescription: null,
      ),
      (
        name: 'leftover wrappers with a long attribute',
        description: '<p style="${'x' * 140}">$visioSection</p>',
        sanitizeDescription: null,
      ),
      (
        name: 'sanitizeDescription returns blank',
        description: 'any visio block',
        sanitizeDescription: (_) => '',
      ),
    ];

    for (final example in skipped) {
      reset(htmlDatasource);
      await expectSkipped(
        example.description,
        sanitizeDescription: example.sanitizeDescription,
        reason: example.name,
      );
    }
  });

  test('should forward leftover description to htmlDataSource', () async {
    final forwarded = <({
      String name,
      String description,
      String forwarded,
      String htmlResult,
      SanitizeCalendarEventDescription? sanitizeDescription,
    })>[
      (
        name: 'default visio strip before htmlDataSource',
        description: 'Sprint planning\n\n$visioSection',
        forwarded: 'Sprint planning',
        htmlResult: '<body>Sprint planning</body>',
        sanitizeDescription: null,
      ),
      (
        name: 'sanitizeDescription output',
        description: 'Sprint planning with visio block',
        forwarded: 'Sprint planning',
        htmlResult: '<body>Sprint planning</body>',
        sanitizeDescription: (_) => 'Sprint planning',
      ),
      (
        name: 'original description when sanitizeDescription throws',
        description: 'Sprint planning with visio block',
        forwarded: 'Sprint planning with visio block',
        htmlResult: '<body>Sprint planning with visio block</body>',
        sanitizeDescription: (_) => throw StateError('strip failed'),
      ),
      (
        name: 'image-only leftover after visio strip',
        description: '<img src="x">$visioSection',
        forwarded: '<img src="x">',
        htmlResult: '<body><img src="x"></body>',
        sanitizeDescription: null,
      ),
    ];

    for (final example in forwarded) {
      reset(htmlDatasource);
      await expectForwardedToHtml(
        description: example.description,
        forwarded: example.forwarded,
        htmlResult: example.htmlResult,
        sanitizeDescription: example.sanitizeDescription,
        reason: example.name,
      );
    }
  });
}
