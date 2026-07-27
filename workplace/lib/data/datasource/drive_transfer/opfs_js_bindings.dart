import 'package:workplace/data/datasource/drive_transfer/opfs_feature_detection.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_fetch_streaming.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_xhr_upload.dart';

/// Every `dart:js_interop`/`package:web` call the drive transfer makes, split
/// by leg across four mixins and composed here. Stager and uploader code never
/// touches JS interop, and tests substitute a fake through [setInstance] — the
/// swap-the-singleton seam `WorkplaceDio.setInstance` already uses here.
class OpfsJsBindings
    with OpfsFeatureDetection, OpfsFileOps, OpfsFetchStreaming, OpfsXhrUpload {
  static OpfsJsBindings _instance = OpfsJsBindings();

  static void setInstance(OpfsJsBindings bindings) => _instance = bindings;

  static OpfsJsBindings get instance => _instance;
}
