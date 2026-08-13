import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';

extension KeyWordIdentifierExtension on KeyWordIdentifier {
  static final unsubscribeMail = KeyWordIdentifier('\$unsubscribe');
  static final needsActionMail = KeyWordIdentifier('needs-action');
  static final eventsMail = KeyWordIdentifier('event');

  /// Keywords that carry dedicated UI treatment (star, read/unread badge,
  /// draft badge, junk folder auto-move, etc.) and therefore MUST NOT
  /// surface as user-visible label chips.
  ///
  /// The set combines the RFC 8621 §2.1.4 system keywords with the three
  /// UI-mapped custom keywords defined above. Any keyword not listed here
  /// is treated as a user-visible label — including custom keywords set
  /// by external JMAP-compliant tools (e.g. mail sentinels, filters).
  static final systemKeywords = <String>{
    KeyWordIdentifier.emailDraft.value,
    KeyWordIdentifier.emailSeen.value,
    KeyWordIdentifier.emailFlagged.value,
    KeyWordIdentifier.emailAnswered.value,
    KeyWordIdentifier.emailForwarded.value,
    KeyWordIdentifier.emailPhishing.value,
    KeyWordIdentifier.emailJunk.value,
    KeyWordIdentifier.emailNotJunk.value,
    KeyWordIdentifier.mdnSent.value,
    unsubscribeMail.value,
    needsActionMail.value,
    eventsMail.value,
  };

  /// True when this keyword should NOT be rendered as a label chip
  /// (RFC 8621 system keywords + tmail's UI-mapped custom keywords).
  bool get isSystemKeyword => systemKeywords.contains(value);

  String generatePath() => '${PatchObject.keywordsProperty}/$value';

  /// General helper to generate a boolean patch.
  PatchObject _boolPatch(bool? flag) {
    return PatchObject({generatePath(): flag});
  }

  PatchObject generateReadActionPath(ReadActions action) {
    return _boolPatch(action == ReadActions.markAsRead ? true : null);
  }

  PatchObject generateMarkStarActionPath(MarkStarAction action) {
    return _boolPatch(action == MarkStarAction.markStar ? true : null);
  }

  PatchObject generateAnsweredActionPath() => _boolPatch(true);

  PatchObject generateForwardedActionPath() => _boolPatch(true);

  PatchObject generateUnsubscribeActionPath() => _boolPatch(true);

  PatchObject generateLabelActionPath({bool remove = false}) =>
      _boolPatch(remove ? null : true);
}
