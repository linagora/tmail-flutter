
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';

extension LocalEmailDraftExtension on LocalEmailDraft {
  PresentationLocalEmailDraft toPresentation() {
    return PresentationLocalEmailDraft(
      id: id,
      composerId: composerId,
      savedTime: savedTime,
      email: _parseEmail(email),
      hasRequestReadReceipt: hasRequestReadReceipt,
      isMarkAsImportant: isMarkAsImportant,
      displayMode: ScreenDisplayMode.values.firstWhereOrNull(
        (type) => type.name == displayMode,
      ) ?? ScreenDisplayMode.normal,
      composerIndex: composerIndex,
      draftHash: draftHash,
      actionType: EmailActionType.values.firstWhereOrNull(
        (type) => type.name == actionType,
      ),
      draftEmailId: draftEmailId != null ? EmailId(Id(draftEmailId!)) : null,
    );
  }

  Email? _parseEmail(String? emailJson) {
    if (emailJson == null) return null;
    try {
      return Email.fromJson(jsonDecode(emailJson));
    } catch (e) {
      logError('LocalEmailDraftExtension::_parseEmail:Exception: $e');
      return null;
    }
  }
}