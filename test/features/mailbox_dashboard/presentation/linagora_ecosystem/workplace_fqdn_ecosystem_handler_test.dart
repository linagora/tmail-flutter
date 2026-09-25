import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/workplace_fqdn_ecosystem_handler.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_user_info_notifier.dart';

/// Exposes the [Ref] a provider is built with, mirroring how
/// `LinagoraEcosystemHandlerRegistry.ref` is sourced in production.
final _refProvider = Provider<Ref>((ref) => ref);

const _localPartTemplate = '{localPart}.twake.linagora.com';

LinagoraEcosystem _ecosystem(String? template) => LinagoraEcosystem.deserialize(
      template == null ? {} : {'workplaceFqdnFallback': template},
    );

/// Loads [template] through a handler resolving [ownerEmail] and returns the
/// provider state afterwards.
String? _loadAndReadState(
  ProviderContainer container, {
  required String? template,
  String? ownerEmail,
}) {
  WorkplaceFqdnEcosystemHandler(
    ref: container.read(_refProvider),
    resolveOwnerEmail: () => ownerEmail,
  ).onEcosystemLoaded(_ecosystem(template));
  return container.read(workplaceFqdnProvider);
}

final _localPartResolutionCases = [
  (
    description: 'resolves the {localPart} placeholder against the owner email',
    ownerEmail: 'alice@example.com',
    expected: 'alice.twake.linagora.com',
  ),
  (
    description: 'strips dots from a dotted local part',
    ownerEmail: 'john.doe@corp.tld',
    expected: 'johndoe.twake.linagora.com',
  ),
  (
    description: 'leaves the provider null when the owner email is null',
    ownerEmail: null,
    expected: null,
  ),
  (
    description: 'leaves the provider null when the owner email is blank',
    ownerEmail: '   ',
    expected: null,
  ),
  (
    description: 'leaves the provider null when the username is not an address',
    ownerEmail: 'alice',
    expected: null,
  ),
];

void main() {
  group('WorkplaceFqdnEcosystemHandler', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    for (final testCase in _localPartResolutionCases) {
      test(testCase.description, () {
        expect(
          _loadAndReadState(
            container,
            template: _localPartTemplate,
            ownerEmail: testCase.ownerEmail,
          ),
          testCase.expected,
        );
      });
    }

    test('resolves domainPart as an alias of domainName', () {
      expect(
        _loadAndReadState(
          container,
          template: '{localPart}.{domainPart}',
          ownerEmail: 'alice@example.com',
        ),
        'alice.example.com',
      );
    });

    for (final ownerEmail in const ['alice@example.com', null]) {
      test('stores a literal template regardless of owner email ($ownerEmail)', () {
        expect(
          _loadAndReadState(
            container,
            template: 'workplace.example.com',
            ownerEmail: ownerEmail,
          ),
          'workplace.example.com',
        );
      });
    }

    test('leaves the provider null when the key is absent', () {
      expect(
        _loadAndReadState(container, template: null, ownerEmail: 'alice@example.com'),
        isNull,
      );
    });

    test('does not override an already-set userInfo value', () {
      container.read(workplaceFqdnUserInfoProvider.notifier).setFqdn('userinfo.example.com');

      expect(
        _loadAndReadState(
          container,
          template: _localPartTemplate,
          ownerEmail: 'alice@example.com',
        ),
        'userinfo.example.com',
      );
    });

    test('onEcosystemCleared clears only the ecosystem source', () {
      container.read(workplaceFqdnUserInfoProvider.notifier).setFqdn('userinfo.example.com');
      final handler = WorkplaceFqdnEcosystemHandler(
        ref: container.read(_refProvider),
        resolveOwnerEmail: () => 'alice@example.com',
      );
      handler.onEcosystemLoaded(_ecosystem(_localPartTemplate));

      handler.onEcosystemCleared();

      expect(container.read(workplaceFqdnProvider), 'userinfo.example.com');
    });
  });
}
