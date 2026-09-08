import 'package:date_format/date_format.dart' as date_format;
import 'package:flutter/widgets.dart';
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
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/mail_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/presentation/mapper/calendar_event_card_mapper.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_actions.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_view_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

void main() {
  final appLocalizations = AppLocalizations();

  group('CalendarEventCardMapper::date', () {
    test('SHOULD build the marker from the start date', () {
      final mapper = _mapper(
        event: _event(start: DateTime(2026, 6, 16, 10)),
      );

      expect(mapper.date?.day, '16');
      expect(mapper.date?.month, isNotEmpty);
    });

    test('SHOULD omit the marker WHEN the event has no start date', () {
      expect(_mapper(event: _event()).date, isNull);
    });

    for (final monthLabel in const ['1月', 'janv.', 'Sept', 'Th01']) {
      test('SHOULD keep the localised month label $monthLabel', () {
        final mapper = _mapper(
          event: _event(start: DateTime(2026, 1, 16, 10)),
          options: _mappingOptions(
            dateLocale: _MonthDateLocale(monthLabel),
          ),
        );

        expect(mapper.date?.month, monthLabel);
      });
    }

    test('SHOULD omit the marker WHEN the localised month is blank', () {
      final mapper = _mapper(
        event: _event(start: DateTime(2026, 1, 16, 10)),
        options: _mappingOptions(
          dateLocale: const _MonthDateLocale('   '),
        ),
      );

      expect(mapper.date, isNull);
    });
  });

  group('CalendarEventCardMapper::cardData', () {
    test('SHOULD map every populated section to the design system data', () {
      final data = _mapper(
        event: _event(
          start: DateTime(2026, 6, 16, 10),
          end: DateTime(2026, 6, 16, 11),
          location: 'Villa Good Tech',
          title: 'Automated DS Flutter',
          method: EventMethod.request,
          organizer: _organizer('Alex Martin', 'alex.martin@example.invalid'),
          attendees: [
            _attendee('Reader', _ownEmailAddress),
            _attendee('Jordan Blake', 'jordan.blake@example.invalid'),
          ],
          conferenceLink: 'https://meet.example.invalid/room',
        ),
        viewState: _viewState(
          attendanceStatus: AttendanceStatus.accepted,
          hasScheduleConflict: true,
        ),
      ).cardData;

      expect({
        'day': data.date?.day,
        'activity': data.activity,
        'actorName': data.actorName,
        'title': data.title,
        'hasConference': data.conference != null,
        'detailLabels': data.details.map((detail) => detail.label).toList(),
        'hasConflictIndicator':
            data.details.first.indicator is LinagoraEventConflictIndicator,
        'responseCount': data.attending?.responses.length,
        'selectedResponseId': data.attending?.selectedResponseId,
        'actionCount': data.actions.length,
        'status': data.status,
      }, {
        'day': '16',
        'activity': appLocalizations.messageEventActionBannerOrganizerInvited,
        'actorName': 'Alex Martin',
        'title': 'Automated DS Flutter',
        'hasConference': true,
        'detailLabels': [
          appLocalizations.when,
          appLocalizations.where,
          appLocalizations.who,
        ],
        'hasConflictIndicator': true,
        'responseCount': 3,
        'selectedResponseId': EventActionType.yes,
        'actionCount': 1,
        'status': null,
      });
    });
  });

  group('CalendarEventCardMapper::details', () {
    test('SHOULD drop every row WHEN the event carries nothing', () {
      expect(_mapper(event: _event()).details, isEmpty);
    });

    test('SHOULD set the day apart from the time WHEN the event is timed', () {
      final details = _mapper(
        event: _event(
          start: DateTime(2026, 6, 16, 10),
          end: DateTime(2026, 6, 16, 11),
        ),
      ).details;

      expect({
        'label': details.single.label,
        'values': details.single.values.map((value) => value.text).toList(),
        'emphases':
            details.single.values.map((value) => value.emphasis).toList(),
        'indicator': details.single.indicator,
      }, {
        'label': appLocalizations.when,
        'values': [
          'Tuesday, June 16, 2026',
          LinagoraEventDetail.defaultDateTimeSeparator,
          '10:00 AM - 11:00 AM',
        ],
        'emphases': const [
          LinagoraEventInfoEmphasis.strong,
          LinagoraEventInfoEmphasis.normal,
          LinagoraEventInfoEmphasis.normal,
        ],
        'indicator': null,
      });
    });

    test('SHOULD keep an all-day event whole WHEN it has no clock time', () {
      final details = _mapper(
        event: _event(
          start: DateTime(2026, 6, 16),
          end: DateTime(2026, 6, 17),
        ),
      ).details;

      expect(details.single.values.single.text, 'Tuesday, June 16, 2026 (UTC)');
      expect(
        details.single.values.single.emphasis,
        LinagoraEventInfoEmphasis.strong,
      );
    });

    test('SHOULD keep a multi-day range whole WHEN it cannot be split', () {
      final details = _mapper(
        event: _event(
          start: DateTime(2026, 6, 16, 10),
          end: DateTime(2026, 6, 17, 11),
        ),
      ).details;

      expect(details.single.values, hasLength(1));
      expect(details.single.values.single.text, contains(' - '));
    });

    test('SHOULD mark a clash WHEN the reader is busy at that time', () {
      final details = _mapper(
        event: _event(
          start: DateTime(2026, 6, 16, 10),
          end: DateTime(2026, 6, 16, 11),
        ),
        viewState: _viewState(hasScheduleConflict: true),
      ).details;

      expect(details.single.indicator, isA<LinagoraEventConflictIndicator>());
    });

    test('SHOULD drop the location row WHEN the event has no location', () {
      expect(
        _mapper(event: _event(location: '')).details,
        isEmpty,
      );
    });

    test('SHOULD keep a plain location in one value', () {
      final where = _rowFor(
        _mapper(event: _event(location: 'Villa Good Tech, 37 rue Pierre')),
        appLocalizations.where,
      );

      expect(where.values.single.text, 'Villa Good Tech, 37 rue Pierre');
      expect(where.values.single.onTap, isNull);
    });

    test('SHOULD make a location URL reachable', () {
      final openedLinks = <String>[];
      final where = _rowFor(
        _mapper(
          event: _event(location: 'Room 3 https://meet.example.com/abc'),
          actions: _actions(
            links: (open: openedLinks.add, copy: null),
          ),
        ),
        appLocalizations.where,
      );

      expect(where.values.map((value) => value.text), [
        'Room 3 ',
        'meet.example.com/abc',
      ]);
      expect(where.valueSpacing, 0);
      expect(where.values.last.emphasis, LinagoraEventInfoEmphasis.link);

      where.values.last.onTap!();
      expect(openedLinks, ['https://meet.example.com/abc']);
    });

    test('SHOULD open a composer for an address written into the location', () {
      final composed = <String>[];
      final where = _rowFor(
        _mapper(
          event: _event(location: 'Ask jordan.blake@example.invalid'),
          actions: _actions(
            addresses: (compose: composed.add, open: null),
          ),
        ),
        appLocalizations.where,
      );

      where.values.last.onTap!();
      expect(composed, ['jordan.blake@example.invalid']);
    });

    test('SHOULD preserve punctuation around a location URL', () {
      final where = _rowFor(
        _mapper(
          event: _event(
            location: 'Room (https://meet.example.com/abc), floor 2',
          ),
        ),
        appLocalizations.where,
      );

      expect(where.values.map((value) => value.text), [
        'Room (',
        'meet.example.com/abc',
        '), floor 2',
      ]);
      expect(where.valueSpacing, 0);
    });

    test('SHOULD preserve whitespace between adjacent location URLs', () {
      final where = _rowFor(
        _mapper(
          event: _event(
            location: 'https://first.example.com https://second.example.com',
          ),
        ),
        appLocalizations.where,
      );

      expect(where.values.map((value) => value.text), [
        'first.example.com',
        ' ',
        'second.example.com',
      ]);
      expect(where.valueSpacing, 0);
    });
  });

  group('CalendarEventCardMapper::participants', () {
    test('SHOULD drop the row WHEN there is nobody to show', () {
      expect(_mapper(event: _event()).details, isEmpty);
    });

    test('SHOULD lead with the organiser and label them as such', () {
      final who = _rowFor(
        _mapper(
          event: _event(
            organizer: _organizer('Alex Martin', 'alex.martin@example.invalid'),
          ),
        ),
        appLocalizations.who,
      );

      expect(who.values.map((value) => value.text), [
        'Alex Martin',
        'alex.martin@example.invalid',
        '- ${appLocalizations.organizer}',
      ]);
      expect(who.lines, isEmpty);
      expect(who.action, isNull);
    });

    test('SHOULD open the details of an address that is tapped', () {
      final opened = <EmailAddress>[];
      final who = _rowFor(
        _mapper(
          event: _event(
            organizer: _organizer('Alex Martin', 'alex.martin@example.invalid'),
            attendees: [_attendee('Jordan Blake', 'jordan.blake@example.invalid')],
          ),
          actions: _actions(
            addresses: (compose: null, open: opened.add),
          ),
        ),
        appLocalizations.who,
      );

      who.values[1].onTap!();
      who.lines.single.values.last.onTap!();

      expect(
        opened.map((address) => address.email),
        ['alex.martin@example.invalid', 'jordan.blake@example.invalid'],
      );
    });

    test('SHOULD keep every attendee WHEN the list is short enough', () {
      final who = _rowFor(
        _mapper(event: _event(attendees: _attendees(6))),
        appLocalizations.who,
      );

      expect(who.values, isEmpty);
      expect(who.lines, hasLength(6));
      expect(who.action, isNull);
    });

    test('SHOULD let the design system collapse a long list', () {
      final event = _event(attendees: _attendees(10));
      final who = _rowFor(
        _mapper(event: event),
        appLocalizations.who,
      );

      expect({
        'lineCount': who.lines.length,
        'expandLabel': who.expansion?.expandLabel,
        'collapseLabel': who.expansion?.collapseLabel,
        'collapsedLineCount': who.expansion?.collapsedLineCount,
        'collapseThreshold': who.expansion?.collapseThreshold,
        'keepsEventIdentity': identical(who.expansion?.identity, event),
      }, {
        'lineCount': 10,
        'expandLabel': appLocalizations.seeAllAttendees,
        'collapseLabel': appLocalizations.hide,
        'collapsedLineCount': 1,
        'collapseThreshold': 1,
        'keepsEventIdentity': true,
      });
    });

    test('SHOULD hide attendees before expansion WHEN organizer is shown', () {
      final who = _rowFor(
        _mapper(
          event: _event(
            organizer: _organizer('Alex Martin', 'alex.martin@example.invalid'),
            attendees: [
              _attendee('Jordan Blake', 'jordan.blake@example.invalid'),
            ],
          ),
        ),
        appLocalizations.who,
      );

      expect({
        'lineCount': who.lines.length,
        'collapsedLineCount': who.expansion?.collapsedLineCount,
        'collapseThreshold': who.expansion?.collapseThreshold,
      }, {
        'lineCount': 1,
        'collapsedLineCount': 0,
        'collapseThreshold': 0,
      });
    });

    test('SHOULD leave the organiser out of the attendee lines', () {
      final who = _rowFor(
        _mapper(
          event: _event(
            organizer: _organizer('Alex Martin', 'alex.martin@example.invalid'),
            attendees: [
              _attendee('Alex Martin', 'alex.martin@example.invalid'),
              _attendee('Jordan Blake', 'jordan.blake@example.invalid'),
            ],
          ),
        ),
        appLocalizations.who,
      );

      expect(who.lines.single.values.first.text, 'Jordan Blake');
    });

    test('SHOULD not add the organiser label WHEN the organiser is empty', () {
      final who = _rowFor(
        _mapper(
          event: _event(
            organizer: CalendarOrganizer(
              name: ' ',
              mailto: MailAddress(''),
            ),
            attendees: [
              _attendee('Jordan Blake', 'jordan.blake@example.invalid'),
            ],
          ),
        ),
        appLocalizations.who,
      );

      expect(who.values, isEmpty);
      expect(
        who.lines.expand((line) => line.values).map((value) => value.text),
        isNot(contains('- ${appLocalizations.organizer}')),
      );
      expect(who.expansion?.collapsedLineCount, 1);
      expect(who.expansion?.collapseThreshold, 1);
    });

    test('SHOULD filter attendees with no name and no address', () {
      final who = _rowFor(
        _mapper(
          event: _event(
            attendees: [
              CalendarAttendee(),
              _attendee('', ''),
              _attendee('Jordan Blake', 'jordan.blake@example.invalid'),
            ],
          ),
        ),
        appLocalizations.who,
      );

      expect(who.lines, hasLength(1));
      expect(who.lines.single.values.first.text, 'Jordan Blake');
    });

    test('SHOULD drop the row WHEN the organiser and attendees are empty', () {
      final mapper = _mapper(
        event: _event(
          organizer: CalendarOrganizer(),
          attendees: [CalendarAttendee()],
        ),
      );

      expect(
        mapper.details.where((detail) => detail.label == appLocalizations.who),
        isEmpty,
      );
    });
  });

  group('CalendarEventCardMapper::conference', () {
    test('SHOULD omit the block WHEN the event carries no link', () {
      expect(_mapper(event: _event()).conference, isNull);
    });

    test('SHOULD omit the block WHEN the event link is blank', () {
      final mapper = _mapper(event: _event(conferenceLink: '   '));

      expect(mapper.conference, isNull);
    });

    test('SHOULD join and copy the conference link', () {
      final opened = <String>[];
      final copied = <String>[];
      final conference = _mapper(
        event: _event(conferenceLink: 'https://meet.example.invalid/room'),
        actions: _actions(
          links: (open: opened.add, copy: copied.add),
        ),
      ).conference!;

      conference.join!.onPressed!();
      conference.onCopyLink!();

      expect({
        'joinLabel': conference.join!.label,
        'copyTooltip': conference.copyTooltip,
        'copySemanticLabel': conference.copySemanticLabel,
        'opened': opened,
        'copied': copied,
      }, {
        'joinLabel': appLocalizations.joinTheVideoConference,
        'copyTooltip': appLocalizations.copyLink,
        'copySemanticLabel': appLocalizations.copyLink,
        'opened': ['https://meet.example.invalid/room'],
        'copied': ['https://meet.example.invalid/room'],
      });
    });

    test('SHOULD keep every conference link reachable', () {
      final opened = <String>[];
      final cardData = _mapper(
        event: _event(
          conferenceLink: 'https://openpaas.example.invalid/room',
          googleConferenceLink: 'https://meet.google.example.invalid/room',
        ),
        actions: _actions(
          links: (open: opened.add, copy: null),
        ),
      ).cardData;

      cardData.conference!.join!.onPressed!();
      cardData.additionalConferences.single.join!.onPressed!();

      expect(
        cardData.additionalConferences.single.join!.label,
        'https://meet.google.example.invalid/room',
      );
      expect(opened, [
        'https://openpaas.example.invalid/room',
        'https://meet.google.example.invalid/room',
      ]);
    });
  });

  group('CalendarEventCardMapper::attending', () {
    test('SHOULD omit the answers WHEN the reader was not invited', () {
      final mapper = _mapper(
        event: _event(
          method: EventMethod.request,
          organizer: _organizer('Alex Martin', 'alex.martin@example.invalid'),
          attendees: [_attendee('Jordan Blake', 'jordan.blake@example.invalid')],
        ),
      );

      expect(mapper.attending, isNull);
      expect(mapper.status?.message, isNotEmpty);
    });

    test('SHOULD offer the three answers to an invitation', () {
      final mapper = _mapper(event: _invitation());

      expect(
        mapper.attending!.responses.map((response) => response.label),
        [appLocalizations.yes, appLocalizations.maybe, appLocalizations.no],
      );
      expect(mapper.attending!.selectedResponseId, isNull);
      expect(mapper.status, isNull);
    });

    for (final settledResponse in _settledResponses) {
      test(
        'SHOULD disable ${settledResponse.actionType.name} '
        'WHEN that answer is already on record',
        () {
          final mapper = _mapper(
            event: _invitation(),
            viewState: _viewState(
              attendanceStatus: settledResponse.attendanceStatus,
            ),
          );
          final responses = mapper.attending!.responses;
          final selected = responses.firstWhere(
            (response) => response.id == settledResponse.actionType,
          );

          expect(
            mapper.attending!.selectedResponseId,
            settledResponse.actionType,
          );
          expect(selected.id, settledResponse.actionType);
          expect(mapper.attending!.isSelected(selected), isTrue);
          expect(selected.onPressed, isNull);
          expect(
            responses.where((response) => response != selected).every(
              (response) => response.onPressed != null,
            ),
            isTrue,
          );
        },
      );
    }

    test('SHOULD hold every answer WHILE one is in flight', () {
      final mapper = _mapper(
        event: _invitation(),
        viewState: _viewState(replying: true),
      );

      expect(
        mapper.attending!.responses.every(
          (response) => response.onPressed == null,
        ),
        isTrue,
      );
    });

    test('SHOULD report the answer that was chosen', () {
      final answers = <EventActionType>[];
      final mapper = _mapper(
        event: _invitation(),
        actions: _actions(onReply: answers.add),
      );

      mapper.attending!.responses.first.onPressed!();

      expect(answers, [EventActionType.yes]);
    });

    test(
      'SHOULD keep a counter proposal answerable however the attendance stands',
      () {
        final mapper = _mapper(
          event: _invitation(method: EventMethod.counter),
          viewState: _viewState(attendanceStatus: AttendanceStatus.accepted),
        );

        expect(
          mapper.attending!.responses.single.label,
          appLocalizations.yes,
        );
        expect(
          mapper.attending!.selectedResponseId,
          isNull,
          reason: 'the single counter answer never settles',
        );
      },
    );

    test('SHOULD keep a counter proposal answerable WHILE replying', () {
      final answers = <EventActionType>[];
      final mapper = _mapper(
        event: _invitation(method: EventMethod.counter),
        viewState: _viewState(replying: true),
        actions: _actions(onReply: answers.add),
      );

      mapper.attending!.responses.single.onPressed!();

      expect(answers, [EventActionType.acceptCounter]);
    });

    test('SHOULD offer to write to attendees beside the answers', () {
      var mailed = 0;
      final mapper = _mapper(
        event: _invitation(),
        actions: _actions(onMailToAttendees: () => mailed++),
      );

      mapper.cardActions.single.onPressed!();

      expect(mapper.cardActions.single.label, appLocalizations.mailToAttendees);
      expect(mailed, 1);
    });
  });

  group('CalendarEventCardMapper::activity', () {
    test('SHOULD name the organiser who sent an invitation', () {
      final mapper = _mapper(event: _invitation());

      expect({
        'hasActivity': mapper.hasActivity,
        'actorName': mapper.actorName,
        'activity': mapper.activity,
        'activityState': mapper.activityState,
      }, {
        'hasActivity': true,
        'actorName': 'Alex Martin',
        'activity': appLocalizations.messageEventActionBannerOrganizerInvited,
        'activityState': EventActivityBadgeState.created,
      });
    });

    test('SHOULD show no badge WHEN the method carries no message', () {
      expect(_mapper(event: _event(method: EventMethod.publish)).hasActivity, isFalse);
    });

    test('SHOULD colour a cancellation as cancelled', () {
      expect(
        _mapper(event: _event(method: EventMethod.cancel)).activityState,
        EventActivityBadgeState.canceled,
      );
    });

    for (final entry in _replyStates.entries) {
      test('SHOULD colour a ${entry.key} reply accordingly', () {
        final mapper = _mapper(
          event: _event(
            method: EventMethod.reply,
            attendees: [
              _attendee(
                'Jordan Blake',
                'jordan.blake@example.invalid',
                participationStatus: entry.key,
              ),
            ],
          ),
          viewState: _viewState(
            listEmailAddressSender: const ['jordan.blake@example.invalid'],
          ),
        );

        expect(mapper.activityState, entry.value);
      });
    }
  });
}

