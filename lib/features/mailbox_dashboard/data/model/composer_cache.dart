import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';

class ComposerCache with EquatableMixin {

  final Email? email;
  final Identity? identity;
  final bool? readReceipentEnabled;
  final ScreenDisplayMode displayMode;

  ComposerCache({
    required this.displayMode,
    this.email,
    this.identity,
    this.readReceipentEnabled,
  });

  @override
  List<Object?> get props => [
    email,
    identity,
    readReceipentEnabled
  ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email?.toJson(),
      'identity': identity?.toJson(),
      'readReceipentEnabled': readReceipentEnabled,
      'displayMode': displayMode.toJson()
    };
  }

  factory ComposerCache.fromJson(Map<String, dynamic> map) {
    return ComposerCache(
      displayMode: ScreenDisplayMode.fromJson(map['displayMode'] ?? ''),
      email: map['email'] != null ? Email.fromJson(map['email']) : null,
      identity: map['identity'] != null ? Identity.fromJson(map['identity']) : null,
      readReceipentEnabled: map['readReceipentEnabled'] as bool?
    );
  }
}
