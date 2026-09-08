import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_controller.dart';

void main() {
  group('PaywallController.isReachable', () {
    test('should return false when neither workplace FQDN nor template is set',
        () {
      final ecosystem = LinagoraEcosystem.deserialize({
        'scribePromptUrl': 'https://domain.tld/scribe',
      });

      final result = PaywallController.isReachable(
        workplaceFqdn: null,
        paywallUrlTemplate: ecosystem.paywallUrlTemplate,
      );

      expect(result, isFalse);
    });

    test('should return true when the ecosystem exposes a paywall template',
        () {
      final ecosystem = LinagoraEcosystem.deserialize({
        'paywallUrlTemplate': 'https://domain.tld/paywall?email={localPart}',
      });

      final result = PaywallController.isReachable(
        workplaceFqdn: null,
        paywallUrlTemplate: ecosystem.paywallUrlTemplate,
      );

      expect(result, isTrue);
    });

    test('should return true when the workplace FQDN is set', () {
      final result = PaywallController.isReachable(
        workplaceFqdn: 'workplace.domain.tld',
        paywallUrlTemplate: null,
      );

      expect(result, isTrue);
    });

    test('should return false when the workplace FQDN is blank', () {
      final result = PaywallController.isReachable(
        workplaceFqdn: '   ',
        paywallUrlTemplate: '',
      );

      expect(result, isFalse);
    });
  });
}
