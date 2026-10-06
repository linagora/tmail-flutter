@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/x_file_extension.dart';
import 'package:web/web.dart' as web;

const _mb = 1024 * 1024;
const _droppedSizeMb = 256;

/// Upper bound for heap growth while a 256 MB drop is mapped. A full read
/// would add ~256 MB; GC can only shrink the measured delta, never inflate it.
const _maxHeapGrowthMb = 32;

int _usedHeapMb() =>
    (((globalContext['performance'] as JSObject)['memory'] as JSObject)
                ['usedJSHeapSize'] as JSNumber)
            .toDartInt ~/
        _mb;

/// A 256 MB blob built from one 1 MB chunk repeated, so creating the test
/// input costs ~1 MB of page heap instead of 256 MB.
String _bigBlobUrl() {
  final chunk = Uint8List(_mb).toJS;
  final url = web.URL.createObjectURL(
    web.Blob(<JSAny>[for (var i = 0; i < _droppedSizeMb; i++) chunk].toJS),
  );
  addTearDown(() => web.URL.revokeObjectURL(url));
  return url;
}

void main() {
  test('mapping a 256 MB dropped file keeps the page heap flat', () async {
    final url = _bigBlobUrl();
    final xFile = XFile(url, name: 'big.bin', length: _droppedSizeMb * _mb);
    final heapBefore = _usedHeapMb();

    // Everything a drop does before upload: folder probe, then mapping.
    final isFolder = await xFile.isDroppedFolder();
    final fileInfo = await xFile.toFileInfo();

    final heapGrowth = _usedHeapMb() - heapBefore;
    expect(isFolder, isFalse);
    expect(fileInfo, isA<FileBlobInfo>());
    expect(fileInfo.fileSize, _droppedSizeMb * _mb);
    expect(
      heapGrowth,
      lessThan(_maxHeapGrowthMb),
      reason: 'heap grew $heapGrowth MB for a $_droppedSizeMb MB drop: the file was read into memory',
    );
  });
}
