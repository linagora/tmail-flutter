import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';

extension PresentationEmailExtension on PresentationEmail {
  ({
    List<EmailAddress> to,
    List<EmailAddress> cc,
    List<EmailAddress> bcc,
    List<EmailAddress> replyTo,
  }) generateRecipientsEmailAddressForComposer({
    required EmailActionType emailActionType,
    bool isSender = false,
    String? userName,
    String? listPost,
  }) {
    final newFromAddress = from.removeDuplicateEmails();
    final newToAddress = to.removeDuplicateEmails();
    final newCcAddress = cc.removeDuplicateEmails();
    final newBccAddress = bcc.removeDuplicateEmails();
    final newReplyToAddress = replyTo.removeDuplicateEmails();

    switch (emailActionType) {
      case EmailActionType.reply:
        return _handleReply(
          isSender: isSender,
          newToAddress: newToAddress,
          newFromAddress: newFromAddress,
          newBccAddress: newBccAddress,
          newReplyToAddress: newReplyToAddress,
          userName: userName,
          listPost: listPost,
        );

      case EmailActionType.replyToList:
        return _handleReplyToList(listPost, userName);

      case EmailActionType.replyAll:
        return _handleReplyAll(
          isSender: isSender,
          newToAddress: newToAddress,
          newCcAddress: newCcAddress,
          newBccAddress: newBccAddress,
          newReplyToAddress: newReplyToAddress,
          newFromAddress: newFromAddress,
          userName: userName,
          listPost: listPost,
        );

      default:
        return (
          to: newToAddress,
          cc: newCcAddress,
          bcc: newBccAddress,
          replyTo: newReplyToAddress,
        );
    }
  }

  ({
    List<EmailAddress> to,
    List<EmailAddress> cc,
    List<EmailAddress> bcc,
    List<EmailAddress> replyTo,
  }) _handleReply({
    required bool isSender,
    required List<EmailAddress> newToAddress,
    required List<EmailAddress> newFromAddress,
    required List<EmailAddress> newBccAddress,
    required List<EmailAddress> newReplyToAddress,
    String? userName,
    String? listPost,
  }) {
    if (isSender) return (to: newToAddress, cc: [], bcc: [], replyTo: []);

    final isReplyToListEnabled = EmailUtils.isReplyToListEnabled(listPost ?? '');
    List<EmailAddress> listToAddress = [];
    if (isReplyToListEnabled) {
      listToAddress = newFromAddress.withoutMe(userName);
    } else {
      listToAddress = (newReplyToAddress.isNotEmpty
        ? newReplyToAddress
        : newFromAddress
      ).withoutMe(userName);
    }

    return (to: listToAddress, cc: [], bcc: [], replyTo: []);
  }

  ({
    List<EmailAddress> to,
    List<EmailAddress> cc,
    List<EmailAddress> bcc,
    List<EmailAddress> replyTo,
  }) _handleReplyToList(String? listPost, String? userName) {
    final recipientRecord = EmailUtils.extractRecipientsFromListPost(listPost ?? '');

    return (
      to: recipientRecord.toMailAddresses.removeDuplicateEmails().withoutMe(userName),
      cc: recipientRecord.ccMailAddresses.removeDuplicateEmails().withoutMe(userName),
      bcc: recipientRecord.bccMailAddresses.removeDuplicateEmails().withoutMe(userName),
      replyTo: [],
    );
  }

  ({
    List<EmailAddress> to,
    List<EmailAddress> cc,
    List<EmailAddress> bcc,
    List<EmailAddress> replyTo,
  }) _handleReplyAll({
    required bool isSender,
    required List<EmailAddress> newToAddress,
    required List<EmailAddress> newCcAddress,
    required List<EmailAddress> newBccAddress,
    required List<EmailAddress> newReplyToAddress,
    required List<EmailAddress> newFromAddress,
    String? userName,
    String? listPost,
  }) {
    if (isSender) {
      return (
        to: newToAddress,
        cc: newCcAddress,
        bcc: newBccAddress,
        replyTo: newReplyToAddress,
      );
    }

    final isReplyToListEnabled = EmailUtils.isReplyToListEnabled(listPost ?? '');
    List<EmailAddress> listToAddress = [];

    if (isReplyToListEnabled) {
      listToAddress = {
        ...newReplyToAddress,
        ...newFromAddress,
        ...newToAddress,
      }.removeDuplicateEmails().withoutMe(userName);

    } else {
      listToAddress = {
        ...(newReplyToAddress.isNotEmpty ? newReplyToAddress : newFromAddress),
        ...newToAddress,
      }.removeDuplicateEmails().withoutMe(userName);
    }

    return (
      to: listToAddress,
      cc: newCcAddress.withoutMe(userName),
      bcc: newBccAddress.withoutMe(userName),
      replyTo: [],
    );
  }

  List<Label> getLabelList(List<Label> labels) {
    if (keywords?.isNotEmpty != true) return const [];

    final enabledKeywords = keywords!.enabledKeywords;
    if (enabledKeywords.isEmpty) return const [];

    // 1) Registered labels: keywords that have a server-side `Label` object
    //    (Linagora `com:linagora:params:jmap:labels` extension) — carry
    //    displayName + color set by the user.
    final registered = labels
        .where((label) =>
            label.keyword != null && enabledKeywords.contains(label.keyword))
        .toList();

    // 2) Orphan / standard JMAP keywords: any keyword set via the RFC 8621
    //    `Email/set keywords` API by an external tool (mail sentinel,
    //    filter, IMAP client) that is NOT already a registered Label AND is
    //    NOT a UI-mapped system keyword (star, seen, draft, junk, etc.).
    //    Rendered as read-only chips with the default primary color so
    //    keywords from any standards-compliant JMAP producer become visible.
    final registeredKeywords = <String>{
      for (final label in registered)
        if (label.keyword != null) label.keyword!.value,
    };
    final orphanLabels = <Label>[];
    for (final keyword in enabledKeywords) {
      if (keyword.isSystemKeyword) continue;
      if (registeredKeywords.contains(keyword.value)) continue;
      orphanLabels.add(Label(keyword: keyword, displayName: keyword.value));
    }

    return [...registered, ...orphanLabels];
  }

  PresentationEmail toggleKeyword(KeyWordIdentifier keyword, bool remove) {
    return copyWith(
      keywords: remove
          ? keywords.withoutKeyword(keyword)
          : keywords.withKeyword(keyword),
    )
      ..searchSnippetSubject = searchSnippetSubject
      ..searchSnippetPreview = searchSnippetPreview;
  }
}
