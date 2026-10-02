import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/middle_ellipsis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_item_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/draggable_recipient_tag_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_collapsed_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_tag_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/feedback_draggable_attachment_item_widget.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import 'middle_ellipsis_text_call_site_configuration_test.mocks.dart';

/// TF-4878 made attachment chips keep the file extension when their name is
/// truncated, through an opt-in flag on the shared `MiddleEllipsisText`.
/// A dropped flag still compiles and only shows up as a cut extension, so these
/// tests pin which chips opt in. Recipient chips must not: an address such as
/// `john.doe@example.com` would otherwise reserve `.com` at the end.
@GenerateNiceMocks([
  MockSpec<SingleEmailController>(),
])
void main() {
  const fileName = 'quarterly-report-with-a-very-long-name.pdf';
  final emailAddress = EmailAddress(null, 'john.doe@example.com');
  final imagePaths = ImagePaths();

  setUp(() {
    Get.testMode = true;
    Get.put(imagePaths);
    Get.put(ResponsiveUtils());
  });

  tearDown(Get.reset);

  Future<MiddleEllipsisText> pumpAndFindLabel(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);

    final labels = find.byType(MiddleEllipsisText);
    expect(labels, findsOneWidget);

    return tester.widget<MiddleEllipsisText>(labels);
  }

  group('attachment chips', () {
    testWidgets(
      'AttachmentItemComposerWidget should preserve the file extension',
      (tester) async {
        final label = await pumpAndFindLabel(
          tester,
          AttachmentItemComposerWidget(
            imagePaths: imagePaths,
            fileIcon: imagePaths.icFilePdf,
            fileName: fileName,
            fileSize: '1 KB',
            uploadStatus: UploadFileStatus.succeed,
            percentUploading: 1,
            uploadTaskId: const UploadTaskId('1'),
          ),
        );

        expect(label.text, fileName);
        expect(label.preserveFileExtension, isTrue);
      },
    );

    testWidgets(
      'AttachmentItemWidget should preserve the file extension',
      (tester) async {
        final controller = MockSingleEmailController();
        when(controller.onStart)
            .thenReturn(InternalFinalCallback<void>(callback: () {}));
        when(controller.attachmentsViewState).thenReturn(RxMap());
        Get.put<SingleEmailController>(controller);

        final label = await pumpAndFindLabel(
          tester,
          AttachmentItemWidget(
            attachment: Attachment(
              blobId: Id('1'),
              name: fileName,
              size: UnsignedInt(1024),
            ),
            imagePaths: imagePaths,
            width: 250,
          ),
        );

        expect(label.text, fileName);
        expect(label.preserveFileExtension, isTrue);
      },
    );

    testWidgets(
      'FeedbackDraggableAttachmentItemWidget should preserve the file extension',
      (tester) async {
        final label = await pumpAndFindLabel(
          tester,
          FeedbackDraggableAttachmentItemWidget(
            attachment: Attachment(name: fileName),
          ),
        );

        expect(label.text, fileName);
        expect(label.preserveFileExtension, isTrue);
      },
    );
  });

  group('recipient chips', () {
    testWidgets(
      'RecipientTagItemWidget should not preserve a file extension',
      (tester) async {
        final label = await pumpAndFindLabel(
          tester,
          RecipientTagItemWidget(
            index: 0,
            prefix: PrefixEmailAddress.to,
            currentEmailAddress: emailAddress,
            currentListEmailAddress: [emailAddress],
            imagePaths: imagePaths,
          ),
        );

        expect(label.preserveFileExtension, isFalse);
      },
    );

    testWidgets(
      'RecipientCollapsedItemWidget should not preserve a file extension',
      (tester) async {
        final label = await pumpAndFindLabel(
          tester,
          RecipientCollapsedItemWidget(emailAddress: emailAddress),
        );

        expect(label.preserveFileExtension, isFalse);
      },
    );

    testWidgets(
      'DraggableRecipientTagWidget should not preserve a file extension',
      (tester) async {
        final label = await pumpAndFindLabel(
          tester,
          DraggableRecipientTagWidget(
            emailAddress: emailAddress,
            imagePaths: imagePaths,
          ),
        );

        expect(label.preserveFileExtension, isFalse);
      },
    );
  });
}
