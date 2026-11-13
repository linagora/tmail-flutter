import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribe/scribe/ai/data/service/prompt_service.dart';
import 'package:scribe/scribe/ai/domain/model/ai_message.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';
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

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _remoteDio(Map<String, dynamic> body) =>
    Dio()..httpClientAdapter = _JsonAdapter(body);

const _remotePromptUrl = 'https://domain.tld/scribe/prompts.json';

Map<String, dynamic> _remoteCatalog(List<Map<String, dynamic>> prompts) =>
    {'prompts': prompts};

Map<String, dynamic> _remotePrompt(String name, String userContent) => {
      'name': name,
      'messages': [
        {'role': 'system', 'content': 'Remote system prompt'},
        {'role': 'user', 'content': userContent},
      ],
    };

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PromptService', () {
    test('buildPromptByName should build prompt with input text', () async {
      // Arrange
      final service = PromptService(_throwingDio());

      // Act - this will use the real prompts.json file since the adapter throws
      final messages = await service.buildPromptByName('change-tone-casual', 'Hello, how are you?');

      // Assert
      expect(messages.length, 2);
      expect(messages.first.role, AIRole.system);
      expect(messages.last.role, AIRole.user);
      expect(messages.last.content, contains('Hello, how are you?'));
    });

    test('buildPromptByName should build prompt with input text and task', () async {
      // Arrange
      final service = PromptService(_throwingDio());
      
      // Act - this will use the real prompts.json file since the test client throws
      final messages = await service.buildPromptByName('custom-prompt-mail', 'Hello, how are you?', task: 'Make it more casual');

      // Assert
      expect(messages.length, 2);
      expect(messages.first.role, AIRole.system);
      expect(messages.last.role, AIRole.user);
      expect(messages.last.content, contains('Hello, how are you?'));
      expect(messages.last.content, contains('Make it more casual'));
    });
  });

  group('PromptService getPromptByName', () {
    test('getPromptByName should return correct prompt from assets', () async {
      final service = PromptService(_throwingDio());

      final prompt = await service.getPromptByName('change-tone-casual');

      expect(prompt.name, 'change-tone-casual');
      expect(prompt.messages.length, greaterThan(0));
    });

    test(
        'bundled prompts should cover every menu action '
        'and the custom prompt', () async {
      final service = PromptService(_throwingDio());
      final promptIds = [
        ...AIScribeMenuAction.values.map((action) => action.promptId),
        CustomPromptAction.promptId,
      ];

      for (final promptId in promptIds) {
        await expectLater(
          service.getPromptByName(promptId),
          completion(isA<Prompt>().having((p) => p.name, 'name', promptId)),
          reason: 'Missing bundled prompt: $promptId',
        );
      }
    });

    test('getPromptByName should throw exception for non-existent prompt',
        () async {
      final service = PromptService(_throwingDio());

      await expectLater(
        service.getPromptByName('non-existent-prompt'),
        throwsException,
      );
    });
  });

  group('PromptService with a remote prompt catalog', () {
    test(
        'getPromptByName should fall back to the bundled prompt '
        'when the remote catalog lacks it', () async {
      final service = PromptService(_remoteDio(_remoteCatalog([
        _remotePrompt('translate-english', 'Remote: {{input}}'),
      ])))
        ..setPromptUrl(_remotePromptUrl);

      final prompt = await service.getPromptByName('translate-mongolian');

      expect(prompt.name, 'translate-mongolian');
      expect(prompt.messages.last.content, contains('Mongolian'));
    });

    test(
        'getPromptByName should prefer the remote prompt '
        'over the bundled one with the same name', () async {
      final service = PromptService(_remoteDio(_remoteCatalog([
        _remotePrompt('translate-english', 'Remote: {{input}}'),
      ])))
        ..setPromptUrl(_remotePromptUrl);

      final messages =
          await service.buildPromptByName('translate-english', 'Bonjour');

      expect(messages.first.content, 'Remote system prompt');
      expect(messages.last.content, 'Remote: Bonjour');
    });

    test(
        'getPromptByName should still throw for a name '
        'neither the remote nor the bundled catalog has', () async {
      final service = PromptService(_remoteDio(_remoteCatalog([
        _remotePrompt('translate-english', 'Remote: {{input}}'),
      ])))
        ..setPromptUrl(_remotePromptUrl);

      await expectLater(
        service.getPromptByName('non-existent-prompt'),
        throwsException,
      );
    });
  });
}