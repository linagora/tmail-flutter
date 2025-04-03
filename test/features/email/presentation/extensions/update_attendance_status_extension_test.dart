import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_accept_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_maybe_response.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/reply/calendar_event_reject_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_maybe_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reject_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/update_attendance_status_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';

import 'update_attendance_status_extension_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SingleEmailController>(),
])
void main() {
  final controller = MockSingleEmailController();
  group('update attendance status extension test', () {
    test(
      'should update attendance status '
      'when viewState is ParseCalendarEventSuccess',
    () {
      // Arrange
      when(controller.attendanceStatus).thenReturn(
        Rxn(AttendanceStatus.accepted),
      );
      final viewState = ParseCalendarEventSuccess([
        BlobCalendarEvent(
          blobId: Id('1'),
          calendarEventList: [],
          attendanceStatus: AttendanceStatus.accepted,
        ),
      ]);

      // Act
      controller.updateAttendanceStatus(viewState);

      // Assert
      expect(
        controller.attendanceStatus.value,
        viewState.blobCalendarEventList.firstOrNull?.attendanceStatus,
      );
    });
    test(
      'should return current attendance status '
      'when viewState is CalendarEventAccepted',
    () {
      // Arrange
      when(controller.attendanceStatus).thenReturn(Rxn());
      final viewState = CalendarEventAccepted(
        CalendarEventAcceptResponse(
          AccountId(Id('1')),
          [Id('1')],
        ),
        EmailId(Id('1')),
      );

      // Act
      controller.updateAttendanceStatus(viewState);

      // Assert
      expect(
        controller.attendanceStatus.value,
        AttendanceStatus.accepted,
      );
    });
    test(
      'should return current attendance status '
      'when viewState is CalendarEventMaybeSuccess',
    () {
      // Arrange
      when(controller.attendanceStatus).thenReturn(Rxn());
      final viewState = CalendarEventMaybeSuccess(
        CalendarEventMaybeResponse(
          AccountId(Id('1')),
          [Id('1')],
        ),
        EmailId(Id('1')),
      );

      // Act
      controller.updateAttendanceStatus(viewState);

      // Assert
      expect(
        controller.attendanceStatus.value,
        AttendanceStatus.tentativelyAccepted,
      );
    });
    test(
      'should return current attendance status '
      'when viewState is CalendarEventRejected',
    () {
      // Arrange
      when(controller.attendanceStatus).thenReturn(Rxn());
      final viewState = CalendarEventRejected(
        CalendarEventRejectResponse(
          AccountId(Id('1')),
          [Id('1')],
        ),
        EmailId(Id('1')),
      );

      // Act
      controller.updateAttendanceStatus(viewState);

      // Assert
      expect(
        controller.attendanceStatus.value,
        AttendanceStatus.rejected,
      );
    });
    test(
      'should keep current attendance status '
      'when viewState is other',
    () {
      // Arrange
      const currentStatus = AttendanceStatus.accepted;
      when(controller.attendanceStatus).thenReturn(Rxn(currentStatus));
      final viewState = ParseCalendarEventLoading();

      // Act
      controller.updateAttendanceStatus(viewState);

      // Assert
      expect(
        controller.attendanceStatus.value,
        currentStatus,
      );
    });
  });
}