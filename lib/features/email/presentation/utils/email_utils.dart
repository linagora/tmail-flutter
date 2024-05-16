
import 'package:collection/collection.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/view_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class EmailUtils {

  static Properties getPropertiesForEmailGetMethod(Session session, AccountId accountId) {
    if (CapabilityIdentifier.jamesCalendarEvent.isSupported(session, accountId)) {
      return ThreadConstants.propertiesCalendarEvent;
    } else {
      return ThreadConstants.propertiesDefault;
    }
  }

  static EmailUnsubscribe? parsingUnsubscribe(String listUnsubscribe) {
    if (listUnsubscribe.isEmpty) {
      return null;
    }

    final regExpMailtoLinks = RegExp(r'mailto:([^>,]*)');
    final allMatchesMailtoLinks = regExpMailtoLinks.allMatches(listUnsubscribe);
    final listMailtoLinks = allMatchesMailtoLinks
      .map((match) => match.group(0))
      .whereNotNull()
      .toList();
    log('EmailUtils::parsingUnsubscribe:listMailtoLinks: $listMailtoLinks');

    final regExpHttpLinks = RegExp(r'http([^>,]*)');
    final allMatchesHttpLinks = regExpHttpLinks.allMatches(listUnsubscribe);
    final listHttpLinks = allMatchesHttpLinks
      .map((match) => match.group(0))
      .whereNotNull()
      .toList();
    log('EmailUtils::parsingUnsubscribe:listHttpLinks: $listHttpLinks');

    if (listMailtoLinks.isNotEmpty || listHttpLinks.isNotEmpty) {
      return EmailUnsubscribe(
        httpLinks: listHttpLinks,
        mailtoLinks: listMailtoLinks
      );
    } else {
      return null;
    }
  }

  static bool checkingIfAttachmentActionIsEnabled(Either<Failure, Success>? state) {
    return state?.fold(
      (failure) {
        return failure is DownloadAttachmentForWebFailure
          || failure is ViewAttachmentForWebFailure;
      },
      (success) {
        return success is DownloadAttachmentForWebSuccess
          || success is ViewAttachmentForWebSuccess
          || success is IdleDownloadAttachmentForWeb
          || success is IdleViewAttachmentForWeb;
      }) ?? false;
  }

  static bool isSameDomain({
    required String emailAddress,
    required String internalDomain
  }) {
    log('EmailUtils::isSameDomain: emailAddress = $emailAddress | internalDomain = $internalDomain');
    return GetUtils.isEmail(emailAddress) &&
      emailAddress.split('@').last.toLowerCase() == internalDomain.toLowerCase();
  }
}