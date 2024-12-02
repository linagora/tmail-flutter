import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_type.dart';

class DeepLinkData with EquatableMixin {
  final DeepLinkActionType actionType;

  DeepLinkData({required this.actionType});

  @override
  List<Object?> get props => [actionType];
}
