import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_mail_to.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_name.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee_participation_status.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_extension_fields.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/mail_address.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_actions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_view_state.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/calendar_event/calendar_event_card_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

import '../../../../../fixtures/widget_fixtures.dart';

void main() {
  _registerEventDetailTests();
  _registerActivityTests();
  _registerRenderingTests();
  _registerConferenceTests();
  _registerResponseTests();
  _registerCalendarActionTests();
}

void _registerActivityTests() {
  testWidgets(
    'SHOULD show the maybe banner colour WHEN an attendee replies tentative',
    _showMaybeBannerForTentativeReply,
  );
}

void _registerEventDetailTests() {
  testWidgets(
    'SHOULD show the warning WHEN the reader is not invited',
    _showWarningForUninvitedReader,
  );
  testWidgets(
    'SHOULD show the conflict indicator WHEN the reader is busy',
    _showConflictIndicatorForBusyReader,
  );
  testWidgets(
    'SHOULD show only the first participant before expansion without organizer',
    _expandAndCollapseLongAttendeeList,
  );
  testWidgets(
    'SHOULD show only the organizer before expanding participants',
    _showOnlyOrganizerBeforeExpandingParticipants,
  );
  testWidgets(
    'SHOULD reset the attendee list WHEN the event changes',
    _resetAttendeeListForNewEvent,
  );
}

void _registerRenderingTests() {
  testWidgets(
    'SHOULD keep the response pill height on a desktop density',
    _keepPillHeightOnDesktopDensity,
  );
  testWidgets(
    'SHOULD show the day and the time as separate runs',
    _showDayAndTimeAsSeparateRuns,
  );
  testWidgets(
    'SHOULD stack the card and step its type up at phone width',
    _useCompactArrangementAtPhoneWidth,
  );
  testWidgets(
    'SHOULD keep the wide arrangement at desktop width',
    _useRegularArrangementAtDesktopWidth,
  );
  testWidgets(
    'SHOULD keep regular layout at phone width WHEN explicitly selected',
    _keepRegularLayoutAtPhoneWidth,
  );
  testWidgets(
    'SHOULD keep compact layout at desktop width WHEN explicitly selected',
    _keepCompactLayoutAtDesktopWidth,
  );
  for (final layout in LinagoraEventCardLayout.values) {
    testWidgets(
      'SHOULD render $layout under unbounded horizontal constraints',
      (tester) => _renderUnderUnboundedHorizontalConstraints(tester, layout),
    );
  }
}

void _registerConferenceTests() {
  testWidgets(
    'SHOULD forward the localised copy label and callback',
    _forwardLocalisedCopyAction,
  );
}

void _registerResponseTests() {
  for (final response in _successfulResponses) {
    testWidgets(
      'SHOULD disable ${response.actionType.name} after a successful reply',
      (tester) => _disableSuccessfulResponse(tester, response),
    );
  }
  testWidgets(
    'SHOULD restore response actions after a failed reply',
    _restoreResponsesAfterFailedReply,
  );
  testWidgets(
    'SHOULD preserve the previous response after a failed reply',
    _preservePreviousResponseAfterFailedReply,
  );
}

void _registerCalendarActionTests() {
  testWidgets(
    'SHOULD open the calendar event WHEN localhost ends with events and two slashes',
    _openCalendarEventForInvitedReader,
  );
  testWidgets(
    'SHOULD hide the calendar action WHEN the reader is not invited',
    _hideCalendarActionForUninvitedReader,
  );
  testWidgets(
    'SHOULD hide the calendar action WHEN the calendar URL is invalid',
    _hideCalendarActionForInvalidUrl,
  );
  testWidgets(
    'SHOULD hide the calendar action WHEN the event UID is missing',
    _hideCalendarActionWithoutEventUid,
  );
  testWidgets(
    'SHOULD hide the calendar action WHEN opening links is unsupported',
    _hideCalendarActionWithoutOpenLink,
  );
}

Future<void> _showWarningForUninvitedReader(WidgetTester tester) async {
  await tester.pumpWidget(_testableCard(
    event: CalendarEvent(
      organizer: CalendarOrganizer(
        mailto: MailAddress('organizer@example.invalid'),
      ),
      participants: [_attendee('Guest', 'guest@example.invalid')],
    ),
  ));
  await tester.pumpAndSettle();

  expect(
    find.text(
      AppLocalizations()
          .youAreNotInvitedToThisEventPleaseContactTheOrganizer,
    ),
    findsOneWidget,
  );
}

