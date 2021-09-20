import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/important_action.dart';
import 'package:model/email/read_actions.dart';

extension KeyWordIdentifierExtension on KeyWordIdentifier {
  String _generatePath() {
    return '${PatchObject.keywordsProperty}/$value';
  }

  PatchObject generateReadActionPath(ReadActions readActions) {
    return PatchObject({
      _generatePath(): readActions == ReadActions.markAsRead ? true : null
    });
  }

  PatchObject generateImportantActionPath(ImportantAction importantAction) {
    return PatchObject({
      _generatePath(): importantAction == ImportantAction.markStar ? true : null
    });
  }
}