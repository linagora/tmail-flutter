
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:model/extensions/mailbox_id_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/presentation_label_mailbox.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

final _systemFolderIconMap = Map<String, String Function(ImagePaths)>.unmodifiable({
  PresentationMailbox.inboxRole:          (paths) => paths.icMailboxInbox,
  PresentationMailbox.favoriteRole:       (paths) => paths.icMailboxFavorite,
  PresentationMailbox.actionRequiredRole: (paths) => paths.icMailboxActionRequired,
  PresentationMailbox.draftsRole:         (paths) => paths.icMailboxDrafts,
  PresentationMailbox.outboxRole:         (paths) => paths.icMailboxOutbox,
  PresentationMailbox.archiveRole:        (paths) => paths.icMailboxArchived,
  PresentationMailbox.sentRole:           (paths) => paths.icMailboxSent,
  PresentationMailbox.trashRole:          (paths) => paths.icMailboxTrash,
  PresentationMailbox.spamRole:           (paths) => paths.icMailboxSpam,
  PresentationMailbox.junkRole:           (paths) => paths.icMailboxSpam,
  PresentationMailbox.templatesRole:      (paths) => paths.icMailboxTemplate,
  PresentationMailbox.recoveredRole:      (paths) => paths.icRecoverDeletedMessages,
  'all_mail':                             (paths) => paths.icMailboxAllMail,
});

final _systemFolderDisplayNameMap = Map<String, String Function(AppLocalizations)>.unmodifiable({
  PresentationMailbox.inboxRole:          (l10n) => l10n.inboxMailboxDisplayName,
  PresentationMailbox.favoriteRole:       (l10n) => l10n.favoriteMailboxDisplayName,
  PresentationMailbox.actionRequiredRole: (l10n) => l10n.actionRequiredMailboxDisplayName,
  PresentationMailbox.archiveRole:        (l10n) => l10n.archiveMailboxDisplayName,
  PresentationMailbox.draftsRole:         (l10n) => l10n.draftsMailboxDisplayName,
  PresentationMailbox.sentRole:           (l10n) => l10n.sentMailboxDisplayName,
  PresentationMailbox.outboxRole:         (l10n) => l10n.outboxMailboxDisplayName,
  PresentationMailbox.trashRole:          (l10n) => l10n.trashMailboxDisplayName,
  PresentationMailbox.spamRole:           (l10n) => l10n.spamMailboxDisplayName,
  PresentationMailbox.junkRole:           (l10n) => l10n.spamMailboxDisplayName,
  PresentationMailbox.templatesRole:      (l10n) => l10n.templatesMailboxDisplayName,
  PresentationMailbox.recoveredRole:      (l10n) => l10n.recoveredMailboxDisplayName,
});

extension PresentationMailboxExtension on PresentationMailbox {

  String getDisplayName(BuildContext context) =>
      getDisplayNameWithoutContext(AppLocalizations.of(context));

  String getDisplayNameWithoutContext(AppLocalizations l10n) {
    if (isLabelMailbox) return (this as PresentationLabelMailbox).label.safeDisplayName;
    if (isDefault) {
      final nameResolver = _systemFolderDisplayNameMap[role!.value.toLowerCase()];
      if (nameResolver != null) return nameResolver(l10n);
    }
    return name?.name ?? '';
  }

  String getMailboxIcon(ImagePaths imagePaths) {
    if (hasRole()) return _resolveSystemFolderIcon(role!.value, imagePaths);
    if (isChildOfTeamMailboxes && myRights?.mayDelete == false) {
      final nameKey = name?.name.toLowerCase();
      if (nameKey != null) {
        return _resolveSystemFolderIcon(nameKey, imagePaths);
      }
    }
    return imagePaths.icFolderMailbox;
  }

  String _resolveSystemFolderIcon(String roleKey, ImagePaths imagePaths) {
    final resolver = _systemFolderIconMap[roleKey];
    return resolver != null ? resolver(imagePaths) : imagePaths.icFolderMailbox;
  }

  Uri get mailboxRouteWeb => RouteUtils.createUrlWebLocationBar(
    AppRoutes.dashboard,
    router: NavigationRouter(mailboxId: id)
  );

  String? get filterKeyword {
    if (isFavorite) {
      return KeyWordIdentifier.emailFlagged.value;
    } else if (isLabelMailbox) {
      return (this as PresentationLabelMailbox).label.keyword?.value;
    } else {
      return null;
    }
  }

  bool get isCacheable => !isVirtualFolder && this is! PresentationLabelMailbox;

  bool get isLabelMailbox => this is PresentationLabelMailbox;

  String get browserRouteTitle => isLabelMailbox
      ? 'Label-${(this as PresentationLabelMailbox).label.id?.value}'
      : 'Mailbox-${mailboxId?.asString}';

  Id? get labelId =>
      isLabelMailbox ? (this as PresentationLabelMailbox).label.id : null;

  MailboxId? get browserRouteMailboxId => isLabelMailbox ? null : mailboxId;

  bool get isAllEmailTrashAndSpamFolder => id == PresentationMailbox.allEmailTrashAndSpamFolder.id;

  bool get isAllEmail => id == PresentationMailbox.unifiedMailbox.id;

  bool get isUnifiedMailbox => isAllEmail || isAllEmailTrashAndSpamFolder;

  String getFolderNameForQuickSearch(AppLocalizations appLocalizations) {
    if (isAllEmailTrashAndSpamFolder) {
      return appLocalizations.allEmailTrashAndSpam;
    } else if (isAllEmail) {
      return appLocalizations.allEmail;
    } else {
      return getDisplayNameWithoutContext(appLocalizations);
    }
  }
}