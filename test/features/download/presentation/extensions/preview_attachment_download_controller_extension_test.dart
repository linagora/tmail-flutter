import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/print_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/download/presentation/controllers/download_controller.dart';
import 'package:tmail_ui_user/features/download/presentation/extensions/preview_attachment_download_controller_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:twake_previewer_flutter/twake_pdf_previewer/twake_pdf_previewer.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import '../../../../fixtures/widget_fixtures.dart';
import 'preview_attachment_download_controller_extension_test.mocks.dart';

class _PendingDeviceInfoPlugin extends DeviceInfoPlugin {
  @override
  Future<BaseDeviceInfo> get deviceInfo => Future.any([]);
}

@GenerateNiceMocks([
  MockSpec<DownloadController>(),
  MockSpec<DynamicUrlInterceptors>(),
])
void main() {
  group('PreviewAttachmentDownloadControllerExtension::previewAttachment', () {
    late MockDownloadController downloadController;

    setUp(() {
      PlatformInfo.isTestingForWeb = true;
      Get.put<DeviceInfoPlugin>(_PendingDeviceInfoPlugin());
      downloadController = MockDownloadController();
      when(downloadController.imagePaths).thenReturn(ImagePaths());
      when(downloadController.printUtils).thenReturn(PrintUtils());
      when(downloadController.dynamicUrlInterceptors)
          .thenReturn(MockDynamicUrlInterceptors());
    });

    tearDown(() {
      PlatformInfo.isTestingForWeb = false;
      Get.reset();
    });

    testWidgets(
      'Should push an open composer action with the link\n'
      'When a mailto link is tapped in the PDF viewer',
    (tester) async {
      await tester.pumpWidget(
        WidgetFixtures.makeTestableWidget(child: const SizedBox.shrink()),
      );
      await tester.pumpAndSettle();

      downloadController.previewAttachment(
        context: tester.element(find.byType(SizedBox)),
        attachment: Attachment(
          blobId: Id('blobId'),
          name: 'file.pdf',
          type: MediaType('application', 'pdf'),
        ),
        accountId: AccountFixtures.aliceAccountId,
        session: SessionFixtures.aliceSession,
        ownEmailAddress: 'alice@example.com',
        onPreviewOrDownloadAction: (_, __) {},
      );
      await tester.pump();

      final mailtoUri = Uri.parse('mailto:bob@example.com');
      tester
          .widget<TwakePdfPreviewer>(find.byType(TwakePdfPreviewer))
          .onLinkTap!(mailtoUri);
      await tester.pump(const Duration(seconds: 1));

      verify(downloadController.pushDownloadUIAction(argThat(
        isA<OpenComposerFromMailtoLinkAction>()
            .having((action) => action.uri, 'uri', mailtoUri),
      ))).called(1);
    });
  });
}