Future<void> _openCalendarEventForInvitedReader(WidgetTester tester) async {
  final openedLinks = <String>[];
  await tester.pumpWidget(_testableCard(
    event: _invitation(eventId: EventId('event/42')),
    calendarUrl: 'localhost:3000/events//',
    actions: CalendarEventCardActions(
      onReply: (_) {},
      onMailToAttendees: () {},
      onOpenLink: openedLinks.add,
    ),
  ));
  await tester.pumpAndSettle();

  final calendarAction = find.text(AppLocalizations().seeInYourCalendar);
  expect(calendarAction, findsOneWidget);
  final calendarButton = tester.widget<LinagoraButton>(
    find.widgetWithText(
      LinagoraButton,
      AppLocalizations().seeInYourCalendar,
    ),
  );
  expect(calendarButton.iconWidget, isA<SvgPicture>());

  await tester.tap(calendarAction);
  await tester.pump();

  expect(
    openedLinks,
    ['http://localhost:3000/events/event%2F42'],
  );
}

Future<void> _hideCalendarActionForUninvitedReader(
  WidgetTester tester,
) async {
  await tester.pumpWidget(_testableCard(
    event: CalendarEvent(
      eventId: EventId('event-42'),
      organizer: CalendarOrganizer(
        mailto: MailAddress('organizer@example.invalid'),
      ),
      participants: [_attendee('Guest', 'guest@example.invalid')],
    ),
    calendarUrl: 'https://calendar.example.invalid',
  ));
  await tester.pumpAndSettle();

  expect(find.text(AppLocalizations().seeInYourCalendar), findsNothing);
}

Future<void> _hideCalendarActionForInvalidUrl(WidgetTester tester) async {
  await tester.pumpWidget(_testableCard(
    event: _invitation(eventId: EventId('event-42')),
    calendarUrl: 'javascript:alert(1)',
  ));
  await tester.pumpAndSettle();

  expect(find.text(AppLocalizations().seeInYourCalendar), findsNothing);
}

Future<void> _hideCalendarActionWithoutEventUid(WidgetTester tester) async {
  await tester.pumpWidget(_testableCard(
    event: _invitation(),
    calendarUrl: 'https://calendar.example.invalid',
  ));
  await tester.pumpAndSettle();

  expect(find.text(AppLocalizations().seeInYourCalendar), findsNothing);
}

Future<void> _hideCalendarActionWithoutOpenLink(WidgetTester tester) async {
  await tester.pumpWidget(_testableCard(
    event: _invitation(eventId: EventId('event-42')),
    calendarUrl: 'https://calendar.example.invalid',
    actions: CalendarEventCardActions(
      onReply: (_) {},
      onMailToAttendees: () {},
    ),
  ));
  await tester.pumpAndSettle();

  expect(find.text(AppLocalizations().seeInYourCalendar), findsNothing);
}

Future<void> _showConflictIndicatorForBusyReader(WidgetTester tester) async {
  await tester.pumpWidget(_testableCard(
    event: CalendarEvent(
      startUtcDate: UTCDate(DateTime.utc(2026, 6, 16, 10)),
      endUtcDate: UTCDate(DateTime.utc(2026, 6, 16, 11)),
    ),
    viewState: _viewState(hasScheduleConflict: true),
  ));
  await tester.pumpAndSettle();

  expect(find.byType(LinagoraEventConflictIndicator), findsOneWidget);
  expect(
    find.byWidgetPredicate(
      (widget) => widget is Tooltip &&
          widget.message ==
              AppLocalizations().youHaveAnotherEventAtThatSameTime,
    ),
    findsOneWidget,
  );
}

Future<void> _showMaybeBannerForTentativeReply(WidgetTester tester) async {
  const attendeeAddress = 'attendee@example.invalid';
  await tester.pumpWidget(_testableCard(
    event: CalendarEvent(
      method: EventMethod.reply,
      participants: [
        _attendee(
          'Attendee',
          attendeeAddress,
          participationStatus: 'TENTATIVE',
        ),
        _attendee('Reader', 'reader@example.invalid'),
      ],
    ),
    viewState: _viewState(
      listEmailAddressSender: const [attendeeAddress],
    ),
  ));
  await tester.pumpAndSettle();

  final badge = find.byType(EventActivityBadge);
  expect(
    tester.widget<EventActivityBadge>(badge).state,
    EventActivityBadgeState.maybe,
  );
  final badgeContainer = tester.widget<Container>(
    find.descendant(
      of: badge,
      matching: find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      ),
    ),
  );
  expect(
    (badgeContainer.decoration! as BoxDecoration).color,
    EventActivityBadge.warningBackground,
  );
}

