import 'package:equatable/equatable.dart';

class RecentLoginUsername with EquatableMixin {
  final String username;
  final DateTime creationDate;

  RecentLoginUsername(this.username, this.creationDate);

  factory RecentLoginUsername.now(String username) => RecentLoginUsername(username, DateTime.now());

  @override
  List<Object?> get props => [ username, creationDate ];
}