import 'package:core/utils/platform_info.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/auto_create_tag_for_recipients_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

typedef CarriedOverComposer = ({ComposerArguments arguments, List<String> droppedAttachmentNames});

extension CarryOverComposerExtension on ComposerController {
  /// Keeps what the user wrote for another account. Draft, identity and files belong to this account, so they stay.
  /// Inline images are kept: they sit in the body and upload again when it is sent.
  Future<CarriedOverComposer> carryOverToAnotherAccount() async {
    autoCreateEmailTag();
    final content = _withoutIdentitySignature(await getContentInEditor());
    final openedWith = composerArguments.value;
    // The reopened composer has no former identity, so it would never remove this one's BCC.
    final identityBcc = identitySelected.value?.bcc ?? const {};
    return (
      arguments: ComposerArguments(
        // Both rebuild the composer from these arguments only, without a server read.
        emailActionType: PlatformInfo.isWeb
            ? EmailActionType.reopenComposerBrowser
            : EmailActionType.restoreComposerFromPersistentCache,
        presentationEmail: PresentationEmail(
          subject: subjectEmail.value,
          to: listToEmailAddress.toSet(),
          cc: listCcEmailAddress.toSet(),
          bcc: listBccEmailAddress.where((address) => !identityBcc.contains(address)).toSet(),
          replyTo: listReplyToEmailAddress.toSet(),
        ),
        emailContents: content,
        messageId: openedWith?.messageId,
        references: openedWith?.references,
        hasRequestReadReceipt: hasRequestReadReceipt.value,
        isMarkAsImportant: isMarkAsImportant.value,
        displayMode: screenDisplayMode.value,
        savedActionType: EmailActionType.compose,
      ),
      droppedAttachmentNames: uploadController.listUploadAttachments
          .map((file) => file.fileName)
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }
}

/// Like [HtmlUtils.removeAllSignatures]: the reopened composer has no former identity to remove it, and quoted ones stay.
String _withoutIdentitySignature(String content) {
  final fragment = parseFragment(content);
  final signatures = fragment.querySelectorAll('.tmail-signature').where((element) => !_isQuoted(element)).toList();
  if (signatures.isEmpty) return content;
  for (final signature in signatures) {
    signature.remove();
  }
  return fragment.outerHtml;
}

bool _isQuoted(Element element) {
  for (var parent = element.parent; parent != null; parent = parent.parent) {
    if (parent.localName == 'blockquote' || parent.localName == 'cite') return true;
  }
  return false;
}
