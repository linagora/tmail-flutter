import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

extension ComposerArgumentsExtension on ComposerArguments {

  ComposerArguments withIdentity({List<Identity>? identities}) {
    return ComposerArguments(
      emailActionType: emailActionType,
      presentationEmail: presentationEmail,
      emailContents: emailContents,
      attachments: attachments,
      mailboxRole: mailboxRole,
      listEmailAddress: listEmailAddress,
      listSharedMediaFile: listSharedMediaFile,
      sendingEmail: sendingEmail,
      subject: subject,
      body: body,
      messageId: messageId,
      references: references,
      previousEmailId: previousEmailId,
      identities: identities,
    );
  }
}