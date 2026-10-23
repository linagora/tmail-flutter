import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';

void main() {
  group('equality', () {
    test('results without data are equal by type only', () {
      // A tear-off builds distinct instances, so the equality goes through props.
      const newSwitched = AccountSwitched.new;
      expect(newSwitched(), newSwitched());
      expect(const AccountSwitchCancelled(), isNot(const AccountSwitchTimedOut()));
    });

    test('refusals are equal only for the same reason', () {
      expect(
        const AccountSwitchRefused(AccountSwitchRefusal.composerOpen),
        isNot(const AccountSwitchRefused(AccountSwitchRefusal.switchInProgress)),
      );
    });

    test('failures are equal only for the same error and stack trace', () {
      final error = Exception('load failed');
      final stackTrace = StackTrace.current;

      expect(AccountSwitchFailed(error, stackTrace), AccountSwitchFailed(error, stackTrace));
      expect(
        AccountSwitchFailed(error, stackTrace),
        isNot(AccountSwitchFailed(Exception('other failure'), stackTrace)),
      );
      expect(
        AccountSwitchFailed(error, stackTrace),
        isNot(AccountSwitchFailed(error, StackTrace.empty)),
      );
    });
  });
}
