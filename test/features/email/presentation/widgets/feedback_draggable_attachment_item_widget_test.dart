import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/feedback_draggable_attachment_item_widget.dart';

void main() {
  group('FeedbackDraggableAttachmentItemWidget test', () {
    setUp(() => Get.put(ImagePaths()));
    tearDown(Get.reset);

    Future<String> pumpLabel(WidgetTester tester, Attachment attachment) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FeedbackDraggableAttachmentItemWidget(attachment: attachment),
        ),
      ));
      return tester.widget<MiddleEllipsisText>(find.byType(MiddleEllipsisText)).text;
    }

    testWidgets('strips bidi overrides from the attachment name', (tester) async {
      final label = await pumpLabel(
        tester,
        Attachment(blobId: Id('blob-id'), name: 'invoice\u202Efdp.exe'),
      );

      expect(label, 'invoicefdp.exe');
    });

    testWidgets('falls back to the blobId when the name is null', (tester) async {
      final label = await pumpLabel(tester, Attachment(blobId: Id('blob-id')));

      expect(label, 'blob-id');
    });
  });
}
