import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailSortOrderType {
  mostRecent,
  oldest,
  relevance,
  senderAscending,
  senderDescending,
  subjectAscending,
  subjectDescending;

  String getTitle(BuildContext context) {
    return getTitleByAppLocalizations(AppLocalizations.of(context));
  }

  String getTitleByAppLocalizations(AppLocalizations appLocalizations) {
    switch (this) {
      case EmailSortOrderType.mostRecent:
        return appLocalizations.mostRecent;
      case EmailSortOrderType.oldest:
        return appLocalizations.oldest;
      case EmailSortOrderType.relevance:
        return appLocalizations.relevance;
      case EmailSortOrderType.senderAscending:
        return appLocalizations.senderAscending;
      case EmailSortOrderType.senderDescending:
        return appLocalizations.senderDescending;
      case EmailSortOrderType.subjectAscending:
        return appLocalizations.subjectAscending;
      case EmailSortOrderType.subjectDescending:
        return appLocalizations.subjectDescending;
    }
  }

  Option<Set<Comparator>> getSortOrder() {
    switch (this) {
      case EmailSortOrderType.mostRecent:
        return Some(
          <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false))
        );
      case EmailSortOrderType.oldest:
        return Some(
          <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(true))
        );
      case EmailSortOrderType.relevance:
        return const None();
      case EmailSortOrderType.senderAscending:
        return Some(
          <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.from)
              ..setIsAscending(true))
        );
      case EmailSortOrderType.senderDescending:
        return Some(
          <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.from)
              ..setIsAscending(false))
        );
      case EmailSortOrderType.subjectAscending:
        return Some(
          <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.subject)
              ..setIsAscending(true))
        );
      case EmailSortOrderType.subjectDescending:
        return Some(
          <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.subject)
              ..setIsAscending(false))
        );
    }
  }

  TextStyle getTextStyle({required bool isInDropdown}) {
    return TextStyle(
      fontSize: isInDropdown ? 15 : 16,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );
  }

  bool isScrollByPosition() {
    return this == EmailSortOrderType.subjectDescending ||
      this == EmailSortOrderType.subjectAscending ||
      this == EmailSortOrderType.senderDescending ||
      this == EmailSortOrderType.senderAscending ||
      this == EmailSortOrderType.relevance;
  }
}