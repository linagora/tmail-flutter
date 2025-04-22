import 'dart:math';

import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';

class ThreadDetailPresentationUtils {
  const ThreadDetailPresentationUtils._();

  static const _initialLoadSize = 2;
  static const _defaultLoadSize = 2;
  // static const _defaultLoadSize = 20;

  static List<EmailId> getEmailIdsToLoad(
    Map<EmailId, PresentationEmail?> emailIdsPresentation,
  ) {
    final validEmailIdsToLoad = emailIdsPresentation.entries
      .where((entry) => entry.value == null)
      .map((entry) => entry.key)
      .toList();

    if (validEmailIdsToLoad.length == emailIdsPresentation.length) {
      // No email loaded yet
      return validEmailIdsToLoad.sublist(
        0,
        min(validEmailIdsToLoad.length, _initialLoadSize),
      );
    }

    return validEmailIdsToLoad.sublist(
      validEmailIdsToLoad.length - min(validEmailIdsToLoad.length, _defaultLoadSize),
      validEmailIdsToLoad.length,
    );
  }
}