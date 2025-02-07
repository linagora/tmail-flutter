
import 'package:equatable/equatable.dart';

class MailPriorityHeader with EquatableMixin {
  final String? xPriority;
  final String? importance;
  final String? priority;

  MailPriorityHeader({
    this.xPriority,
    this.importance,
    this.priority,
  });

  factory MailPriorityHeader.asImportant() => MailPriorityHeader(
    xPriority: '1',
    importance: 'high',
    priority: 'urgent',
  );

  @override
  List<Object?> get props => [
    xPriority,
    importance,
    priority,
  ];
}