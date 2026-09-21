import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_ecosystem_notifier.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_provider.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_source.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_sources.dart';
import 'package:tmail_ui_user/main/providers/workplace/fqdn/workplace_fqdn_user_info_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

WorkplaceFqdnSource _userInfo(ProviderContainer container) =>
    container.read(workplaceFqdnUserInfoProvider.notifier);

WorkplaceFqdnSource _ecosystem(ProviderContainer container) =>
    container.read(workplaceFqdnEcosystemProvider.notifier);

String? _state(ProviderContainer container) =>
    container.read(workplaceFqdnProvider);

ProviderContainer _makeContainer() => ProviderContainer();

void main() {
  group('WorkplaceFqdnUserInfoNotifier.setFqdn', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(_state(container), isNull);
    });

    test('null input → state null', () {
      _userInfo(container).setFqdn(null);
      expect(_state(container), isNull);
    });

    test('empty string → state null', () {
      _userInfo(container).setFqdn('');
      expect(_state(container), isNull);
    });

    test('whitespace-only → state null', () {
      _userInfo(container).setFqdn('   ');
      expect(_state(container), isNull);
    });

    test('bare domain → prefixed with https and stored trimmed', () {
      _userInfo(container).setFqdn('workplace.example.com');
      expect(_state(container), 'workplace.example.com');
    });

    test('https:// URL → stored as-is', () {
      _userInfo(container).setFqdn('https://workplace.example.com');
      expect(_state(container), 'https://workplace.example.com');
    });

    test('leading/trailing whitespace stripped before parse', () {
      _userInfo(container).setFqdn('  workplace.example.com  ');
      expect(_state(container), 'workplace.example.com');
    });

    test('invalid URI → state null', () {
      // Uri.tryParse returns non-null for almost anything, but a completely
      // invalid value with unescaped characters can produce null.
      // Verify state is null for an unparseable raw value.
      _userInfo(container).setFqdn(':::bad:::');
      expect(_state(container), isNull);
    });

    test('hostless URI → state null', () {
      _userInfo(container).setFqdn('https://');
      expect(_state(container), isNull);
      _userInfo(container).setFqdn('https:workplace.example.com');
      expect(_state(container), isNull);
    });

    test('URI carrying a path or query → state null', () {
      _userInfo(container).setFqdn('https://workplace.example.com/path');
      expect(_state(container), isNull);
      _userInfo(container).setFqdn('workplace.example.com?q=1');
      expect(_state(container), isNull);
    });

    test('trailing slash tolerated and stripped', () {
      _userInfo(container).setFqdn('https://workplace.example.com/');
      expect(_state(container), 'https://workplace.example.com');
      _userInfo(container).setFqdn('workplace.example.com/');
      expect(_state(container), 'workplace.example.com');
    });

    test('bare host starting with "http" is not read as schemed', () {
      _userInfo(container).setFqdn('httpadmin.twake.linagora.com');
      expect(_state(container), 'httpadmin.twake.linagora.com');
    });

    test('calling setFqdn twice: second call overwrites first', () {
      _userInfo(container).setFqdn('first.example.com');
      _userInfo(container).setFqdn('second.example.com');
      expect(_state(container), 'second.example.com');
    });

    test('reset to null after valid fqdn', () {
      _userInfo(container).setFqdn('workplace.example.com');
      _userInfo(container).setFqdn(null);
      expect(_state(container), isNull);
    });
  });

  group('workplaceFqdnProvider priority (userInfo vs ecosystem fallback)', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('fallback only → state is the fallback', () {
      _ecosystem(container).setFqdn('fallback.example.com');
      expect(_state(container), 'fallback.example.com');
    });

    test('userInfo only → state is the userInfo value', () {
      _userInfo(container).setFqdn('userinfo.example.com');
      expect(_state(container), 'userinfo.example.com');
    });

    test('fallback set, then userInfo set → userInfo wins', () {
      _ecosystem(container).setFqdn('fallback.example.com');
      _userInfo(container).setFqdn('userinfo.example.com');
      expect(_state(container), 'userinfo.example.com');
    });

    test('userInfo set, then fallback set → userInfo still wins', () {
      _userInfo(container).setFqdn('userinfo.example.com');
      _ecosystem(container).setFqdn('fallback.example.com');
      expect(_state(container), 'userinfo.example.com');
    });

    test('both set, then userInfo cleared → falls back to ecosystem value', () {
      _userInfo(container).setFqdn('userinfo.example.com');
      _ecosystem(container).setFqdn('fallback.example.com');
      _userInfo(container).setFqdn(null);
      expect(_state(container), 'fallback.example.com');
    });

    test('both set, then fallback cleared → userInfo still stands', () {
      _userInfo(container).setFqdn('userinfo.example.com');
      _ecosystem(container).setFqdn('fallback.example.com');
      _ecosystem(container).setFqdn(null);
      expect(_state(container), 'userinfo.example.com');
    });

    test('ecosystem source trims whitespace like userInfo', () {
      _ecosystem(container).setFqdn('  fallback.example.com  ');
      expect(_state(container), 'fallback.example.com');
    });

    test('ecosystem source rejects an unparseable value like userInfo', () {
      _ecosystem(container).setFqdn(':::bad:::');
      expect(_state(container), isNull);
    });

    test('ecosystem emits first, userInfo arrives later → userInfo wins', () {
      _ecosystem(container).setFqdn('fallback.example.com');
      expect(_state(container), 'fallback.example.com');

      _userInfo(container).setFqdn('userinfo.example.com');
      expect(_state(container), 'userinfo.example.com');
    });
  });

  group('workplaceFqdnSourcesProvider registration seam', () {
    test('priority follows workplaceFqdnSourcesProvider order', () {
      final reordered = ProviderContainer(
        overrides: [
          workplaceFqdnSourcesProvider.overrideWithValue([
            (ref) => ref.watch(workplaceFqdnEcosystemProvider),
            (ref) => ref.watch(workplaceFqdnUserInfoProvider),
          ]),
        ],
      );
      addTearDown(reordered.dispose);

      _userInfo(reordered).setFqdn('userinfo.example.com');
      _ecosystem(reordered).setFqdn('fallback.example.com');

      expect(_state(reordered), 'fallback.example.com');
    });
  });
}
