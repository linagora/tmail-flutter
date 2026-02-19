import 'dart:convert';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';
import 'package:flutter/services.dart' show rootBundle;

class PromptService {
  static PromptService? _instance;
  final DioClient _dioClient;
  
  factory PromptService({DioClient? dioClient}) {
    _instance ??= PromptService._internal(dioClient: dioClient);
    return _instance!;
  }
  
  PromptService._internal({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient(Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));
  
  PromptData? _promptData;
  String? _promptUrl;
  
  void setPromptUrl(String? url) {
    _promptUrl = url;
  }
  
  String? get promptUrl => _promptUrl;
  
  Future<PromptData> loadPrompts() async {
    // App in memory cache
    if (_promptData != null) {
      return _promptData!;
    }
    
    // First try: remote prompts
    if (_promptUrl != null) {
      try {
        _promptData = await _fetchPromptsFromUrl(_promptUrl!);
        return _promptData!;
      } catch (e) {
        log('PromptService::loadPrompts: failed to fetch from remote URL: $e');
      }
    }
    
    // Fallback: local prompts
    return _loadPromptsFromAssets();
  }
  
  Future<PromptData> _fetchPromptsFromUrl(String url) async {
    log('PromptService::_fetchPromptsFromUrl: Fetching from $url');
    
    try {
      final response = await _dioClient.get(url);
            
      if (response.statusCode == 200) {
        final jsonData = response.data;
        Map<String, dynamic> promptsMap;
        
        if (jsonData is String) {
          promptsMap = jsonDecode(jsonData) as Map<String, dynamic>;
        } else if (jsonData is Map<String, dynamic>) {
          promptsMap = jsonData;
        } else {
          throw Exception('Failed to fetch prompts: invalid response format');
        }
        
        log('PromptService::_fetchPromptsFromUrl: Successfully fetched prompts');
        return PromptData.fromJson(promptsMap);
      } else {
        throw Exception('Failed to fetch prompts: unexpected status code ${response.statusCode}');
      }
    } catch (e) {
      log('PromptService::_fetchPromptsFromUrl: Exception: $e');
      rethrow;
    }
  }
  
  Future<PromptData> _loadPromptsFromAssets() async {
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