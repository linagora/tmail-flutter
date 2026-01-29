import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';

class PromptService {
  static final PromptService _instance = PromptService._internal();
  
  factory PromptService() => _instance;
  
  PromptService._internal();
  
  PromptData? _promptData;
  
  Future<PromptData> loadPrompts() async {
    if (_promptData != null) {
      return _promptData!;
    }
    
    try {
      final jsonString = await rootBundle.loadString('packages/scribe/assets/prompts.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      _promptData = PromptData.fromJson(jsonData);
      return _promptData!;
    } catch (e) {
      throw Exception('Failed to load prompts: $e');
    }
  }
  
  Future<Prompt> getPromptByName(String name) async {
    final promptData = await loadPrompts();
    return promptData.prompts.firstWhere(
      (prompt) => prompt.name == name,
      orElse: () => throw Exception('Prompt not found: $name'),
    );
  }
  
  Future<List<AIMessage>> buildPromptByName(String name, String inputText, {String? task}) async {
    final prompt = await getPromptByName(name);
    return prompt.buildPrompt(inputText, task: task);
  }
}