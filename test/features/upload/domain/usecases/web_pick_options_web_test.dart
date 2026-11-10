@TestOn('chrome')
library;

import 'dart:js_interop';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker_web/file_picker_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/web_pick_options.dart';
import 'package:web/web.dart' as web;

web.HTMLInputElement _pickerInput() {
  final input = web.document.querySelector(
    '#__file_picker_web-file-input input[type=file]',
  );
  expect(input, isNotNull, reason: 'the picker must keep its input attached');
  return input! as web.HTMLInputElement;
}

void _selectFiles(web.HTMLInputElement input, List<String> names) {
  final transfer = web.DataTransfer();
  for (final name in names) {
    transfer.items.add(web.File(['content'.toJS].toJS, name));
  }
  input.files = transfer.files;
}

void main() {
  setUpAll(() => FilePickerWeb.registerWith(webPluginRegistrar));

  test('web picks skip reading file bytes and read streams', () {
    final options = lazyWebPickOptions();

    expect(options, isA<FilePickerWebOptions>());
    final webOptions = options as FilePickerWebOptions;
    expect(webOptions.withData, isFalse);
    expect(webOptions.withReadStream, isFalse);
  });

  test('web picks do not treat window focus as a cancelled dialog', () {
    final webOptions = lazyWebPickOptions() as FilePickerWebOptions;

    expect(webOptions.cancelUploadOnWindowBlur, isFalse);
  });

  test(
    'keeps every file when change arrives more than 500 ms after window focus',
    () async {
      final pick = FilePicker.pickFiles(webOptions: lazyWebPickOptions());
      await Future<void>.delayed(Duration.zero);
      final input = _pickerInput();

      web.window.dispatchEvent(web.Event('focus'));
      await Future<void>.delayed(const Duration(milliseconds: 800));
      _selectFiles(input, ['a.txt', 'b.txt', 'c.txt']);
      input.dispatchEvent(web.Event('change'));

      final files = await pick;
      expect(files.map((file) => file.name), ['a.txt', 'b.txt', 'c.txt']);
    },
  );

  test('completes with no files when the dialog is cancelled', () async {
    final pick = FilePicker.pickFiles(webOptions: lazyWebPickOptions());
    await Future<void>.delayed(Duration.zero);
    final input = _pickerInput();

    input.dispatchEvent(web.Event('cancel'));

    expect(await pick, isEmpty);
  });
}
