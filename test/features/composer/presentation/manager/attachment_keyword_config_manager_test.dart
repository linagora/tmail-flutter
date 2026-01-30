import 'package:core/utils/config/app_config_loader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_keyword_config_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_keywords_configuration_parser.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/attachment_keyword_config.dart';

import 'attachment_keyword_config_manager_test.mocks.dart';

@GenerateMocks([AppConfigLoader])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AttachmentKeywordConfigManager manager;
  late MockAppConfigLoader mockLoader;

  setUp(() {
    manager = AttachmentKeywordConfigManager();
    manager.clearCache();
    mockLoader = MockAppConfigLoader();
    manager.injectLoader(mockLoader);
  });

  group('AttachmentKeywordConfigManager.getConfig', () {
    test('returns config loaded from loader on first call', () async {
      final config = AttachmentKeywordConfig(
        includeList: ['invoice'],
        excludeList: ['invoice-draft'],
      );

      when(mockLoader.load<AttachmentKeywordConfig>(
        any,
        any,
      )).thenAnswer((_) async => config);

      final result = await manager.getConfig();

      expect(result.includeList, equals(['invoice']));
      expect(result.excludeList, equals(['invoice-draft']));
    });

    test('returns cached result on second call without calling loader again', () async {
      final config = AttachmentKeywordConfig(includeList: ['invoice']);

      when(mockLoader.load<AttachmentKeywordConfig>(any, any))
          .thenAnswer((_) async => config);

      await manager.getConfig();
      await manager.getConfig();

      verify(mockLoader.load<AttachmentKeywordConfig>(
        any,
        argThat(isA<AttachmentKeywordsConfigurationParser>()),
      )).called(1);
    });

    test('returns empty AttachmentKeywordConfig when loader throws', () async {
      when(mockLoader.load<AttachmentKeywordConfig>(any, any))
          .thenThrow(Exception('file not found'));

      final result = await manager.getConfig();

      expect(result.includeList, isEmpty);
      expect(result.excludeList, isEmpty);
    });

    test('caches the empty fallback config on error (loader not called again)', () async {
      when(mockLoader.load<AttachmentKeywordConfig>(any, any))
          .thenThrow(Exception('file not found'));

      await manager.getConfig();
      await manager.getConfig();

      verify(mockLoader.load<AttachmentKeywordConfig>(any, any)).called(1);
    });
  });

  group('AttachmentKeywordConfigManager.clearCache', () {
    test('clearCache forces re-load on next getConfig call', () async {
      final config = AttachmentKeywordConfig(includeList: ['invoice']);

      when(mockLoader.load<AttachmentKeywordConfig>(any, any))
          .thenAnswer((_) async => config);

      await manager.getConfig();
      manager.clearCache();
      manager.injectLoader(mockLoader);
      await manager.getConfig();

      verify(mockLoader.load<AttachmentKeywordConfig>(any, any)).called(2);
    });
  });
}
