
import 'package:core/utils/app_logger.dart';
import 'package:html_editor_enhanced/utils/html_editor_constants.dart';
import 'package:html_editor_enhanced/utils/html_editor_utils.dart';

class AssetPreloader {
  static AssetPreloader? _instance;

  AssetPreloader._();

  factory AssetPreloader() => _instance ??= AssetPreloader._();

  Future<void> preloadHtmlEditorAssets() async {
    try {
      await Future.wait([
        HtmlEditorUtils().loadAsset(HtmlEditorConstants.summernoteHtmlAssetPath),
        HtmlEditorUtils().loadAsset(HtmlEditorConstants.jqueryAssetPath),
        HtmlEditorUtils().loadAsset(HtmlEditorConstants.summernoteCSSAssetPath),
        HtmlEditorUtils().loadAsset(HtmlEditorConstants.summernoteJSAssetPath),
        HtmlEditorUtils().loadAsset(HtmlEditorConstants.summernoteFontEOTAssetPath),
        HtmlEditorUtils().loadAsset(HtmlEditorConstants.summernoteFontTTFAssetPath),
      ]);
    } catch (e) {
      logError('AssetPreloader::preloadHtmlEditorAssets:Exception = $e');
    }
  }
}