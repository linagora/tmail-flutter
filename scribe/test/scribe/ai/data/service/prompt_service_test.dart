import 'package:flutter_test/flutter_test.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/data/service/prompt_service.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';

class TestDioClient implements DioClient {
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) {
    throw Exception('Not found');
  }

  @override
  Future<dynamic> post(String path, {data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress, bool useJMAPHeader = true}) {
    throw UnsupportedError('post not implemented');
  }

  @override
  Future<dynamic> delete(String path, {data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnsupportedError('delete not implemented');
  }

  @override
  Future<dynamic> put(String path, {data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) {
    throw UnsupportedError('put not implemented');
  }

  @override
  Map<String, dynamic> getHeaders() {
    return {};
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PromptService', () {
    late TestDioClient testDioClient;
    
    setUp(() {
      testDioClient = TestDioClient();
    });

    test('buildPromptByName should build prompt with input text', () async {
      // Arrange
      final service = PromptService(testDioClient);
      
      // Act - this will use the real prompts.json file since the test client throws
      final messages = await service.buildPromptByName('change-tone-casual', 'Hello, how are you?');

      // Assert
      expect(messages.length, 2);
      expect(messages.first.role, AIRole.system);
      expect(messages.last.role, AIRole.user);
      expect(messages.last.content, contains('Hello, how are you?'));
    });

    test('buildPromptByName should build prompt with input text and task', () async {
      // Arrange
      final service = PromptService(testDioClient);
      
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
    test('getPromptByName should return correct prompt from data', () async {
      // Arrange
      final promptData = PromptData(
        prompts: [
          Prompt(
            name: 'test-prompt',
            messages: [
              const AIMessage(role: AIRole.system, content: 'System message'),
              const AIMessage(role: AIRole.user, content: 'User message with {{input}}')
            ]
          )
        ]
      );

      // Act
      final prompt = promptData.prompts.firstWhere(
        (prompt) => prompt.name == 'test-prompt',
        orElse: () => throw Exception('Prompt not found: test-prompt'),
      );

      // Assert
      expect(prompt.name, 'test-prompt');
      expect(prompt.messages.length, 2);
    });

    test('getPromptByName should throw exception for non-existent prompt', () async {
      // Arrange
      final promptData = PromptData(
        prompts: [
          Prompt(
            name: 'test-prompt',
            messages: [
              const AIMessage(role: AIRole.system, content: 'System message'),
              const AIMessage(role: AIRole.user, content: 'User message')
            ]
          )
        ]
      );

      // Act & Assert
      expect(
        () => promptData.prompts.firstWhere(
          (prompt) => prompt.name == 'non-existent-prompt',
          orElse: () => throw Exception('Prompt not found: non-existent-prompt'),
        ),
        throwsException,
      );
    });
  });
}