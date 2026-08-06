import 'package:core/utils/html/editor_script/quoted_reply_enter_handler_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const handler = QuotedReplyEnterHandlerScript();

  group('QuotedReplyEnterHandlerScript', () {
    test('has a stable command name', () {
      expect(handler.name, 'registerQuotedReplyEnterKeyHandler');
    });

    test('attaches only once to the editable root', () {
      expect(handler.script, contains('quotedReplyEnterHandlerAttached'));
      expect(
        handler.script,
        contains("root.dataset.quotedReplyEnterHandlerAttached = 'true'"),
      );
    });
  });
}
