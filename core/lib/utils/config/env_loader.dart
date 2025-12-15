import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  const EnvLoader._();

  static const String envFileName = 'env.file';
  static const String appFCMConfigurationPath = "configurations/env.fcm";

  static Future<void> loadEnvFile() async {
    await loadConfigFromEnv();
    final mapEnvData = Map<String, String>.from(dotenv.env);
    await loadFcmConfigFileToEnv(
      currentMapEnvData: mapEnvData,
      onCallBack: () async {
        await loadConfigFromEnv();
      },
    );
  }

  static Future<void> loadFcmConfigFileToEnv({
    Map<String, String>? currentMapEnvData,
    VoidCallback? onCallBack,
  }) async {
    try {
      await dotenv.load(
        fileName: appFCMConfigurationPath,
        mergeWith: currentMapEnvData ?? {},
      );
    } catch (e) {
      logWarning('EnvLoader::loadFcmConfigFileToEnv: Exception = $e');
      onCallBack?.call();
    }
  }

  static Future<void> loadConfigFromEnv() async {
    try {
      await dotenv.load(fileName: envFileName);
    } catch (e) {
      logWarning('EnvLoader::loadConfigFromEnv:Exception = $e');
    }
  }
}
