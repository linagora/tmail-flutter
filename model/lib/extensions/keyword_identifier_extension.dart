import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';

extension KeyWordIdentifierExtension on KeyWordIdentifier {
  static final unsubscribeMail = KeyWordIdentifier('\$unsubscribe');
  static final needsActionMail = KeyWordIdentifier('\$needs-action');

  String generatePath() => '${PatchObject.keywordsProperty}/$value';

  /// General helper to generate a boolean patch.
  PatchObject _boolPatch(bool? flag) {
    return PatchObject({generatePath(): flag});
  }

  PatchObject generateReadActionPath(ReadActions action) {
    final isRead = action == ReadActions.markAsRead;
    return _boolPatch(isRead ? true : null);
  }

  PatchObject generateMarkStarActionPath(MarkStarAction action) {
    final isStar = action == MarkStarAction.markStar;
    return _boolPatch(isStar ? true : null);
  }

  PatchObject generateAnsweredActionPath() => _boolPatch(true);

  PatchObject generateForwardedActionPath() => _boolPatch(true);

  PatchObject generateUnsubscribeActionPath() => _boolPatch(true);

  PatchObject generateLabelActionPath() => _boolPatch(true);
}
