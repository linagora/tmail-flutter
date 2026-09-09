import 'package:equatable/equatable.dart';

import 'workplace_action_config.dart';
import 'workplace_theme.dart';

/// The picker shape an intent asks Drive for: which actions to offer and how
/// to render them.
class WorkplaceIntentConfig with EquatableMixin {
  final WorkplaceActionConfig addAsLink;

  /// Null hides the attachment button.
  final WorkplaceActionConfig? addAsAttachment;
  final WorkplaceTheme theme;

  const WorkplaceIntentConfig({
    required this.addAsLink,
    this.addAsAttachment,
    required this.theme,
  });

  @override
  List<Object?> get props => [addAsLink, addAsAttachment, theme];
}
