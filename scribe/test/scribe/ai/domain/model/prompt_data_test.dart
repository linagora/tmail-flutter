import 'package:flutter_test/flutter_test.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';

void main() {
  group('PromptData', () {
    test('fromJson should parse prompts correctly', () {
      // Arrange
      final jsonData = {
        "prompts": [
          {
            "name": "test-prompt-1",
            "messages": [
              {
                "role": "system",
                "content": "System message 1"
              },
              {
                "role": "user",
                "content": "User message 1"
              }
            ]
          },
          {
            "name": "test-prompt-2",
            "messages": [
              {
                "role": "system",
                "content": "System message 2"
              },
              {
                "role": "user",
                "content": "User message 2"
              }
            ]
          }
        ]
      };

      // Act
      final promptData = PromptData.fromJson(jsonData);

      // Assert
      expect(promptData.prompts.length, 2);
      expect(promptData.prompts.first.name, 'test-prompt-1');
      expect(promptData.prompts.last.name, 'test-prompt-2');
      expect(promptData.prompts.first.messages.length, 2);
      expect(promptData.prompts.last.messages.length, 2);
    });

    test('fromJson should handle empty prompts list', () {
      // Arrange
      final jsonData = {
        "prompts": []
      };

      // Act
      final promptData = PromptData.fromJson(jsonData);

      // Assert
      expect(promptData.prompts.length, 0);
    });
  });

  group('Prompt', () {
    test('fromJson should parse prompt correctly', () {
      // Arrange
      final jsonData = {
        "name": "test-prompt",
        "messages": [
          {
            "role": "system",
            "content": "System message"
          },
          {
            "role": "user",
            "content": "User message with {{input}} placeholder"
          }
        ]
      };

      // Act
      final prompt = Prompt.fromJson(jsonData);

      // Assert
      expect(prompt.name, 'test-prompt');
      expect(prompt.messages.length, 2);
      expect(prompt.messages.first.role, AIRole.system);
      expect(prompt.messages.first.content, 'System message');
      expect(prompt.messages.last.role, AIRole.user);
      expect(prompt.messages.last.content, 'User message with {{input}} placeholder');
    });

    test('buildPrompt should replace input placeholder correctly', () {
      // Arrange
      final messages = [
        const AIMessage(role: AIRole.system, content: 'System message'),
        const AIMessage(role: AIRole.user, content: 'User message with {{input}} placeholder')
      ];
      final prompt = Prompt(name: 'test-prompt', messages: messages);

      // Act
      final result = prompt.buildPrompt('test input value');

      // Assert
      expect(result.length, 2);
      expect(result.first.role, AIRole.system);
      expect(result.first.content, 'System message');
      expect(result.last.role, AIRole.user);
      expect(result.last.content, 'User message with test input value placeholder');
    });

    test('buildPrompt should replace task placeholder when provided', () {
      // Arrange
      final messages = [
        const AIMessage(role: AIRole.system, content: 'System message'),
        const AIMessage(role: AIRole.user, content: 'Task: {{task}}, Input: {{input}}')
      ];
      final prompt = Prompt(name: 'test-prompt', messages: messages);

      // Act
      final result = prompt.buildPrompt('test input value', task: 'test task value');

      // Assert
      expect(result.length, 2);
      expect(result.first.role, AIRole.system);
      expect(result.first.content, 'System message');
      expect(result.last.role, AIRole.user);
      expect(result.last.content, 'Task: test task value, Input: test input value');
    });

    test('buildPrompt should not replace task placeholder when not provided', () {
      // Arrange
      final messages = [
        const AIMessage(role: AIRole.system, content: 'System message'),
        const AIMessage(role: AIRole.user, content: 'Task: {{task}}, Input: {{input}}')
      ];
      final prompt = Prompt(name: 'test-prompt', messages: messages);

      // Act
      final result = prompt.buildPrompt('test input value');

      // Assert
      expect(result.length, 2);
      expect(result.first.role, AIRole.system);
      expect(result.first.content, 'System message');
      expect(result.last.role, AIRole.user);
      expect(result.last.content, 'Task: {{task}}, Input: test input value');
    });

    test('buildPrompt should handle messages without placeholders', () {
      // Arrange
      final messages = [
        const AIMessage(role: AIRole.system, content: 'System message'),
        const AIMessage(role: AIRole.user, content: 'User message without placeholders')
      ];
      final prompt = Prompt(name: 'test-prompt', messages: messages);

      // Act
      final result = prompt.buildPrompt('test input', task: 'test task');

      // Assert
      expect(result.length, 2);
      expect(result.last.content, 'User message without placeholders');
    });
  });
}