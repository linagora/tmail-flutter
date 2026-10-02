import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_item_composer_widget.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

void main() {
  group('AttachmentItemComposerWidget test', () {
    testWidgets('shows the attachment name without bidi overrides', (tester) async {
      final imagePaths = ImagePaths();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AttachmentItemComposerWidget(
            imagePaths: imagePaths,
            fileIcon: imagePaths.icCancel,
            fileName: 'invoice\u202Efdp.exe',
            fileSize: '1 KB',
            uploadStatus: UploadFileStatus.succeed,
            percentUploading: 1,
            uploadTaskId: const UploadTaskId('id'),
          ),
        ),
      ));

      final label = tester.widget<MiddleEllipsisText>(find.byType(MiddleEllipsisText));
      expect(label.text, 'invoicefdp.exe');
    });
  });
}
