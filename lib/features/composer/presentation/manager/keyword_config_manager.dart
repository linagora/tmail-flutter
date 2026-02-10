import 'package:core/utils/app_logger.dart';
import 'package:core/utils/config/app_config_loader.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/attachment_keywords_configuration_parser.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/keyword_config.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class KeywordConfigManager {
  static final KeywordConfigManager _instance = KeywordConfigManager._();

  factory KeywordConfigManager() => _instance;

  KeywordConfigManager._();

  KeywordConfig? _cachedConfig;
  AppConfigLoader? _appConfigLoader;

  static const String _configPath =
      AppConfig.attachmentKeywordsConfigurationPath;

  Future<KeywordConfig> getConfig() async {
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    try {
      _appConfigLoader ??= AppConfigLoader();
      _cachedConfig = await _appConfigLoader?.load<KeywordConfig>(
        _configPath,
        AttachmentKeywordsConfigurationParser(),
      );
    } catch (e) {
      logWarning(
          "KeywordConfigManager::getConfig:Error loading keyword config: $e");
      _cachedConfig = const KeywordConfig();
    }

    return _cachedConfig!;
  }

  void clearCache() {
    _cachedConfig = null;
  }
}
