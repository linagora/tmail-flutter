import 'package:jmap_dart_client/http/converter/email_id_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

part 'composer_persistent_cache.g.dart';

/// Extension of [ComposerCache] with draft-recovery metadata.
///
/// [isCleanClose] `null`/`false` means "restore on next open"; `true` means
/// the composer was dismissed intentionally (send or explicit discard).
/// [timestampMs] selects the most recent snapshot across concurrent sessions.
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  converters: [
    EmailIdNullableConverter(),
  ],
)
class ComposerPersistentCache extends ComposerCache {
  static const _expiryDuration = Duration(hours: 24);

  final bool? isCleanClose;
  final int? timestampMs;

  ComposerPersistentCache({
    super.email,
    super.hasRequestReadReceipt,
    super.isMarkAsImportant,
    super.displayMode,
    super.composerIndex,
    super.composerId,
    super.draftHash,
    super.actionType,
    super.draftEmailId,
    super.templateEmailId,
    this.isCleanClose,
    this.timestampMs,
  });

  factory ComposerPersistentCache.fromJson(Map<String, dynamic> json) =>
      _$ComposerPersistentCacheFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        ..._$ComposerPersistentCacheToJson(this),
      };

  bool get isRestorable => isCleanClose != true && !isExpired && !isEmpty;

  bool get isExpired {
    if (timestampMs == null) return false;
    return DateTime.now().millisecondsSinceEpoch - timestampMs! >
        _expiryDuration.inMilliseconds;
  }

  bool get isEmpty => email == null;

  ComposerPersistentCache copyWith({
    Email? email,
    bool? hasRequestReadReceipt,
    bool? isMarkAsImportant,
    ScreenDisplayMode? displayMode,
    int? composerIndex,
    String? composerId,
    int? draftHash,
    EmailActionType? actionType,
    EmailId? draftEmailId,
    EmailId? templateEmailId,
    bool? isCleanClose,
    int? timestampMs,
  }) =>
      ComposerPersistentCache(
        email: email ?? this.email,
        hasRequestReadReceipt: hasRequestReadReceipt ?? this.hasRequestReadReceipt,
        isMarkAsImportant: isMarkAsImportant ?? this.isMarkAsImportant,
        displayMode: displayMode ?? this.displayMode,
        composerIndex: composerIndex ?? this.composerIndex,
        composerId: composerId ?? this.composerId,
        draftHash: draftHash ?? this.draftHash,
        actionType: actionType ?? this.actionType,
        draftEmailId: draftEmailId ?? this.draftEmailId,
        templateEmailId: templateEmailId ?? this.templateEmailId,
        isCleanClose: isCleanClose ?? this.isCleanClose,
        timestampMs: timestampMs ?? this.timestampMs,
      );

  @override
  List<Object?> get props => [
        ...super.props,
        isCleanClose,
        timestampMs,
      ];
}

extension ComposerPersistentCacheListExtension on Iterable<ComposerCache> {
  ComposerPersistentCache? get newestLocalCache =>
      whereType<ComposerPersistentCache>()
          .fold<ComposerPersistentCache?>(null, (newest, entry) {
        if (newest == null) return entry;
        return (entry.timestampMs ?? 0) > (newest.timestampMs ?? 0)
            ? entry
            : newest;
      });
}
