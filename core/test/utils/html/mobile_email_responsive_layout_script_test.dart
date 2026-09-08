import 'package:core/utils/html/mobile_email_responsive_layout_script.dart';
import 'package:flutter_test/flutter_test.dart';

const _contentSizeChangedEventJSChannelName = 'MobileEmailContentSizeChanged';

void main() {
  group('MobileEmailResponsiveLayoutScript', () {
    test('wraps the layout policy in an executable script tag', () {
      final script = MobileEmailResponsiveLayoutScript.generate(
        contentSizeChangedEventJSChannelName:
            _contentSizeChangedEventJSChannelName,
      );

      expect(script, contains('<script type="text/javascript">'));
      expect(script, contains('</script>'));
    });

    test('binds the size-change callback to the registered channel', () {
      final script = MobileEmailResponsiveLayoutScript.generate(
        contentSizeChangedEventJSChannelName:
            _contentSizeChangedEventJSChannelName,
      );

      expect(
        script,
        contains("callHandler('$_contentSizeChangedEventJSChannelName'"),
      );
      expect(script, isNot(contains('__TMAIL_CONTENT_SIZE_CHANNEL__')));
    });
  });
}
