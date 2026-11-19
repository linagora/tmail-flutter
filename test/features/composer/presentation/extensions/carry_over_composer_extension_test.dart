import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/carry_over_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';

import 'carry_over_composer_extension_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<ComposerController>(fallbackGenerators: fallbackGenerators),
  MockSpec<UploadController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final andy = EmailAddress('Andy', 'andy@example.com');
  final ciara = EmailAddress('Ciara', 'ciara@example.com');
  final dana = EmailAddress('Dana', 'dana@example.com');
  final evan = EmailAddress('Evan', 'evan@example.com');
  final messageId = MessageIdsHeaderValue({'original@example.com'});
  final references = MessageIdsHeaderValue({'ancestor@example.com'});
  late MockComposerController composer;
  late MockUploadController upload;
  late TextEditingController toInput;

  setUp(() {
    composer = MockComposerController();
    upload = MockUploadController();
    toInput = TextEditingController();
    when(composer.uploadController).thenReturn(upload);
    when(composer.toEmailAddressController).thenReturn(toInput);
    when(composer.ccEmailAddressController).thenReturn(TextEditingController());
    when(composer.bccEmailAddressController).thenReturn(TextEditingController());
    when(composer.replyToEmailAddressController).thenReturn(TextEditingController());
    when(composer.listToEmailAddress).thenReturn([andy]);
    when(composer.listCcEmailAddress).thenReturn([ciara]);
    when(composer.listBccEmailAddress).thenReturn([dana]);
    when(composer.listReplyToEmailAddress).thenReturn([evan]);
    when(composer.subjectEmail).thenReturn(Rxn<String>('Quarterly plan'));
    when(composer.readContentInEditor()).thenAnswer((_) async => '<p>Draft body</p>');
    when(composer.hasRequestReadReceipt).thenReturn(RxBool(true));
    when(composer.isMarkAsImportant).thenReturn(RxBool(true));
    when(composer.screenDisplayMode).thenReturn(Rx(ScreenDisplayMode.fullScreen));
    when(composer.isInitialRecipient).thenReturn(RxBool(true));
    when(composer.keyToEmailTagEditor).thenReturn(GlobalKey());
    when(composer.composerArguments).thenReturn(
      Rxn(
        ComposerArguments(
          emailActionType: EmailActionType.editDraft,
          presentationEmail: PresentationEmail(id: EmailId(Id('draft-1'))),
          messageId: messageId,
          references: references,
          selectedIdentityId: IdentityId(Id('identity-1')),
          savedEmailDraftId: EmailId(Id('draft-1')),
          composerId: 'composer-1',
        ),
      ),
    );
    when(upload.listUploadAttachments).thenReturn(RxList<UploadFileState>());
    when(upload.mapInlineAttachments).thenReturn({});
    when(composer.identitySelected).thenReturn(Rxn<Identity>());
  });

  tearDown(() => toInput.dispose());

  test('carries what the user wrote into arguments that rebuild the composer without a server read', () async {
    final carried = await composer.carryOverToAnotherAccount();

    expect(
      carried.arguments,
      ComposerArguments(
        emailActionType: EmailActionType.restoreComposerFromPersistentCache,
        presentationEmail: PresentationEmail(
          subject: 'Quarterly plan',
          to: {andy},
          cc: {ciara},
          bcc: {dana},
          replyTo: {evan},
        ),
        emailContents: '<p>Draft body</p>',
        messageId: messageId,
        references: references,
        hasRequestReadReceipt: true,
        isMarkAsImportant: true,
        displayMode: ScreenDisplayMode.fullScreen,
        savedActionType: EmailActionType.compose,
      ),
    );
    expect(carried.droppedAttachmentNames, isEmpty);
  });

  test('SHOULD NOT carry the draft, identity or composer id of the ended account', () async {
    final arguments = (await composer.carryOverToAnotherAccount()).arguments;

    expect(arguments.presentationEmail?.id, isNull);
    expect(arguments.savedEmailDraftId, isNull);
    expect(arguments.selectedIdentityId, isNull);
    expect(arguments.identities, isNull);
    expect(arguments.composerId, isNull);
    expect(arguments.attachments, isNull);
    expect(arguments.inlineImages, isNull);
  });

  test('keeps an address still typed in the To field as a recipient', () async {
    final to = [andy];
    when(composer.listToEmailAddress).thenReturn(to);
    toInput.text = 'fiona@example.com';

    final carried = await composer.carryOverToAnotherAccount();

    expect(carried.arguments.presentationEmail?.to?.map((address) => address.email), ['andy@example.com', 'fiona@example.com']);
  });

  test('lists the names of the attachments it leaves behind', () async {
    when(upload.listUploadAttachments).thenReturn(RxList([
      UploadFileState(const UploadTaskId('task-1'), attachment: Attachment(name: 'notes.pdf')),
      UploadFileState(const UploadTaskId('task-2'), attachment: Attachment(name: 'budget.xlsx')),
    ]));

    final carried = await composer.carryOverToAnotherAccount();

    expect(carried.droppedAttachmentNames, ['notes.pdf', 'budget.xlsx']);
    expect(carried.arguments.attachments, isNull);
  });

  test('SHOULD NOT list an inline image, its body copy uploads again when sent', () async {
    when(composer.readContentInEditor()).thenAnswer((_) async => '<p><img src="data:image/png;base64,AAAA"></p>');
    when(upload.mapInlineAttachments).thenReturn({'cid-1': Attachment(name: 'logo.png', cid: 'cid-1')});

    final carried = await composer.carryOverToAnotherAccount();

    expect(carried.droppedAttachmentNames, isEmpty);
    expect(carried.arguments.emailContents, '<p><img src="data:image/png;base64,AAAA"></p>');
  });

  test('SHOULD NOT list an attachment without a name', () async {
    when(upload.listUploadAttachments).thenReturn(RxList([UploadFileState(const UploadTaskId('task-1'))]));

    expect((await composer.carryOverToAnotherAccount()).droppedAttachmentNames, isEmpty);
  });

  test('leaves out the signature of the ended identity but keeps a quoted one', () async {
    when(composer.readContentInEditor()).thenAnswer((_) async =>
        '<p>Draft body</p><div class="tmail-signature">Bob team</div>'
        '<blockquote><div class="tmail-signature">Quoted sender</div></blockquote>'
        '<cite><div class="tmail-signature">Cited sender</div></cite>');

    final content = (await composer.carryOverToAnotherAccount()).arguments.emailContents;

    expect(
      content,
      '<p>Draft body</p>'
      '<blockquote><div class="tmail-signature">Quoted sender</div></blockquote>'
      '<cite><div class="tmail-signature">Cited sender</div></cite>',
    );
  });

  test('SHOULD NOT rewrite a body without a signature of its own', () async {
    const body = '<p>Draft&nbsp;body<br></p><blockquote><div class="tmail-signature">Quoted</div></blockquote>';
    when(composer.readContentInEditor()).thenAnswer((_) async => body);

    expect((await composer.carryOverToAnotherAccount()).arguments.emailContents, body);
  });

  test('leaves out the BCC added by the ended identity and keeps the ones the user typed', () async {
    when(composer.listBccEmailAddress).thenReturn([dana, ciara]);
    when(composer.identitySelected).thenReturn(
      Rxn(Identity(id: IdentityId(Id('identity-1')), bcc: {EmailAddress('Dana', 'dana@example.com')})),
    );

    final bcc = (await composer.carryOverToAnotherAccount()).arguments.presentationEmail?.bcc;

    expect(bcc, {ciara});
  });

  test('carries a new message without the headers of a reply', () async {
    when(composer.composerArguments).thenReturn(Rxn());

    final arguments = (await composer.carryOverToAnotherAccount()).arguments;

    expect(arguments.messageId, isNull);
    expect(arguments.references, isNull);
  });
}
