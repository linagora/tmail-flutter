import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/model/calendar_event_card_view_state.dart';

void main() {
  test('meAddresses is exactly ownerEmailAddresses with no ownEmailAddress fallback', () {
    const state = CalendarEventCardViewState(
      ownEmailAddress: 'reader@example.invalid',
      ownerEmailAddresses: {},
    );

    expect(state.meAddresses, isEmpty);
  });
}
