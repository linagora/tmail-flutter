import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class ThreadDetailArguments with EquatableMixin {
  final ThreadId threadId;

  const ThreadDetailArguments({required this.threadId});

  @override
  List<Object?> get props => [threadId];
}