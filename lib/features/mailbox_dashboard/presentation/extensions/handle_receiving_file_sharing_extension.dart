import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/shared_media_file_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension HandleReceivingFileSharingExtension on MailboxDashBoardController {
  void openComposerFromSingleShare(SharedMediaFile sharedMediaFile) {
    switch (sharedMediaFile.type) {
      case SharedMediaType.image:
      case SharedMediaType.video:
      case SharedMediaType.file:
        openComposer(
          ComposerArguments.fromFileShared([sharedMediaFile]),
        );
        break;
      case SharedMediaType.text:
        // Android delivers both a shared sentence (EXTRA_TEXT) and a shared
        // text-format file such as .vcf/.ics/.csv (EXTRA_STREAM) with a
        // text/* mime type and SharedMediaType.text, so the mime type alone
        // cannot tell them apart. Only a file share leaves a real file on
        // disk behind `path` — literal text arrives as the characters
        // themselves — so route files to attachments and literal text to
        // the email body.
        if (sharedMediaFile.isFileShare) {
          openComposer(
            ComposerArguments.fromFileShared([sharedMediaFile]),
          );
        } else {
          openComposer(
            ComposerArguments.fromContentShared(sharedMediaFile.path.trim()),
          );
        }
        break;
      case SharedMediaType.url:
        if (sharedMediaFile.path.startsWith(RouteUtils.mailtoPrefix)) {
          final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(sharedMediaFile.path);
          openComposer(
            ComposerArguments.fromMailtoUri(
              listEmailAddress: navigationRouter.listEmailAddress,
              cc: navigationRouter.cc,
              bcc: navigationRouter.bcc,
              subject: navigationRouter.subject,
              body: navigationRouter.body,
            ),
          );
        } else if (PlatformInfo.isIOS) {
          // On iOS a url-type event can only originate from the share
          // extension (the plugin ignores every other URL), so a non-mailto
          // link share goes into the email body. On Android, shared links
          // arrive as text/plain and never reach here — its url-type events
          // are deep-link VIEW intents (e.g. twakemail.mobile://openApp)
          // owned by DeepLinksManager and must stay ignored.
          openComposer(
            ComposerArguments.fromContentShared(sharedMediaFile.path.trim()),
          );
        }
        break;
      case SharedMediaType.mailto:
        if (EmailUtils.isEmailAddressValid(sharedMediaFile.path)) {
          openComposer(
            ComposerArguments.fromEmailAddress(
              EmailAddress(null, sharedMediaFile.path),
            ),
          );
        }
        break;
    }
  }
}
