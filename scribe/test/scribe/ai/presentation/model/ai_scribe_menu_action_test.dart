import 'dart:typed_data';
import 'dart:ui';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:scribe/scribe/ai/data/service/prompt_service.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw Exception('Not found');
  }

  @override
  void close({bool force = false}) {}
}

Dio _throwingDio() => Dio()..httpClientAdapter = _ThrowingAdapter();

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ScribeLocalizations.load(const Locale('en'));
  });

  const newIds = [
    'translate-mongolian',
    'translate-german',
    'translate-spanish',
    'translate-italian',
  ];

  group('AIScribeMenuCategory.translate', () {
    test('translate menu offers Mongolian, German, Spanish and Italian', () {
      final promptIds = AIScribeMenuCategory.translate.actions
          .map((action) => action.promptId)
          .toList();

      expect(promptIds, containsAll(newIds));
    });

    test('translate menu labels include the new languages', () {
      final localizations = ScribeLocalizations();
      final labels = AIScribeMenuCategory.translate.actions
          .map((action) => action.getLabel(localizations))
          .toList();

      expect(labels, containsAll(['Mongolian', 'German', 'Spanish', 'Italian']));
    });

    test('bundled prompts exist for the new languages', () async {
      final service = PromptService(_throwingDio());

      for (final id in newIds) {
        final prompt = await service.getPromptByName(id);
        expect(prompt.name, id);
      }
    });

    test('existing languages keep their order and ids', () {
      final promptIds = AIScribeMenuCategory.translate.actions
          .map((action) => action.promptId)
          .take(4)
          .toList();

      expect(promptIds, [
        'translate-french',
        'translate-english',
        'translate-russian',
        'translate-vietnamese',
      ]);
    });

    test('translate actions are in the translate category without icon', () {
      for (final action in AIScribeMenuCategory.translate.actions) {
        expect(action.category, AIScribeMenuCategory.translate);
        expect(action.getIcon(ImagePaths()), isNull);
      }
    });
  });

  test('every action has a bundled prompt that embeds the input', () async {
    final service = PromptService(_throwingDio());

    for (final action in AIScribeMenuAction.values) {
      final messages = await service.buildPromptByName(action.promptId, 'Bonjour');
      expect(messages.last.content, contains('Bonjour'), reason: action.promptId);
    }
  });
}