Future<void> _expandAndCollapseLongAttendeeList(WidgetTester tester) async {
  final attendees = [
    for (var index = 0; index < 7; index++)
      _attendee('Attendee $index', 'attendee$index@example.invalid'),
  ];

  await tester.pumpWidget(_testableCard(
    event: CalendarEvent(participants: attendees),
  ));
  await tester.pumpAndSettle();

  expect({
    'firstParticipantCount': find.text('Attendee 0').evaluate().length,
    'secondParticipantCount': find.text('Attendee 1').evaluate().length,
    'expandActionCount':
        find.text(AppLocalizations().seeAllAttendees).evaluate().length,
  }, {
    'firstParticipantCount': 1,
    'secondParticipantCount': 0,
    'expandActionCount': 1,
  });

  await tester.tap(find.text(AppLocalizations().seeAllAttendees));
  await tester.pumpAndSettle();

  expect(find.text('Attendee 6'), findsOneWidget);

  await tester.tap(find.text(AppLocalizations().hide));
  await tester.pumpAndSettle();

  expect({
    'firstParticipantCount': find.text('Attendee 0').evaluate().length,
    'secondParticipantCount': find.text('Attendee 1').evaluate().length,
  }, {
    'firstParticipantCount': 1,
    'secondParticipantCount': 0,
  });
}

Future<void> _showOnlyOrganizerBeforeExpandingParticipants(
  WidgetTester tester,
) async {
  await tester.pumpWidget(_testableCard(
    event: CalendarEvent(
      organizer: CalendarOrganizer(
        name: 'Organizer Person',
        mailto: MailAddress('organizer@example.invalid'),
      ),
      participants: [
        _attendee('First Participant', 'first@example.invalid'),
        _attendee('Second Participant', 'second@example.invalid'),
      ],
    ),
  ));
  await tester.pumpAndSettle();

  expect({
    'organizerCount': find.text('Organizer Person').evaluate().length,
    'participantCount': find.text('First Participant').evaluate().length,
    'expandActionCount':
        find.text(AppLocalizations().seeAllAttendees).evaluate().length,
  }, {
    'organizerCount': 1,
    'participantCount': 0,
    'expandActionCount': 1,
  });

  await tester.tap(find.text(AppLocalizations().seeAllAttendees));
  await tester.pumpAndSettle();

  expect(find.text('First Participant'), findsOneWidget);
  expect(find.text('Second Participant'), findsOneWidget);

  await tester.tap(find.text(AppLocalizations().hide));
  await tester.pumpAndSettle();

  expect(find.text('First Participant'), findsNothing);
}

Future<void> _resetAttendeeListForNewEvent(WidgetTester tester) async {
  late StateSetter updateCard;
  var event = CalendarEvent(participants: _attendees('First'));

  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: StatefulBuilder(
      builder: (context, setState) {
        updateCard = setState;
        return _card(
          event: event,
        );
      },
    ),
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.text(AppLocalizations().seeAllAttendees));
  await tester.pumpAndSettle();
  expect(find.text('First 6'), findsOneWidget);

  updateCard(() => event = CalendarEvent(participants: _attendees('Second')));
  await tester.pumpAndSettle();

  expect(find.text('Second 5'), findsNothing);
  expect(find.text(AppLocalizations().seeAllAttendees), findsOneWidget);
}

/// Desktop and web resolve the ambient density to [VisualDensity.compact],
/// which shortens every button that does not pin its own height.
Future<void> _keepPillHeightOnDesktopDensity(WidgetTester tester) async {
  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: Theme(
      data: ThemeData(visualDensity: VisualDensity.compact),
      child: _card(
        event: _invitation(),
      ),
    ),
  ));
  await tester.pumpAndSettle();

  expect(
    tester
        .getSize(
          find.widgetWithText(LinagoraButton, AppLocalizations().yes),
        )
        .height,
    40,
  );
}

