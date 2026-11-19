import 'package:core/utils/platform_info.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/delegation_ended_handler.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/composer_delegation_ended_handler.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';

import 'composer_delegation_ended_handler_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<MailboxDashBoardController>(fallbackGenerators: fallbackGenerators),
  MockSpec<ComposerManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<ComposerController>(fallbackGenerators: fallbackGenerators),
  MockSpec<UploadController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockMailboxDashBoardController dashboard;
  late MockComposerManager composerManager;
  late RxMap<String, ComposerView> webComposers;
  const handler = ComposerDelegationEndedHandler();
  bool showsMine() => true;

  setUp(() {
    PlatformInfo.isTestingForWeb = true;
    dashboard = MockMailboxDashBoardController();
    composerManager = MockComposerManager();
    webComposers = <String, ComposerView>{}.obs;
    when(dashboard.composerManager).thenReturn(composerManager);
    when(dashboard.twakeAppManager).thenReturn(TwakeAppManager());
    when(composerManager.composers).thenReturn(webComposers);
    Get.put<MailboxDashBoardController>(dashboard);
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
    Get.reset();
  });

  MockComposerController writingComposer(String subject, {List<String> attachmentNames = const []}) {
    final composer = MockComposerController();
    final upload = MockUploadController();
    when(composer.uploadController).thenReturn(upload);
    when(composer.toEmailAddressController).thenReturn(TextEditingController());
    when(composer.ccEmailAddressController).thenReturn(TextEditingController());
    when(composer.bccEmailAddressController).thenReturn(TextEditingController());
    when(composer.replyToEmailAddressController).thenReturn(TextEditingController());
    when(composer.subjectEmail).thenReturn(Rxn<String>(subject));
    when(composer.readContentInEditor()).thenAnswer((_) async => '<p>$subject</p>');
    when(composer.hasRequestReadReceipt).thenReturn(RxBool(false));
    when(composer.isMarkAsImportant).thenReturn(RxBool(false));
    when(composer.screenDisplayMode).thenReturn(Rx(ScreenDisplayMode.normal));
    when(composer.composerArguments).thenReturn(Rxn());
    when(composer.identitySelected).thenReturn(Rxn<Identity>());
    when(upload.listUploadAttachments).thenReturn(RxList([
      for (final name in attachmentNames) UploadFileState(UploadTaskId(name), attachment: Attachment(name: name)),
    ]));
    when(upload.mapInlineAttachments).thenReturn({});
    return composer;
  }

  void openWebComposer(String id, ComposerController composer) {
    Get.put<ComposerController>(composer, tag: id);
    webComposers[id] = ComposerView(key: Key(id), composerId: id);
  }

  List<String?> reopenedSubjects() => verify(composerManager.addComposer(captureAny))
      .captured
      .map((arguments) => (arguments as ComposerArguments).presentationEmail?.subject)
      .toList();

  test('keeps every open web composer and reopens them only once the user is in their own mailbox', () async {
    openWebComposer('composer-1', writingComposer('Budget', attachmentNames: ['notes.pdf']));
    openWebComposer('composer-2', writingComposer('Agenda', attachmentNames: ['slides.key']));

    final afterLeave = await handler.beforeLeave();

    verifyNever(composerManager.addComposer(any));

    final handling = await afterLeave!(showsMine);

    expect(handling.keptComposerCount, 2);
    expect(handling.droppedAttachmentNames, ['notes.pdf', 'slides.key']);
    expect(reopenedSubjects(), ['Budget', 'Agenda']);
    expect(dashboard.twakeAppManager.hasComposer, isTrue);
  });

  test('reopens as a browser composer without the identity of the ended mailbox', () async {
    openWebComposer('composer-1', writingComposer('Budget'));
    final afterLeave = await handler.beforeLeave();
    when(dashboard.listIdentities).thenReturn([]);

    await afterLeave!(showsMine);

    final arguments = verify(composerManager.addComposer(captureAny)).captured.single as ComposerArguments;
    expect(arguments.emailActionType, EmailActionType.reopenComposerBrowser);
    expect(arguments.selectedIdentityId, isNull);
  });

  test('keeps the open mobile composer route too', () async {
    Get.put<ComposerController>(writingComposer('Budget'));
    final afterLeave = await handler.beforeLeave();

    expect((await afterLeave!(showsMine)).keptComposerCount, 1);
  });

  test('reopens the mobile composer only once the route it left has released its controller', () {
    Get.testMode = true;
    addTearDown(() => Get.testMode = false);
    fakeAsync((async) {
      PlatformInfo.isTestingForWeb = false;
      Get.put<ComposerController>(writingComposer('Budget'));
      late AfterDelegationLeft afterLeave;
      handler.beforeLeave().then((value) => afterLeave = value!);
      async.flushMicrotasks();
      var reopened = false;

      afterLeave(showsMine).then((_) => reopened = true);
      async.elapse(const Duration(milliseconds: 300));
      expect(reopened, isFalse);

      Get.delete<ComposerController>();
      async.elapse(const Duration(milliseconds: 50));
      expect(reopened, isTrue);
    });
  });

  test('SHOULD NOT wait forever for a mobile composer controller that is never released', () {
    Get.testMode = true;
    addTearDown(() => Get.testMode = false);
    fakeAsync((async) {
      PlatformInfo.isTestingForWeb = false;
      Get.put<ComposerController>(writingComposer('Budget'));
      late AfterDelegationLeft afterLeave;
      handler.beforeLeave().then((value) => afterLeave = value!);
      async.flushMicrotasks();
      var reopened = false;

      afterLeave(showsMine).then((_) => reopened = true);
      async.elapse(const Duration(seconds: 2));

      expect(reopened, isTrue);
    });
  });

  test('SHOULD NOT count a composer it could not read, and still keeps the others', () async {
    final broken = writingComposer('Broken');
    when(broken.readContentInEditor()).thenThrow(StateError('editor gone'));
    openWebComposer('composer-1', broken);
    openWebComposer('composer-2', writingComposer('Agenda'));

    final handling = await (await handler.beforeLeave())!(showsMine);

    expect(handling.keptComposerCount, 1);
    expect(reopenedSubjects(), ['Agenda']);
  });

  test('SHOULD NOT reopen nor count the composers left once my mailbox is no longer shown', () async {
    openWebComposer('composer-1', writingComposer('Budget', attachmentNames: ['notes.pdf']));
    openWebComposer('composer-2', writingComposer('Agenda', attachmentNames: ['slides.key']));
    final afterLeave = await handler.beforeLeave();
    var checks = 0;

    final handling = await afterLeave!(() => checks++ == 0);

    expect(reopenedSubjects(), ['Budget']);
    expect(handling, const DelegationEndedHandling(keptComposerCount: 1, droppedAttachmentNames: ['notes.pdf']));
  });

  test('SHOULD NOT keep anything when no composer is open', () async {
    expect(await handler.beforeLeave(), isNull);
  });

  test('SHOULD NOT keep anything once the dashboard is gone', () async {
    Get.delete<MailboxDashBoardController>(force: true);

    expect(await handler.beforeLeave(), isNull);
  });
}
