import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';

class ThreadDetailPresentationUtils {
  const ThreadDetailPresentationUtils._();

  static const _initialLoadSize = 2;
  static const _defaultLoadSize = 20;

  @visibleForTesting
  static int get defaultLoadSize => _defaultLoadSize;

  static List<EmailId> getFirstLoadEmailIds(
    List<EmailId> emailIds, {
    EmailId? selectedEmailId,
  }) {
    // Default first, second and last email
    if (emailIds.length <= 3) return emailIds;

    if (selectedEmailId == null ||
        !emailIds.contains(selectedEmailId) ||
        selectedEmailId == emailIds.first ||
        selectedEmailId == emailIds.last ||
        selectedEmailId == emailIds.elementAt(1)) {

      return [
        ...emailIds.sublist(
          0,
          min(emailIds.length, _initialLoadSize),
        ),
        emailIds.last,
      ];
    }

    return [
      emailIds.first,
      selectedEmailId,
      emailIds.last,
    ];
  }

  static getLoadMoreEmailIds(
    List<EmailId> emailIds, {
    bool loadEmailsAfterSelectedEmail = false,
  }) {
    if (loadEmailsAfterSelectedEmail) {
      return emailIds.sublist(0, min(emailIds.length, _defaultLoadSize));
    }

    return emailIds.sublist(
      emailIds.length - min(_defaultLoadSize, emailIds.length),
      emailIds.length,
    );
  }

  static List<EmailId> refreshEmailIds({
    required List<EmailId> original,
    required List<EmailId> created,
    required List<EmailId> destroyed,
  }) {
    return [
      ...original.whereNot(destroyed.contains),
      ...created,
    ];
  }

  static List<PresentationEmail> refreshPresentationEmails({
    required List<PresentationEmail> original,
    required List<PresentationEmail> created,
    required List<PresentationEmail> updated,
    required List<EmailId> destroyed,
  }) {
    return [
      ...original
        .whereNot((email) => destroyed.contains(email.id))
        .map((email) {
          final updatedInOriginal = updated.firstWhereOrNull(
            (updatedEmail) => updatedEmail.id == email.id,
          );

          return email.copyWith(
            keywords: updatedInOriginal?.keywords,
            mailboxIds: updatedInOriginal?.mailboxIds,
          );
        }),
      ...created,
    ];
  }
}