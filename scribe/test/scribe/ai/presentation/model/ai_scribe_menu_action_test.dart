import 'dart:typed_data';
import 'dart:ui';

import 'package:core/presentation/resources/image_paths.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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

  const translatePromptIds = [
    'translate-french',
    'translate-english',
    'translate-russian',
    'translate-vietnamese',
    'translate-mongolian',
    'translate-german',
    'translate-spanish',
    'translate-italian',
  ];

  const newLanguageByPromptId = {
    'translate-mongolian': 'Mongolian',
    'translate-german': 'German',
    'translate-spanish': 'Spanish',
    'translate-italian': 'Italian',
  };

  group('AIScribeMenuCategory.translate', () {
    test('translate menu lists every language in order with matching labels', () {
      final localizations = ScribeLocalizations();
      final actions = AIScribeMenuCategory.translate.actions;

      expect(
        actions.map((action) => action.promptId).toList(),
        translatePromptIds,
      );
      expect(
        actions.map((action) => action.getLabel(localizations)).toList(),
        [
          'French',
          'English',
          'Russian',
          'Vietnamese',
          'Mongolian',
          'German',
          'Spanish',
          'Italian',
        ],
      );
    });

    test('bundled prompts exist for the new languages with the right instruction',
        () async {
      final service = PromptService(_throwingDio());

      for (final entry in newLanguageByPromptId.entries) {
        final prompt = await service.getPromptByName(entry.key);
        expect(prompt.name, entry.key);
        expect(
          prompt.messages.last.content,
          contains('Translate the text to ${entry.value}.'),
        );
      }
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