Future<void> _showDayAndTimeAsSeparateRuns(WidgetTester tester) async {
  await tester.pumpWidget(_testableCard(
    event: CalendarEvent(
      startUtcDate: UTCDate(DateTime(2026, 6, 16, 10)),
      endUtcDate: UTCDate(DateTime(2026, 6, 16, 11)),
    ),
  ));
  await tester.pumpAndSettle();

  final day = find.text('Tuesday, June 16, 2026');
  final time = find.text('10:00 AM - 11:00 AM');

  expect(day, findsOneWidget);
  expect(time, findsOneWidget);
  expect(
    tester.widget<Text>(day).style?.fontWeight,
    FontWeight.w600,
    reason: 'the day carries the weight a reader scans for',
  );
  expect(tester.widget<Text>(time).style?.fontWeight, FontWeight.w400);
}

Future<void> _disableSuccessfulResponse(
  WidgetTester tester,
  _SuccessfulResponse response,
) async {
  late StateSetter updateCard;
  AttendanceStatus? attendanceStatus;
  final replies = <EventActionType>[];

  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: StatefulBuilder(
      builder: (context, setState) {
        updateCard = setState;
        return _card(
          event: _invitation(),
          viewState: _viewState(attendanceStatus: attendanceStatus),
          actions: CalendarEventCardActions(
            onReply: replies.add,
            onMailToAttendees: () {},
          ),
        );
      },
    ),
  ));
  await tester.pumpAndSettle();

  final label = response.actionType.getLabelButton(AppLocalizations());
  await tester.tap(find.text(label));
  await tester.pump();
  expect(replies, [response.actionType]);

  updateCard(() => attendanceStatus = response.attendanceStatus);
  await tester.pump();

  expect(_responseButton(tester, label).onPressed, isNull);
  _expectDisabledPalette(tester, label);

  await tester.tap(find.text(label));
  await tester.pump();
  expect(replies, [response.actionType]);
}

void _expectDisabledPalette(WidgetTester tester, String label) {
  final materialButton = tester.widget<FilledButton>(
    find.ancestor(
      of: find.text(label),
      matching: find.byType(FilledButton),
    ),
  );
  const disabledStates = {WidgetState.disabled};
  expect(
    materialButton.style?.backgroundColor?.resolve(disabledStates),
    LinagoraButton.disabledContainerColor,
  );
  expect(
    materialButton.style?.foregroundColor?.resolve(disabledStates),
    LinagoraButton.disabledContentColor,
  );
}

Future<void> _restoreResponsesAfterFailedReply(WidgetTester tester) async {
  late StateSetter updateCard;
  var replying = true;

  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: StatefulBuilder(
      builder: (context, setState) {
        updateCard = setState;
        return _card(
          event: _invitation(),
          viewState: _viewState(replying: replying),
        );
      },
    ),
  ));
  await tester.pumpAndSettle();

  _expectResponsesEnabled(tester, enabled: false);

  updateCard(() => replying = false);
  await tester.pump();

  _expectResponsesEnabled(tester, enabled: true);
}

Future<void> _preservePreviousResponseAfterFailedReply(
  WidgetTester tester,
) async {
  late StateSetter updateCard;
  var replying = true;

  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: StatefulBuilder(
      builder: (context, setState) {
        updateCard = setState;
        return _card(
          event: _invitation(),
          viewState: _viewState(
            attendanceStatus: AttendanceStatus.accepted,
            replying: replying,
          ),
        );
      },
    ),
  ));
  await tester.pumpAndSettle();

  _expectResponsesEnabled(tester, enabled: false);

  updateCard(() => replying = false);
  await tester.pump();

  expect(
    _responseButton(tester, AppLocalizations().yes).onPressed,
    isNull,
  );
  expect(
    _responseButton(tester, AppLocalizations().maybe).onPressed,
    isNotNull,
  );
  expect(
    _responseButton(tester, AppLocalizations().no).onPressed,
    isNotNull,
  );
}

void _expectResponsesEnabled(
  WidgetTester tester, {
  required bool enabled,
}) {
  for (final response in _successfulResponses) {
    final label = response.actionType.getLabelButton(AppLocalizations());
    expect(
      _responseButton(tester, label).onPressed,
      enabled ? isNotNull : isNull,
    );
  }
}

LinagoraButton _responseButton(WidgetTester tester, String label) {
  return tester.widget<LinagoraButton>(
    find.widgetWithText(LinagoraButton, label),
  );
}

