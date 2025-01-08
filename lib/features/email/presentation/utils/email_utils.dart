import 'package:collection/collection.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/mail/mail_address.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

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
        return failure is DownloadAttachmentForWebFailure;
      },
      (success) {
        return success is DownloadAttachmentForWebSuccess
          || success is IdleDownloadAttachmentForWeb;
      }) ?? false;
  }

  static bool isSameDomain({
    required String emailAddress,
    required String internalDomain
  }) {
    log('EmailUtils::isSameDomain: emailAddress = $emailAddress | internalDomain = $internalDomain');
    return EmailUtils.isEmailAddressValid(emailAddress) &&
      emailAddress.split('@').last.toLowerCase() == internalDomain.toLowerCase();
  }

  static bool isEmailAddressValid(String address) {
    try {
      return GetUtils.isEmail(address) && MailAddress.validateAddress(address).asString().isNotEmpty;
    } catch(e) {
      logError('EmailUtils::isEmailAddressValid: Exception = $e');
      return false;
    }
  }

  static List<EmailAddress>? parsingListPost(String listPost) {
    try {
      if (listPost.isEmpty) {
        return null;
      }

      final regExpMailtoLinks = RegExp(r'mailto:([^>,]*)');
      final allMatchesMailtoLinks = regExpMailtoLinks.allMatches(listPost);
      final listMailtoLinks = allMatchesMailtoLinks
        .map((match) => match.group(0))
        .whereNotNull()
        .toList();
      log('EmailUtils::parsingListPost:listMailtoLinks: $listMailtoLinks');

      if (listMailtoLinks.isNotEmpty) {
        return listMailtoLinks
          .map((mailto) {
            final mapMailto = RouteUtils.parseMapMailtoFromUri(mailto);
            final emailAddress = mapMailto[RouteUtils.paramMailtoAddress];
            return emailAddress != null
              ? EmailAddress(null, emailAddress)
              : null;
          })
          .whereNotNull()
          .toList();
      } else {
        return null;
      }
    } catch (e) {
      logError('EmailUtils::parsingListPost:Exception = $e');
      return null;
    }
  }
}