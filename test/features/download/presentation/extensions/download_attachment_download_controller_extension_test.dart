import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/download_attachment_download_controller_extension.dart';

import '../../../../fixtures/widget_fixtures.dart';
import 'download_attachment_download_controller_extension_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DownloadController>()])
void main() {
  group('DownloadAttachmentDownloadControllerExtension::exportAttachment test', () {
    tearDown(Get.reset);

    testWidgets('shows the attachment name without bidi overrides in the downloading dialog', (tester) async {
      await tester.pumpWidget(WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()));
      await tester.pump();

      MockDownloadController().exportAttachment(
        attachment: Attachment(blobId: Id('blob-id'), name: 'invoice\u202Efdp.exe'),
        accountId: null,
        session: null,
      );
      await tester.pump();

      expect(find.text('Downloading invoicefdp.exe'), findsOneWidget);
    });
  });
}
