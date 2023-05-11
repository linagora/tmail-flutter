import 'package:core/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const String kApplicationDocumentsPath = 'applicationDocumentsPath';

void main() {
  const fileName = 'test_file';
  const fileContent = 'Hello, World!';

  group('fileUtils test', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
    });

    test('Store private HTLM String to File', () async {

      final file = await FileUtils().saveToFile(nameFile: fileName, content: fileContent);

      expect(await file.exists(), equals(true));

      expect(await file.readAsString(), equals(fileContent));

      file.delete();
    });

    test('Get HTML String from File Private', () async {

      /// Create a temporary file that will be deleted after `getFromFile` is done
      final file = await FileUtils().saveToFile(nameFile: fileName, content: fileContent);

      final htmlString = await FileUtils().getContentFromFile(nameFile: fileName);

      expect(htmlString.isNotEmpty, equals(true));

      expect(htmlString, equals(fileContent));

      file.delete();
    });
  });
}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }
}