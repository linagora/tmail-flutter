import 'package:core/utils/html/editor_script/list_keyboard_handler_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const handler = ListKeyboardHandlerScript();

  group('ListKeyboardHandlerScript', () {
    test('has a stable command name', () {
      expect(handler.name, 'registerListKeyboardHandler');
    });

    test('attaches only once to the editable root', () {
      expect(handler.script, contains('listKeyboardHandlerAttached'));
      expect(
        handler.script,
        contains("root.dataset.listKeyboardHandlerAttached = 'true'"),
      );
    });

    test('delegates nesting to the Summernote indent commands', () {
      expect(handler.script, contains("'outdent' : 'indent'"));
    });
  });
}
