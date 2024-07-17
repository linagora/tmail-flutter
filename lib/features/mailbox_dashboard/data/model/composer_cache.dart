import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';

part 'composer_cache.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ComposerCache with EquatableMixin {

  final Email? email;
  final Identity? identity;
  final bool? hasRequestReadReceipt;
  final ScreenDisplayMode displayMode;

  ComposerCache({
    this.email,
    this.identity,
    this.hasRequestReadReceipt,
    this.displayMode = ScreenDisplayMode.normal
  });

  factory ComposerCache.fromJson(Map<String, dynamic> json) => _$ComposerCacheFromJson(json);

  Map<String, dynamic> toJson() => _$ComposerCacheToJson(this);

  @override
  List<Object?> get props => [
    email,
    identity,
    hasRequestReadReceipt,
    displayMode
  ];
}
