@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/dropped_file_open_read.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/x_file_extension.dart';
import 'package:web/web.dart' as web;

/// Wraps `window.fetch` so every `blob:` response body is a counting stream
/// with `highWaterMark: 0`: no byte is pulled unless the caller really reads.
/// That makes "the drop never reads the file" a deterministic assertion,
/// instead of a memory measurement that GC and rendering make flaky.
void _installBlobReadAccounting() {
  globalContext.callMethod('eval'.toJS, r'''
    (() => {
      if (window.__realFetch) return;
      window.__realFetch = window.fetch.bind(window);
      window.__blobReads = { fetched: 0, pulledBytes: 0, cancelled: 0 };
      window.fetch = async (url, ...rest) => {
        const res = await window.__realFetch(url, ...rest);
        if (!String(url).startsWith('blob:')) return res;
        window.__blobReads.fetched++;
        const source = res.body.getReader();
        const counted = new ReadableStream({
          async pull(controller) {
            const { done, value } = await source.read();
            if (done) return controller.close();
            window.__blobReads.pulledBytes += value.byteLength;
            controller.enqueue(value);
          },
          cancel(reason) {
            window.__blobReads.cancelled++;
            return source.cancel(reason);
          },
        }, { highWaterMark: 0 });
        return new Response(counted, { status: res.status, headers: res.headers });
      };
    })()
  '''.toJS);
}

void _resetBlobReads() => globalContext.callMethod('eval'.toJS,
    'window.__blobReads = { fetched: 0, pulledBytes: 0, cancelled: 0 }'.toJS);

int _blobReads(String key) =>
    ((globalContext['__blobReads'] as JSObject)[key] as JSNumber).toDartInt;

String _blobUrlOf(int sizeInBytes) {
  final url = web.URL.createObjectURL(
    web.Blob(<JSAny>[Uint8List(sizeInBytes).toJS].toJS),
  );
  addTearDown(() => web.URL.revokeObjectURL(url));
  return url;
}

void main() {
  setUpAll(_installBlobReadAccounting);
  setUp(_resetBlobReads);

  group('dropped big file is never read up front', () {
    test('folder probe opens the blob but pulls 0 bytes and cancels it', () async {
      final url = _blobUrlOf(32 * 1024 * 1024);

      final readable = await droppedFileIsReadable(XFile(url, name: 'big.bin'));

      expect(readable, isTrue);
      expect(_blobReads('fetched'), 1);
      expect(_blobReads('pulledBytes'), 0, reason: 'probe must not read file content');
      expect(_blobReads('cancelled'), 1, reason: 'probe must release the body');
    });

    test('toFileInfo takes the size from the drop and touches no bytes', () async {
      // A tiny blob that claims 1 GB: if the size came from a read, it would be 1 byte.
      const claimedSize = 1024 * 1024 * 1024;
      final url = _blobUrlOf(1);

      final fileInfo = await XFile(url, name: 'big.bin', length: claimedSize).toFileInfo();

      expect(fileInfo, isA<FileBlobInfo>());
      expect(fileInfo.fileSize, claimedSize);
      expect((fileInfo as FileBlobInfo).sourceUrl, url);
      expect(_blobReads('fetched'), 0, reason: 'mapping a drop must not open the blob');
    });

    test('isDroppedFolder on a big file reads no content', () async {
      final url = _blobUrlOf(32 * 1024 * 1024);

      final isFolder = await XFile(url, name: 'big.bin').isDroppedFolder();

      expect(isFolder, isFalse);
      expect(_blobReads('pulledBytes'), 0);
    });

    test('a 0-byte untyped file is kept, not mistaken for a folder', () async {
      final url = _blobUrlOf(0);

      expect(await XFile(url, name: 'LICENSE', mimeType: '').isDroppedFolder(), isFalse);
    });
  });
}
