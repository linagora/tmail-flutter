import 'dart:async';
import 'dart:convert';
import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:scribe/scribe/ai/domain/model/ai_message.dart';
import 'package:scribe/scribe/ai/domain/model/prompt_data.dart';
import 'package:flutter/services.dart' show rootBundle;

class PromptService {
  static const String _defaultAssetPath = 'packages/scribe/assets/prompts.json';

  final Dio _dio;

  String? _promptUrl;
  PromptData? _promptData;
  Future<PromptData>? _loadingFuture;

  PromptService(this._dio);

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
      PromptData? remotePromptData;
      try {
        remotePromptData = await _fetchPromptsFromUrl(_promptUrl!);
      } catch (e) {
        log('PromptService::loadPrompts: failed to fetch from remote URL: $e');
      }
      if (remotePromptData != null) {
        _promptData = await _withBundledFallback(remotePromptData);
        return _promptData!;
      }
    }

    _promptData = await _loadPromptsFromAssets();
    return _promptData!;
  }

  // Remote prompts override bundled ones by name; bundled prompts stand in
  // for the names the remote catalog lacks.
  Future<PromptData> _withBundledFallback(PromptData remotePromptData) async {
    final PromptData bundledPromptData;
    try {
      bundledPromptData = await _loadPromptsFromAssets();
    } catch (e) {
      log('PromptService::_withBundledFallback: failed to load local prompts: $e');
      return remotePromptData;
    }

    final remoteNames = remotePromptData.prompts.map((p) => p.name).toSet();
    return PromptData(
      prompts: [
        ...remotePromptData.prompts,
        ...bundledPromptData.prompts.where((p) => !remoteNames.contains(p.name)),
      ],
    );
  }

  Future<PromptData> _fetchPromptsFromUrl(String url) async {
    final sanitizedUrl =
        Uri.tryParse(url)?.replace(queryParameters: {}).toString() ?? url;
    log('PromptService::_fetchPromptsFromUrl: Fetching from $sanitizedUrl');
    try {
      final response = await _dio.get(url);
      final data = response.data;

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
    final prompt = promptData.prompts.where((p) => p.name == name).firstOrNull;
    if (prompt == null) {
      throw Exception('Prompt not found: $name');
    }
    return prompt;
  }

  Future<List<AIMessage>> buildPromptByName(String name, String inputText, {String? task}) async {
    final prompt = await getPromptByName(name);
    return prompt.buildPrompt(inputText, task: task);
  }
}