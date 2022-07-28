
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressFileUtils {

  /// Maximum image size displayed
  static const int MAXIMUM_IMAGE_SIZE_KB = 300;
  /// Quality image 0 - 100
  static const int QUALITY_DEFAULT = 50;
  /// Max image width
  static const int MAX_IMAGE_WIDTH = 1000;

  bool _exceedMaximumImageSize(Uint8List bytesData) {
    final maximumSizeBytes = MAXIMUM_IMAGE_SIZE_KB * 1024;
    final sizeBytesData = bytesData.length;
    log('CompressFileUtils::exceedMaximumImageSize(): maximumSizeBytes: $maximumSizeBytes');
    log('CompressFileUtils::exceedMaximumImageSize(): sizeBytesData: $sizeBytesData');
    return sizeBytesData > maximumSizeBytes;
  }

  Future<Uint8List> compressBytesDataImage(Uint8List bytesData, {int? maxWidth}) async {
    if (_exceedMaximumImageSize(bytesData)) {
      log('CompressFileUtils::_compressImageData(): BEFORE_COMPRESS: bytesData: ${bytesData.lengthInBytes}');
      final bytesCompressed = await FlutterImageCompress.compressWithList(
          bytesData,
          quality: QUALITY_DEFAULT,
          minWidth: maxWidth ?? MAX_IMAGE_WIDTH);
      log('CompressFileUtils::_compressImageData(): AFTER_COMPRESS_MOBILE: bytesData: ${bytesCompressed.lengthInBytes}');
      return bytesCompressed;
    } else {
      return bytesData;
    }
  }
}