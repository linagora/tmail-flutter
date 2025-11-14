import 'package:core/utils/app_logger.dart';
import 'package:flutter_emoji_mart/flutter_emoji_mart.dart';
import 'package:html_editor_enhanced/utils/html_editor_constants.dart';
import 'package:html_editor_enhanced/utils/html_editor_utils.dart';

/// A singleton class responsible for preloading and caching assets
/// such as HTML editor files and emoji data.
class AssetManager {
  static final AssetManager _instance = AssetManager._internal();

  factory AssetManager() => _instance;

  AssetManager._internal();

  EmojiData? _emojiData;
  bool _isEmojiDataLoaded = false;

  Future<void> preloadAllAssets() async {
    await Future.wait([
      preloadHtmlEditorAssets(),
      loadEmojiData(),
    ]);
  }

  /// Loads all required HTML editor assets concurrently.
  Future<void> preloadHtmlEditorAssets() async {
    try {
      await Future.wait([
        HtmlEditorUtils.loadAsset(HtmlEditorConstants.summernoteHtmlAssetPath),
        HtmlEditorUtils.loadAsset(HtmlEditorConstants.jqueryAssetPath),
        HtmlEditorUtils.loadAsset(HtmlEditorConstants.summernoteCSSAssetPath),
        HtmlEditorUtils.loadAsset(HtmlEditorConstants.summernoteJSAssetPath),
        HtmlEditorUtils.loadAsset(HtmlEditorConstants.summernoteFontEOTAssetPath),
        HtmlEditorUtils.loadAsset(HtmlEditorConstants.summernoteFontTTFAssetPath),
      ]);
      log('AssetManager::preloadHtmlEditorAssets:✅ HtmlEditor assets preloaded successfully.');
    } catch (e, s) {
      logError('AssetManager::preloadHtmlEditorAssets: failed + $e, $s');
    }
  }

  /// Loads emoji data once and caches it in memory.
  /// If data has already been loaded, returns immediately.
  Future<void> loadEmojiData({double version = 13.5}) async {
    if (_isEmojiDataLoaded && _emojiData != null) {
      return;
    }

    try {
      final rawData = await EmojiData.builtIn();
      _emojiData = rawData.filterByVersion(version);
      _isEmojiDataLoaded = true;
      log('AssetManager::loadEmojiData:✅ EmojiData (v$version) loaded successfully.');
    } catch (e, s) {
      logError('AssetManager::loadEmojiData: failed + $e, $s');
    }
  }

  /// Returns the cached emoji data, or null if not yet loaded.
  EmojiData? get emojiData => _emojiData;
}