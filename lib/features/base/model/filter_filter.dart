import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum FilterField {
  from,
  to,
  cc,
  bcc,
  replyTo,
  subject,
  hasKeyword,
  notKeyword,
  mailBox,
  date,
  sortBy,
  labels,
  hasAttachment,
  deletionDate,
  receptionDate,
  recoverSubject,
  recipients,
  sender;

  String getTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case FilterField.from:
        return appLocalizations.from_email_address_prefix;
      case FilterField.to:
        return appLocalizations.to_email_address_prefix;
      case FilterField.subject:
      case FilterField.recoverSubject:
        return appLocalizations.subject;
      case FilterField.hasKeyword:
        return appLocalizations.hasTheWords;
      case FilterField.notKeyword:
        return appLocalizations.doesNotHave;
      case FilterField.mailBox:
        return appLocalizations.folder;
      case FilterField.date:
        return appLocalizations.date;
      case FilterField.sortBy:
        return appLocalizations.sortBy;
      case FilterField.hasAttachment:
        return appLocalizations.hasAttachment;
      case FilterField.deletionDate:
        return appLocalizations.deletionDate;
      case FilterField.receptionDate:
        return appLocalizations.receptionDate;
      case FilterField.recipients:
        return appLocalizations.headerRecipients;
      case FilterField.sender:
        return appLocalizations.sender;
      case FilterField.labels:
        return appLocalizations.labels;
      default:
        return '';
    }
  }

  String getHintText(AppLocalizations appLocalizations) {
    switch (this) {
      case FilterField.from:
      case FilterField.to:
        return appLocalizations.nameOrEmailAddress;
      case FilterField.subject:
        return appLocalizations.enterASubject;
      case FilterField.hasKeyword:
      case FilterField.notKeyword:
        return appLocalizations.enterSomeSuggestions;
      case FilterField.mailBox:
        return appLocalizations.allFolders;
      case FilterField.date:
        return appLocalizations.allTime;
      case FilterField.sortBy:
        return appLocalizations.mostRecent;
      case FilterField.hasAttachment:
        return appLocalizations.hasAttachment;
      case FilterField.recoverSubject:
        return appLocalizations.enterSubjectKeywords;
      case FilterField.recipients:
      case FilterField.sender:
        return appLocalizations.addAnEmailAddress;
      case FilterField.labels:
        return appLocalizations.allLabels;
      default:
        return '';
    }
  }

  List<EmailReceiveTimeType> getSupportedTimeTypes(
    DateTime restorationHorizon,
  ) {
    switch (this) {
      case FilterField.deletionDate:
        final supportedTypes = EmailReceiveTimeType
            .valuesForRecoverDeletionDateField
            .where((type) => restorationHorizon
                .subtract(const Duration(seconds: 2)) // to allow "15 days" if restorationHorizon is exactly 15
                .isBefore(type.toOldestUTCDate()!.value))
            .toList();

        return [...supportedTypes, EmailReceiveTimeType.customRange];
      case FilterField.receptionDate:
        return EmailReceiveTimeType.valuesForRecoverReceptionDateDateField;
      default:
        return [];
    }
  }
}
