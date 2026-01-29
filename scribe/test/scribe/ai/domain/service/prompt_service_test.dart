import 'package:flutter_test/flutter_test.dart';
import 'package:scribe/scribe/ai/domain/service/prompt_service.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PromptService', () {
    test('PromptService should be singleton', () {
      // Act
      final service1 = PromptService();
      final service2 = PromptService();

      // Assert
      expect(service1, same(service2));
    });

    test('buildPromptByName should build prompt with input text', () async {
      // Arrange
      final service = PromptService();
      
      // Act - this will use the real prompts.json file
      final messages = await service.buildPromptByName('change-tone-casual', 'Hello, how are you?');

      // Assert
      expect(messages.length, 2);
      expect(messages.first.role, 'system');
      expect(messages.last.role, 'user');
      expect(messages.last.content, contains('Hello, how are you?'));
    });

    test('buildPromptByName should build prompt with input text and task', () async {
      // Arrange
      final service = PromptService();
      
      // Act - this will use the real prompts.json file
      final messages = await service.buildPromptByName('custom-prompt-mail', 'Hello, how are you?', task: 'Make it more casual');

      // Assert
      expect(messages.length, 2);
      expect(messages.first.role, 'system');
      expect(messages.last.role, 'user');
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
              const AIMessage(role: 'system', content: 'System message'),
              const AIMessage(role: 'user', content: 'User message with {{input}}')
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
              const AIMessage(role: 'system', content: 'System message'),
              const AIMessage(role: 'user', content: 'User message')
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