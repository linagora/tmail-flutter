import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/workplace_fqdn_ecosystem_handler.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/workplace/workplace_fqdn_notifier.dart';

LinagoraEcosystem _ecosystem(String? template) => LinagoraEcosystem.deserialize(
      template == null ? {} : {'workplaceFqdnFallback': template},
    );

void _resetProvider() {
  appProviderContainer.read(workplaceFqdnProvider.notifier).setFqdn(null);
  appProviderContainer
      .read(workplaceFqdnProvider.notifier)
      .setFallbackFqdn(null);
}

/// Loads [template] through a handler resolving [ownerEmail] and returns the
/// provider state afterwards.
String? _loadAndReadState({required String? template, String? ownerEmail}) {
  WorkplaceFqdnEcosystemHandler(resolveOwnerEmail: () => ownerEmail)
      .onEcosystemLoaded(_ecosystem(template));
  return appProviderContainer.read(workplaceFqdnProvider);
}

void main() {
  group('WorkplaceFqdnEcosystemHandler', () {
    setUp(_resetProvider);
    tearDown(_resetProvider);

    test('resolves the localpart placeholder against the owner email', () {
      expect(
        _loadAndReadState(
          template: '{localpart}.twake.linagora.com',
          ownerEmail: 'alice@example.com',
        ),
        'alice.twake.linagora.com',
      );
    });

    test('strips dots from a dotted local part', () {
      expect(
        _loadAndReadState(
          template: '{localpart}.twake.linagora.com',
          ownerEmail: 'john.doe@corp.tld',
        ),
        'johndoe.twake.linagora.com',
      );
    });

    test('stores the template verbatim when it has no placeholder', () {
      expect(
        _loadAndReadState(
          template: 'workplace.example.com',
          ownerEmail: 'alice@example.com',
        ),
        'workplace.example.com',
      );
    });

    test('leaves the provider null when the key is absent', () {
      expect(
        _loadAndReadState(template: null, ownerEmail: 'alice@example.com'),
        isNull,
      );
    });

    test('leaves the provider null when the owner email is null', () {
      expect(
        _loadAndReadState(
          template: '{localpart}.twake.linagora.com',
          ownerEmail: null,
        ),
        isNull,
      );
    });

    test('leaves the provider null when the owner email is blank', () {
      expect(
        _loadAndReadState(
          template: '{localpart}.twake.linagora.com',
          ownerEmail: '   ',
        ),
        isNull,
      );
    });

    test('does not override an already-set userInfo value', () {
      appProviderContainer
          .read(workplaceFqdnProvider.notifier)
          .setFqdn('userinfo.example.com');

      expect(
        _loadAndReadState(
          template: '{localpart}.twake.linagora.com',
          ownerEmail: 'alice@example.com',
        ),
        'userinfo.example.com',
      );
    });

    test('onEcosystemCleared clears only the fallback', () {
      appProviderContainer
          .read(workplaceFqdnProvider.notifier)
          .setFqdn('userinfo.example.com');
      final handler = WorkplaceFqdnEcosystemHandler(
        resolveOwnerEmail: () => 'alice@example.com',
      );
      handler.onEcosystemLoaded(
        _ecosystem('{localpart}.twake.linagora.com'),
      );

      handler.onEcosystemCleared();

      expect(
        appProviderContainer.read(workplaceFqdnProvider),
        'userinfo.example.com',
      );
    });
  });
}
