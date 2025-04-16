import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/event_method.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_event_actions_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

void main() {
  group('list event actions extension test:', () {
    group('validActionsOfEventMethod test:', () {
      test(
        'should return all but acceptCounter '
        'when event method is not counter',
      () {
        // arrange
        const method = EventMethod.add;
        
        // act
        final result = EventActionType.values.validActionsOfEventMethod(method);
        
        // assert
        expect(result, equals([
          EventActionType.yes,
          EventActionType.maybe,
          EventActionType.no,
          EventActionType.mailToAttendees,
        ]));
      });

      test(
        'should only return acceptCounter and mailToAttendees '
        'when event method is counter',
      () {
        // arrange
        const method = EventMethod.counter;
        
        // act
        final result = EventActionType.values.validActionsOfEventMethod(method);
        
        // assert
        expect(result, equals([
          EventActionType.acceptCounter,
          EventActionType.mailToAttendees,
        ]));
      });
    });
  });
}