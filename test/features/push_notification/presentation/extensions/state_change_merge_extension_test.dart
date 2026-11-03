import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:jmap_dart_client/jmap/push/type_state.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/extensions/state_change_merge_extension.dart';

void main() {
  final alice = AccountId(Id('alice'));
  final bob = AccountId(Id('bob'));

  group('StateChange.mergeWith', () {
    test('keeps type keys of both accounts and lets later keys win', () {
      final earlier = StateChange('StateChange', {
        alice: TypeState({'Email': 's1', 'Mailbox': 'm1'}),
        bob: TypeState({'Email': 'b1'}),
      });
      final later = StateChange('StateChange', {
        alice: TypeState({'Email': 's2'}),
        bob: TypeState({'Mailbox': 'bm2'}),
      });

      final merged = earlier.mergeWith(later);

      expect(merged.changed[alice]!.typeState, {
        'Email': 's2',
        'Mailbox': 'm1',
      });
      expect(merged.changed[bob]!.typeState, {
        'Email': 'b1',
        'Mailbox': 'bm2',
      });
    });
  });

  group('StateChange list mergeAll', () {
    test('returns null for an empty list', () {
      expect(<StateChange>[].mergeAll(), isNull);
    });

    test('folds every change in order', () {
      final merged = [
        StateChange('StateChange', {alice: TypeState({'Email': 's1'})}),
        StateChange('StateChange', {bob: TypeState({'Email': 'b1'})}),
        StateChange('StateChange', {alice: TypeState({'Email': 's2'})}),
      ].mergeAll();

      expect(merged!.changed[alice]!.typeState['Email'], 's2');
      expect(merged.changed[bob]!.typeState['Email'], 'b1');
    });
  });
}
