import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/shared_media_file_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/show_mine_before_intent.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_preview_attachment_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension HandleReceivingFileSharingExtension on MailboxDashBoardController {
  /// Opens the composer of `mine` for a share or `mailto` intent, switching back from a delegated mailbox first.
  void openComposerFromSharedFiles(List<SharedMediaFile> sharedMediaFiles) {
    final openComposerForShare = _composerOpenerFor(sharedMediaFiles);
    if (openComposerForShare == null) return;
    if (!shownAccountCapabilities.switchesToMineBeforeIntent) {
      openComposerForShare();
      return;
    }
    final context = currentContext;
    if (context != null) unawaited(_openComposerOnMine(context, openComposerForShare));
  }

  Future<void> _openComposerOnMine(
    BuildContext context,
    VoidCallback openComposerForShare,
  ) async {
    if (await showMineBeforeIntent(context)) openComposerForShare();
  }

  // Null for an event that opens no composer, so it never triggers a switch to mine.
  VoidCallback? _composerOpenerFor(List<SharedMediaFile> sharedMediaFiles) {
    if (sharedMediaFiles.length != 1) {
      return () => openComposer(ComposerArguments.fromFileShared(sharedMediaFiles));
    }
    final sharedMediaFile = sharedMediaFiles.first;
    if (sharedMediaFile.path.trim().isEmpty) return null;
    return _composerOpenerForSingleShare(sharedMediaFile);
  }

  VoidCallback? _composerOpenerForSingleShare(SharedMediaFile sharedMediaFile) {
    switch (sharedMediaFile.type) {
      case SharedMediaType.image:
      case SharedMediaType.video:
      case SharedMediaType.file:
        return () => _openComposerWithFile(sharedMediaFile);
      case SharedMediaType.text:
        return () => _openComposerFromText(sharedMediaFile);
      case SharedMediaType.url:
        return _composerOpenerForUrl(sharedMediaFile);
      case SharedMediaType.mailto:
        return _composerOpenerForMailtoAddress(sharedMediaFile);
      case SharedMediaType.unreadable:
        return null;
    }
  }

  void _openComposerWithFile(SharedMediaFile sharedMediaFile) {
    openComposer(ComposerArguments.fromFileShared([sharedMediaFile]));
  }

  void _openComposerWithContent(SharedMediaFile sharedMediaFile) {
    openComposer(ComposerArguments.fromContentShared(sharedMediaFile.path.trim()));
  }

  // Android delivers both a shared sentence (EXTRA_TEXT) and a shared
  // text-format file such as .vcf/.ics/.csv (EXTRA_STREAM) with a
  // text/* mime type and SharedMediaType.text, so the mime type alone
  // cannot tell them apart. Only a file share leaves a real file on
  // disk behind `path` — literal text arrives as the characters
  // themselves — so route files to attachments and literal text to
  // the email body.
  void _openComposerFromText(SharedMediaFile sharedMediaFile) {
    if (sharedMediaFile.isFileShare) {
      _openComposerWithFile(sharedMediaFile);
    } else {
      _openComposerWithContent(sharedMediaFile);
    }
  }

  VoidCallback? _composerOpenerForUrl(SharedMediaFile sharedMediaFile) {
    if (sharedMediaFile.path.startsWith(RouteUtils.mailtoPrefix)) {
      final uri = Uri.tryParse(sharedMediaFile.path);
      return uri == null ? null : () => openComposerFromMailToLink(uri);
    }
    // On iOS a url-type event can only originate from the share
    // extension (the plugin ignores every other URL), so a non-mailto
    // link share goes into the email body. On Android, shared links
    // arrive as text/plain and never reach here — its url-type events
    // are deep-link VIEW intents (e.g. twakemail.mobile://openApp)
    // owned by DeepLinksManager and must stay ignored.
    return PlatformInfo.isIOS ? () => _openComposerWithContent(sharedMediaFile) : null;
  }

  VoidCallback? _composerOpenerForMailtoAddress(SharedMediaFile sharedMediaFile) {
    if (!EmailUtils.isEmailAddressValid(sharedMediaFile.path)) return null;
    return () => openComposer(
      ComposerArguments.fromEmailAddress(
        EmailAddress(null, sharedMediaFile.path),
      ),
    );
  }
}
