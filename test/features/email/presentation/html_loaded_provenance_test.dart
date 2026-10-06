import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  bool hasSanitizer(TransformConfiguration config) => config.textTransformers
      .any((transformer) => transformer is StandardizeHtmlSanitizingTransformers);

  test('EmailLoaded producer configs always sanitize', () {
    PlatformInfo.isTestingForWeb = false;
    expect(
      hasSanitizer(TransformConfiguration.forPreviewEmailOnPlatform()),
      isTrue,
    );

    PlatformInfo.isTestingForWeb = true;
    expect(
      hasSanitizer(TransformConfiguration.forPreviewEmailOnPlatform()),
      isTrue,
    );
  });

  test('print config does not sanitize already-loaded EmailLoaded HTML', () {
    expect(
      hasSanitizer(TransformConfiguration.forPrintEmail()),
      isFalse,
    );
  });

  test('iOS email view height cap stays at 22000', () {
    expect(ConstantsUI.htmlContentMaxHeight, 22000.0);
  });
}
