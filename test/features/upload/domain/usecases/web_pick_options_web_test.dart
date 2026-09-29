@TestOn('chrome')

import 'package:file_picker_web/file_picker_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/web_pick_options.dart';

void main() {
  test('web picks skip reading file bytes and read streams', () {
    final options = lazyWebPickOptions();

    expect(options, isA<FilePickerWebOptions>());
    final webOptions = options as FilePickerWebOptions;
    expect(webOptions.withData, isFalse);
    expect(webOptions.withReadStream, isFalse);
  });
}