/// The phone arrangement: no date marker, labels above their values, and the
/// response block centred.
Future<void> _useCompactArrangementAtPhoneWidth(WidgetTester tester) async {
  await _pumpAtWidth(tester, 390);

  final l = AppLocalizations();
  final card = tester.getRect(find.byType(LinagoraEventCard));

  expect(find.byType(LinagoraEventDateIcon), findsNothing);

  final label = tester.getRect(find.text(l.when));
  final value = tester.getRect(find.text('Tuesday, June 16, 2026'));
  expect(value.top, greaterThan(label.bottom - 1));
  expect(label.left, value.left);

  expect(tester.getRect(find.text(l.attending)).center.dx, card.center.dx);

  expect(_fontSizeOf(tester, l.when), 14);
  expect(_fontSizeOf(tester, 'Tuesday, June 16, 2026'), 16);
  expect(_fontSizeOf(tester, 'Automated DS Flutter'), 22);
}

Future<void> _useRegularArrangementAtDesktopWidth(WidgetTester tester) async {
  await _pumpAtWidth(tester, 1150);

  final l = AppLocalizations();
  final label = tester.getRect(find.text(l.when));
  final value = tester.getRect(find.text('Tuesday, June 16, 2026'));

  expect(find.byType(LinagoraEventDateIcon), findsOneWidget);
  expect(
    label.center.dy,
    closeTo(value.center.dy, 0.5),
    reason: 'the label is vertically centred on the first value line',
  );
  expect(value.left, greaterThan(label.right));

  expect(_fontSizeOf(tester, l.when), 12);
  expect(_fontSizeOf(tester, 'Tuesday, June 16, 2026'), 14);
}

Future<void> _keepRegularLayoutAtPhoneWidth(WidgetTester tester) async {
  await _pumpAtWidth(
    tester,
    390,
    layout: LinagoraEventCardLayout.regular,
  );

  expect(tester.takeException(), isNull);
  expect(find.byType(LinagoraEventDateIcon), findsOneWidget);
  expect(
    tester.widget<LinagoraEventCard>(find.byType(LinagoraEventCard)).layout,
    LinagoraEventCardLayout.regular,
  );
}

Future<void> _keepCompactLayoutAtDesktopWidth(WidgetTester tester) async {
  await _pumpAtWidth(
    tester,
    1150,
    layout: LinagoraEventCardLayout.compact,
  );

  expect(tester.takeException(), isNull);
  expect(find.byType(LinagoraEventDateIcon), findsNothing);
  expect(
    tester.widget<LinagoraEventCard>(find.byType(LinagoraEventCard)).layout,
    LinagoraEventCardLayout.compact,
  );
}

Future<void> _renderUnderUnboundedHorizontalConstraints(
  WidgetTester tester,
  LinagoraEventCardLayout layout,
) async {
  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _card(
        event: _layoutEvent(),
        layout: layout,
      ),
    ),
  ));
  await tester.pumpAndSettle();

  expect(tester.takeException(), isNull);
  expect(find.byType(LinagoraEventCard), findsOneWidget);
  expect(
    find.text(AppLocalizations().joinTheVideoConference),
    findsOneWidget,
  );
}

