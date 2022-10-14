import 'package:core/utils/config/app_config_parser.dart';
import 'package:core/utils/config/errors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppConfigLoader {
  Future<T> load<T>(String fileName, AppConfigParser parser) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      var envString = await rootBundle.loadString(fileName);
      if (envString.isEmpty) {
        throw EmptyConfiguration();
      }

      return await parser.parse(envString);
    } on FlutterError {
      throw ConfigurationNotFoundError();
    }
  }

  Future<T> loadData<T>(String fileName, AppConfigParser parser) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      var envData = await rootBundle.load(fileName);
      if (envData.lengthInBytes == 0) {
        throw EmptyConfiguration();
      }

      return await parser.parseData(envData);
    } on FlutterError {
      throw ConfigurationNotFoundError();
    }
  }
}