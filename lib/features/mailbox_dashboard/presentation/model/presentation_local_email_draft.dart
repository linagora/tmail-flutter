import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';

class PresentationLocalEmailDraft with EquatableMixin {

  final String id;
  final String composerId;
  final DateTime savedTime;
  final Email? email;
  final bool? hasRequestReadReceipt;
  final bool? isMarkAsImportant;
  final ScreenDisplayMode? displayMode;
  final int? composerIndex;

  PresentationLocalEmailDraft({
    required this.id,
    required this.composerId,
    required this.savedTime,
    this.email,
    this.hasRequestReadReceipt,
    this.isMarkAsImportant,
    this.displayMode,
    this.composerIndex,
  });

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
  ];
}
