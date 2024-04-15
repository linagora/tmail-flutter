import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/mailbox_property.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';

extension ListMailboxIdExtension on List<MailboxId> {

  Map<Id, PatchObject> generateMapUpdateObjectSubscribeMailbox(MailboxSubscribeState subscribeState) {
    final Map<Id, PatchObject> maps = {
      for (var mailboxId in this)
        mailboxId.id: PatchObject({
          MailboxProperty.isSubscribed: subscribeState == MailboxSubscribeState.enabled
        })
    };
    return maps;
  }

  Set<Id> get ids => map((mailboxId) => mailboxId.id).toSet();
}