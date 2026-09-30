@TestOn('chrome')
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/dropped_file_open_read.dart';
import 'package:web/web.dart' as web;

void main() {
  test('streams a dropped blob and can be opened twice', () async {
    final bytes = Uint8List.fromList(utf8.encode('hello drop'));
    final url = web.URL.createObjectURL(web.Blob(<JSAny>[bytes.toJS].toJS));
    addTearDown(() => web.URL.revokeObjectURL(url));

    final openRead = droppedFileOpenRead(XFile(url, name: 'note.txt'));

    expect(await utf8.decodeStream(openRead()), 'hello drop');
    expect(await utf8.decodeStream(openRead()), 'hello drop');
  });
}
