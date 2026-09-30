import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every web editor that routes pasted HTML through
/// `execCommand('insertHTML')` (`normalizeHtmlTextWhenPasting: true`) runs in
/// a same-origin iframe, so it must also install the paste sanitizer script.
/// The composer installs it through its editor script plan, whose content is
/// pinned by web_editor_script_plan_test.dart.
void main() {
  test('every editor normalizing pasted HTML installs sanitizeInsertHtml', () {
    final editorsWithoutSanitizer = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
          final source = file.readAsStringSync();
          return source.contains('normalizeHtmlTextWhenPasting: true') &&
              !source.contains('sanitizeInsertHtml') &&
              !source.contains('editorScriptPlan.initialScripts');
        })
        .map((file) => file.path)
        .toList();

    expect(editorsWithoutSanitizer, isEmpty);
  });

  test('every editor normalizing pasted HTML disables summernote drag-and-drop', () {
    // summernote's dropzone inserts dropped HTML with pasteHTML, bypassing the insertHTML hook.
    final editorsWithDragAndDrop = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
          final source = file.readAsStringSync();
          return source.contains('normalizeHtmlTextWhenPasting: true') &&
              !source.contains('disableDragAndDrop: true');
        })
        .map((file) => file.path)
        .toList();

    expect(editorsWithDragAndDrop, isEmpty);
  });
}
