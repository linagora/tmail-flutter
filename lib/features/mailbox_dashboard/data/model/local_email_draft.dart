import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/email_id_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';

part 'local_email_draft.g.dart';

@JsonSerializable(
    explicitToJson: true,
    includeIfNull: false,
    converters: [
      EmailIdNullableConverter(),
    ]
)
class LocalEmailDraft with EquatableMixin {

  final String? id;
  final DateTime? timeStamp;
  final Email? email;
  final bool? hasRequestReadReceipt;
  final bool? isMarkAsImportant;
  final ScreenDisplayMode displayMode;
  final int? composerIndex;
  final String? composerId;
  final int? draftHash;
  final EmailActionType? actionType;
  final EmailId? draftEmailId;
  final EmailId? templateEmailId;

  LocalEmailDraft({
    this.id,
    this.timeStamp,
    this.email,
    this.hasRequestReadReceipt,
    this.isMarkAsImportant,
    this.displayMode = ScreenDisplayMode.normal,
    this.composerIndex,
    this.composerId,
    this.draftHash,
    this.actionType,
    this.draftEmailId,
    this.templateEmailId,
  });

  factory LocalEmailDraft.fromJson(Map<String, dynamic> json) => _$LocalEmailDraftFromJson(json);

  Map<String, dynamic> toJson() => _$LocalEmailDraftToJson(this);

  @override
  List<Object?> get props => [
    id,
    timeStamp,
    email,
    hasRequestReadReceipt,
    isMarkAsImportant,
    displayMode,
    composerIndex,
    composerId,
    draftHash,
    actionType,
    draftEmailId,
    templateEmailId,
  ];
}
