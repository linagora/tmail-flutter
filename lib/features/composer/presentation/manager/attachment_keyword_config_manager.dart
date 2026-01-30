import 'package:core/utils/app_logger.dart';
import 'package:core/utils/config/app_config_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_keywords_configuration_parser.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_text_detector.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/attachment_keyword_config.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class AttachmentKeywordConfigManager {
  static final AttachmentKeywordConfigManager _instance = AttachmentKeywordConfigManager._();

  factory AttachmentKeywordConfigManager() => _instance;

  AttachmentKeywordConfigManager._();

  AttachmentKeywordConfig? _cachedConfig;
  AppConfigLoader? _appConfigLoader;

  static const String _configPath =
      AppConfig.attachmentKeywordsConfigurationPath;

  @visibleForTesting
  void injectLoader(AppConfigLoader loader) {
    _appConfigLoader = loader;
  }

  Future<AttachmentKeywordConfig> getConfig() async {
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    try {
      _appConfigLoader ??= AppConfigLoader();
      _cachedConfig = await _appConfigLoader?.load<AttachmentKeywordConfig>(
        _configPath,
        AttachmentKeywordsConfigurationParser(),
      );
    } catch (e) {
      logWarning(
          "AttachmentKeywordConfigManager::getConfig:Error loading keyword config: $e");
      _cachedConfig = AttachmentKeywordConfig();
    }

    return _cachedConfig!;
  }

  void clearCache() {
    _cachedConfig = null;
    _appConfigLoader = null;
    AttachmentTextDetector.clearPatternCache();
  }
}
