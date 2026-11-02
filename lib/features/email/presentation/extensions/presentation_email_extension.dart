import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
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
    Set<String>? meAddresses,
    String? listPost,
  }) {
    final me = meAddresses ?? (userName == null ? const <String>{} : {userName});
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
          meAddresses: me,
          listPost: listPost,
        );

      case EmailActionType.replyToList:
        return _handleReplyToList(listPost, me);

      case EmailActionType.replyAll:
        return _handleReplyAll(
          isSender: isSender,
          newToAddress: newToAddress,
          newCcAddress: newCcAddress,
          newBccAddress: newBccAddress,
          newReplyToAddress: newReplyToAddress,
          newFromAddress: newFromAddress,
          meAddresses: me,
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
    required Set<String> meAddresses,
    String? listPost,
  }) {
    if (isSender) return (to: newToAddress, cc: [], bcc: [], replyTo: []);

    final isReplyToListEnabled = EmailUtils.isReplyToListEnabled(listPost ?? '');
    List<EmailAddress> listToAddress = [];
    if (isReplyToListEnabled) {
      listToAddress = newFromAddress.withoutMeAddresses(meAddresses);
    } else {
      listToAddress = (newReplyToAddress.isNotEmpty
        ? newReplyToAddress
        : newFromAddress
      ).withoutMeAddresses(meAddresses);
    }

    return (to: listToAddress, cc: [], bcc: [], replyTo: []);
  }

  ({
    List<EmailAddress> to,
    List<EmailAddress> cc,
    List<EmailAddress> bcc,
    List<EmailAddress> replyTo,
  }) _handleReplyToList(String? listPost, Set<String> meAddresses) {
    final recipientRecord = EmailUtils.extractRecipientsFromListPost(listPost ?? '');

    return (
      to: recipientRecord.toMailAddresses.removeDuplicateEmails().withoutMeAddresses(meAddresses),
      cc: recipientRecord.ccMailAddresses.removeDuplicateEmails().withoutMeAddresses(meAddresses),
      bcc: recipientRecord.bccMailAddresses.removeDuplicateEmails().withoutMeAddresses(meAddresses),
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
    required Set<String> meAddresses,
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
      }.removeDuplicateEmails().withoutMeAddresses(meAddresses);

    } else {
      listToAddress = {
        ...(newReplyToAddress.isNotEmpty ? newReplyToAddress : newFromAddress),
        ...newToAddress,
      }.removeDuplicateEmails().withoutMeAddresses(meAddresses);
    }

    return (
      to: listToAddress,
      cc: newCcAddress.withoutMeAddresses(meAddresses),
      bcc: newBccAddress.withoutMeAddresses(meAddresses),
      replyTo: [],
    );
  }

  List<Label> getLabelList(List<Label> labels) {
    if (keywords?.isNotEmpty != true || labels.isEmpty) return const [];

    final enabledKeywords = keywords!.enabledKeywords;

    if (enabledKeywords.isEmpty) return const [];

    return labels
        .where((label) =>
            label.keyword != null && enabledKeywords.contains(label.keyword))
        .toList();
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
