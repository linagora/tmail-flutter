@TestOn('chrome')

import 'dart:async';
import 'dart:typed_data';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/download/download_client.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:universal_html/html.dart' as html;

import 'download_manager_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DownloadClient>(), MockSpec<DeviceInfoPlugin>()])
void main() {
  late DownloadManager downloadManager;

  setUp(() {
    downloadManager = DownloadManager(
      MockDownloadClient(),
      MockDeviceInfoPlugin(),
    );
  });

  group('DownloadManager::createAnchorElementDownloadFileWeb', () {
    test('tags the download Blob it actually creates as octet-stream, not empty, so Chrome does not sniff extension-less filenames', () async {
      final bytes = Uint8List.fromList('plain text content'.codeUnits);
      html.AnchorElement? clickedAnchor;
      final blobCompleter = Completer<html.Blob>();

      // Captured on the capture phase of the click event, which fires
      // synchronously inside anchor.click(). The method under test revokes
      // the blob: URL right after click() returns, so the request for the
      // blob's content must be *started* here, while the URL is still
      // valid; an in-flight request survives the later revoke() call.
      html.document.body?.addEventListener('click', (event) {
        clickedAnchor = event.target as html.AnchorElement;
        final xhr = html.HttpRequest();
        xhr.open('GET', clickedAnchor!.href!);
        xhr.responseType = 'blob';
        xhr.onLoad.listen((_) => blobCompleter.complete(xhr.response as html.Blob));
        xhr.onError.listen((event) => blobCompleter.completeError(event));
        xhr.send();
      }, true);

      downloadManager.createAnchorElementDownloadFileWeb(bytes, 'twake-configuration');

      expect(clickedAnchor, isNotNull);
      expect(clickedAnchor!.download, 'twake-configuration');

      final resolvedBlob = await blobCompleter.future;
      expect(resolvedBlob.type, Constant.octetStreamMimeType);
    });
  });
}