const _ownEmailAddress = 'reader@example.invalid';

const _replyStates = <String, EventActivityBadgeState>{
  'ACCEPTED': EventActivityBadgeState.accepted,
  'TENTATIVE': EventActivityBadgeState.updated,
  'DECLINED': EventActivityBadgeState.canceled,
};

const _settledResponses = [
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

CalendarEventCardMapper _mapper({
  required CalendarEvent event,
  CalendarEventCardViewState? viewState,
  CalendarEventCardActions? actions,
  CalendarEventCardMappingOptions? options,
}) {
  return CalendarEventCardMapper(
    event: event,
    viewState: viewState ?? _viewState(),
    actions: actions ?? _actions(),
    options: options ?? _mappingOptions(),
  );
}

CalendarEventCardMappingOptions _mappingOptions({
  date_format.DateLocale dateLocale = const date_format.EnglishDateLocale(),
}) {
  return CalendarEventCardMappingOptions(
    appLocalizations: AppLocalizations(),
    dateLocale: dateLocale,
    timeZone: 'UTC',
  );
}

CalendarEventCardViewState _viewState({
  AttendanceStatus? attendanceStatus,
  bool replying = false,
  bool hasScheduleConflict = false,
  List<String> listEmailAddressSender = const [],
}) {
  return CalendarEventCardViewState(
    ownEmailAddress: _ownEmailAddress,
    listEmailAddressSender: listEmailAddressSender,
    attendanceStatus: attendanceStatus,
    replying: replying,
    hasScheduleConflict: hasScheduleConflict,
  );
}

CalendarEventCardActions _actions({
  OnEventReplyAction? onReply,
  VoidCallback? onMailToAttendees,
  _LinkActions? links,
  _AddressActions? addresses,
}) {
  return CalendarEventCardActions(
    onReply: onReply ?? (_) {},
    onMailToAttendees: onMailToAttendees ?? () {},
    onOpenLink: links?.open,
    onCopyLink: links?.copy,
    onOpenComposer: addresses?.compose,
    onOpenEmailAddress: addresses?.open,
  );
}

typedef _LinkActions = ({
  OnEventLinkAction? open,
  OnEventLinkAction? copy,
});

typedef _AddressActions = ({
  OnEventMailAddressAction? compose,
  OnEventEmailAddressAction? open,
});

CalendarEvent _event({
  DateTime? start,
  DateTime? end,
  String? location,
  String? title,
  EventMethod? method,
  CalendarOrganizer? organizer,
  List<CalendarAttendee>? attendees,
  String? conferenceLink,
  String? googleConferenceLink,
}) {
  return CalendarEvent(
    title: title,
    location: location,
    method: method,
    organizer: organizer,
    participants: attendees,
    startUtcDate: start == null ? null : UTCDate(start),
    endUtcDate: end == null ? null : UTCDate(end),
    extensionFields: conferenceLink == null && googleConferenceLink == null
        ? null
        : CalendarExtensionFields({
            if (conferenceLink != null)
              'X-OPENPAAS-VIDEOCONFERENCE': [conferenceLink],
            if (googleConferenceLink != null)
              'X-GOOGLE-CONFERENCE': [googleConferenceLink],
          }),
  );
}

/// An invitation the reader is listed in and can answer.
CalendarEvent _invitation({EventMethod method = EventMethod.request}) {
  return _event(
    method: method,
    organizer: _organizer('Alex Martin', 'alex.martin@example.invalid'),
    attendees: [_attendee('Reader', _ownEmailAddress)],
  );
}

CalendarOrganizer _organizer(String name, String address) =>
    CalendarOrganizer(name: name, mailto: MailAddress(address));

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

List<CalendarAttendee> _attendees(int count) => [
  for (var index = 0; index < count; index++)
    _attendee('Attendee $index', 'attendee$index@example.invalid'),
];

LinagoraEventDetail _rowFor(CalendarEventCardMapper mapper, String label) =>
    mapper.details.firstWhere((detail) => detail.label == label);

class _MonthDateLocale implements date_format.DateLocale {
  final String monthLabel;

  const _MonthDateLocale(this.monthLabel);

  @override
  List<String> get monthsShort => List.filled(12, monthLabel);

  @override
  List<String> get monthsLong =>
      const date_format.EnglishDateLocale().monthsLong;

  @override
  List<String> get daysShort =>
      const date_format.EnglishDateLocale().daysShort;

  @override
  List<String> get daysLong =>
      const date_format.EnglishDateLocale().daysLong;

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';
}
