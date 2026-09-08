import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';

typedef OnEventReplyAction = void Function(EventActionType actionType);
typedef OnEventLinkAction = void Function(String link);
typedef OnEventMailAddressAction = void Function(String mailAddress);
typedef OnEventEmailAddressAction = void Function(EmailAddress emailAddress);

/// What the reader can do from an invitation card.
///
/// A null callback leaves its control visible but inert, which is how the
/// card renders an action the surrounding screen cannot serve.
class CalendarEventCardActions {
  /// Answers the invitation.
  final OnEventReplyAction onReply;

  /// Opens a composer addressed to everyone invited.
  final VoidCallback onMailToAttendees;

  /// Opens a link outside the app, such as the video conference.
  final OnEventLinkAction? onOpenLink;

  /// Copies a link to the clipboard.
  final OnEventLinkAction? onCopyLink;

  /// Opens a composer for an address written into the event's location.
  final OnEventMailAddressAction? onOpenComposer;

  /// Opens the details of an organiser or attendee.
  final OnEventEmailAddressAction? onOpenEmailAddress;

  const CalendarEventCardActions({
    required this.onReply,
    required this.onMailToAttendees,
    this.onOpenLink,
    this.onCopyLink,
    this.onOpenComposer,
    this.onOpenEmailAddress,
  });
}
