import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';

extension KeyWordIdentifierExtension on KeyWordIdentifier {
  static final unsubscribeMail = KeyWordIdentifier('\$unsubscribe');

  String generatePath() {
    return '${PatchObject.keywordsProperty}/$value';
  }

  PatchObject generateReadActionPath(ReadActions readActions) {
    return PatchObject({
      generatePath(): readActions == ReadActions.markAsRead ? true : null
    });
  }

  PatchObject generateMarkStarActionPath(MarkStarAction markStarAction) {
    return PatchObject({
      generatePath(): markStarAction == MarkStarAction.markStar ? true : null
    });
  }

  PatchObject generateAnsweredActionPath() {
    return PatchObject({
      generatePath(): true
    });
  }

  PatchObject generateForwardedActionPath() {
    return PatchObject({
      generatePath(): true
    });
  }

  PatchObject generateUnsubscribeActionPath() {
    return PatchObject({
      generatePath(): true
    });
  }
}