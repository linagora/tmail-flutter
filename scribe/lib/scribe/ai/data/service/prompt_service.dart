import 'dart:async';
import 'dart:convert';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';
import 'package:flutter/services.dart' show rootBundle;

class PromptService {
  static const String _defaultAssetPath = 'packages/scribe/assets/prompts.json';
  
  final DioClient _dioClient;
  
  String? _promptUrl;
  PromptData? _promptData;
  Future<PromptData>? _loadingFuture;
  
  PromptService(this._dioClient);

  void setPromptUrl(String? url) {
    if (_promptUrl == url) return;
    _promptUrl = url;
    _promptData = null;
    _loadingFuture = null;
  }

  String? get promptUrl => _promptUrl;

  // Prevents multiple API calls if the previous request hasn't finished
  Future<PromptData> loadPrompts() {
    if (_promptData != null) {
      return Future.value(_promptData!);
    }
    
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _fetchAndCachePrompts().whenComplete(() {
      _loadingFuture = null; 
    });

    return _loadingFuture!;
  }

  // Prioritize loading from remote or fallback to load local assets
  Future<PromptData> _fetchAndCachePrompts() async {
    if (_promptUrl != null) {
      try {
        _promptData = await _fetchPromptsFromUrl(_promptUrl!);
        return _promptData!;
      } catch (e) {
        log('PromptService::loadPrompts: failed to fetch from remote URL: $e');
      }
    }
    
    _promptData = await _loadPromptsFromAssets();
    return _promptData!;
  }

  Future<PromptData> _fetchPromptsFromUrl(String url) async {
    log('PromptService::_fetchPromptsFromUrl: Fetching from $url');
    
    try {
      final data = await _dioClient.get(url);
      
      final promptsMap = data is String 
          ? jsonDecode(data) as Map<String, dynamic> 
          : data as Map<String, dynamic>;
      
      return PromptData.fromJson(promptsMap);
    } catch (e) {
      throw Exception('Failed to fetch prompts: $e');
    }
  }

  Future<PromptData> _loadPromptsFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(_defaultAssetPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return PromptData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load local prompts: $e');
    }
  }

  Future<Prompt> getPromptByName(String name) async {
    final promptData = await loadPrompts();
    try {
      return promptData.prompts.firstWhere((prompt) => prompt.name == name);
    } catch (_) {
      throw Exception('Prompt not found: $name');
    }
  }

  Future<List<AIMessage>> buildPromptByName(String name, String inputText, {String? task}) async {
    final prompt = await getPromptByName(name);
    return prompt.buildPrompt(inputText, task: task);
  }
}