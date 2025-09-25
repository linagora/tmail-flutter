import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';

class PresentationLocalEmailDraft with EquatableMixin {

  final String id;
  final String composerId;
  final DateTime savedTime;
  final Email? email;
  final bool? hasRequestReadReceipt;
  final bool? isMarkAsImportant;
  final ScreenDisplayMode displayMode;
  final int? composerIndex;
  final int? draftHash;
  final EmailActionType? actionType;
  final EmailId? draftEmailId;

  PresentationLocalEmailDraft({
    required this.id,
    required this.composerId,
    required this.savedTime,
    this.email,
    this.hasRequestReadReceipt,
    this.isMarkAsImportant,
    this.displayMode = ScreenDisplayMode.normal,
    this.composerIndex,
    this.draftHash,
    this.actionType,
    this.draftEmailId,
  });

  PresentationLocalEmailDraft copyWith({
    String? id,
    String? composerId,
    DateTime? savedTime,
    Email? email,
    bool? hasRequestReadReceipt,
    bool? isMarkAsImportant,
    ScreenDisplayMode? displayMode,
    int? composerIndex,
    int? draftHash,
    EmailActionType? actionType,
    EmailId? draftEmailId,
  }) => PresentationLocalEmailDraft(
    id: id ?? this.id,
    composerId: composerId ?? this.composerId,
    savedTime: savedTime ?? this.savedTime,
    email: email ?? this.email,
    hasRequestReadReceipt: hasRequestReadReceipt ?? this.hasRequestReadReceipt,
    isMarkAsImportant: isMarkAsImportant ?? this.isMarkAsImportant,
    displayMode: displayMode ?? this.displayMode,
    composerIndex: composerIndex ?? this.composerIndex,
    draftHash: draftHash ?? this.draftHash,
    actionType: actionType ?? this.actionType,
    draftEmailId: draftEmailId ?? this.draftEmailId,
  );

  @override
  List<Object?> get props => [
    id,
    savedTime,
    email,
    hasRequestReadReceipt,
    isMarkAsImportant,
    displayMode,
    composerIndex,
    composerId,
    draftHash,
    actionType,
    draftEmailId,
  ];
}