Future<void> _forwardLocalisedCopyAction(WidgetTester tester) async {
  const link = 'https://meet.example.invalid/room';
  final messenger = TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger;
  final clipboardCalls = <MethodCall>[];

  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.setData') clipboardCalls.add(call);
    return null;
  });
  addTearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: Builder(
      builder: (context) => _card(
        event: CalendarEvent(
          extensionFields: CalendarExtensionFields({
            'X-OPENPAAS-VIDEOCONFERENCE': [link],
          }),
        ),
        actions: CalendarEventCardActions(
          onReply: (_) {},
          onMailToAttendees: () {},
          onCopyLink: (link) => AppUtils.copyLinkToClipboard(context, link),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();

  final semantics = tester.ensureSemantics();
  try {
    final copyLabel = AppLocalizations().copyLink;
    final copyControl = find.bySemanticsLabel(copyLabel);

    expect(find.byTooltip(copyLabel), findsOneWidget);
    expect(copyControl, findsOneWidget);

    await tester.tap(copyControl);
    await tester.pump();

    expect({
      'clipboardMethod': clipboardCalls.single.method,
      'clipboardArguments': clipboardCalls.single.arguments,
      'snackBarCount':
          find.text(AppLocalizations().linkCopiedToClipboard).evaluate().length,
    }, {
      'clipboardMethod': 'Clipboard.setData',
      'clipboardArguments': {'text': link},
      'snackBarCount': 1,
    });
  } finally {
    semantics.dispose();
  }
}

double _fontSizeOf(WidgetTester tester, String text) => tester
    .renderObject<RenderParagraph>(find.text(text).first)
    .text
    .style!
    .fontSize!;

Future<void> _pumpAtWidth(
  WidgetTester tester,
  double width, {
  LinagoraEventCardLayout layout = LinagoraEventCardLayout.adaptive,
}) async {
  tester.view.physicalSize = Size(width, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: SingleChildScrollView(
      child: _card(
        event: _layoutEvent(),
        layout: layout,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Widget _testableCard({
  required CalendarEvent event,
  CalendarEventCardViewState? viewState,
  CalendarEventCardActions? actions,
  String? calendarUrl,
}) {
  return WidgetFixtures.makeTestableWidget(
    child: _card(
      event: event,
      viewState: viewState,
      actions: actions,
      calendarUrl: calendarUrl,
    ),
  );
}

Widget _card({
  required CalendarEvent event,
  CalendarEventCardViewState? viewState,
  CalendarEventCardActions? actions,
  LinagoraEventCardLayout layout = LinagoraEventCardLayout.adaptive,
  String? calendarUrl,
}) {
  return CalendarEventCardWidget(
    calendarEvent: event,
    viewState: viewState ?? _viewState(),
    actions: actions ?? CalendarEventCardActions(
      onReply: (_) {},
      onMailToAttendees: () {},
      onOpenLink: (_) {},
      onCopyLink: (_) {},
    ),
    layout: layout,
    calendarUrl: calendarUrl,
  );
}

CalendarEvent _layoutEvent() {
  return CalendarEvent(
    title: 'Automated DS Flutter',
    method: EventMethod.request,
    startUtcDate: UTCDate(DateTime(2026, 6, 16, 12)),
    endUtcDate: UTCDate(DateTime(2026, 6, 16, 12, 30)),
    organizer: CalendarOrganizer(
      mailto: MailAddress('organizer@example.invalid'),
    ),
    participants: [_attendee('Reader', 'reader@example.invalid')],
    extensionFields: CalendarExtensionFields({
      'X-OPENPAAS-VIDEOCONFERENCE': [
        'https://meet.example.invalid/layout-room',
      ],
    }),
  );
}

CalendarEventCardViewState _viewState({
  bool hasScheduleConflict = false,
  AttendanceStatus? attendanceStatus,
  bool replying = false,
  List<String> listEmailAddressSender = const [],
}) {
  return CalendarEventCardViewState(
    ownEmailAddress: 'reader@example.invalid',
    hasScheduleConflict: hasScheduleConflict,
    attendanceStatus: attendanceStatus,
    replying: replying,
    listEmailAddressSender: listEmailAddressSender,
  );
}

CalendarEvent _invitation({EventId? eventId}) {
  return CalendarEvent(
    eventId: eventId,
    method: EventMethod.request,
    organizer: CalendarOrganizer(
      mailto: MailAddress('organizer@example.invalid'),
    ),
    participants: [_attendee('Reader', 'reader@example.invalid')],
  );
}

CalendarAttendee _attendee(
  String name,
  String address, {
  String? participationStatus,
}) {
  return CalendarAttendee(
    name: CalendarAttendeeName(name),
    mailto: CalendarAttendeeMailTo(MailAddress(address)),
    participationStatus: participationStatus == null
        ? null
        : CalendarAttendeeParticipationStatus(participationStatus),
  );
}

List<CalendarAttendee> _attendees(String prefix) => [
  for (var index = 0; index < 7; index++)
    _attendee('$prefix $index', '$prefix$index@example.invalid'),
];

typedef _SuccessfulResponse = ({
  AttendanceStatus attendanceStatus,
  EventActionType actionType,
});

const _successfulResponses = <_SuccessfulResponse>[
  (
    attendanceStatus: AttendanceStatus.accepted,
    actionType: EventActionType.yes,
  ),
  (
    attendanceStatus: AttendanceStatus.tentativelyAccepted,
    actionType: EventActionType.maybe,
  ),
  (
    attendanceStatus: AttendanceStatus.rejected,
    actionType: EventActionType.no,
  ),
];
