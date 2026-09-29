import 'dart:typed_data';

import 'package:model/upload/file_info.dart';

/// `blob:` URLs exist only in a browser.
FileInfo createBlobFileInfo(Uint8List bytes, String fileName, String mimeType) =>
    throw UnsupportedError('createBlobFileInfo is web only');
