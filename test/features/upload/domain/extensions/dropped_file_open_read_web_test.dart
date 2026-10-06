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

  test('a readable or empty blob is readable', () async {
    final filled = web.URL.createObjectURL(web.Blob(<JSAny>[Uint8List.fromList(utf8.encode('abc')).toJS].toJS));
    final empty = web.URL.createObjectURL(web.Blob(<JSAny>[].toJS));
    addTearDown(() {
      web.URL.revokeObjectURL(filled);
      web.URL.revokeObjectURL(empty);
    });

    expect(await droppedFileIsReadable(XFile(filled, name: 'b')), isTrue);
    expect(await droppedFileIsReadable(XFile(empty, name: 'LICENSE')), isTrue);
  });

  test('an unreadable blob url, as a dropped folder gives, is not readable', () async {
    final url = web.URL.createObjectURL(web.Blob(<JSAny>[].toJS));
    web.URL.revokeObjectURL(url);

    expect(await droppedFileIsReadable(XFile(url, name: 'docs')), isFalse);
  });
}
