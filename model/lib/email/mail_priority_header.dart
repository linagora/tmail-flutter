
import 'package:equatable/equatable.dart';

class MailPriorityHeader with EquatableMixin {
  static const String firstXPriority = '1';
  static const String highImportance = 'high';
  static const String urgentPriority = 'urgent';

  final String? xPriority;
  final String? importance;
  final String? priority;

  MailPriorityHeader({
    this.xPriority,
    this.importance,
    this.priority,
  });

  @override
  List<Object?> get props => [
    xPriority,
    importance,
    priority,
  ];
}