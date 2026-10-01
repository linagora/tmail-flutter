import 'package:core/data/network/download/download_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadClient.encodeToBase64Uri', () {
    test('attribute-escapes the file name and cid', () {
      final result = DownloadClient.encodeToBase64Uri({
        'bytesData': <int>[1, 2, 3],
        'mimeType': 'image/png',
        'cid': '"><script>alert(1)</script>',
        'fileName': '"><script>alert(1)</script>.png',
      });

      expect(result, isNot(contains('<script>')));
      expect(result, contains('alt="&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;"'));
      expect(result, contains('id="cid:&quot;&gt;&lt;script&gt;alert(1)&lt;/script&gt;"'));
    });
  });
}
