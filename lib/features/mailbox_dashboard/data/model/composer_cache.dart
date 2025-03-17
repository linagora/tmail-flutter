import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';

part 'composer_cache.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ComposerCache with EquatableMixin {

  final Email? email;
  final bool? hasRequestReadReceipt;
  final bool? isMarkAsImportant;
  final ScreenDisplayMode displayMode;
  final int? composerIndex;
  final String? composerId;

  ComposerCache({
    this.email,
    this.hasRequestReadReceipt,
    this.isMarkAsImportant,
    this.displayMode = ScreenDisplayMode.normal,
    this.composerIndex,
    this.composerId,
  });

  factory ComposerCache.fromJson(Map<String, dynamic> json) => _$ComposerCacheFromJson(json);

  Map<String, dynamic> toJson() => _$ComposerCacheToJson(this);

  @override
  List<Object?> get props => [
    email,
    hasRequestReadReceipt,
    isMarkAsImportant,
    displayMode,
    composerIndex,
    composerId,
  ];
}
