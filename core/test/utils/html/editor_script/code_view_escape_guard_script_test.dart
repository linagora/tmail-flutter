import 'package:core/utils/html/editor_script/code_view_escape_guard_script.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const guard = CodeViewEscapeGuardScript();

  group('CodeViewEscapeGuardScript', () {
    test('has a stable command name', () {
      expect(guard.name, 'registerCodeViewEscapeGuard');
    });

    test('attaches only once to the document', () {
      expect(guard.script, contains('codeViewEscapeGuardAttached'));
      expect(
        guard.script,
        contains("root.dataset.codeViewEscapeGuardAttached = 'true'"),
      );
    });
  });
}
