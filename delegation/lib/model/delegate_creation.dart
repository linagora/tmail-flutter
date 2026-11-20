import 'package:equatable/equatable.dart';

class DelegateCreation with EquatableMixin {
  final String username;

  DelegateCreation({required this.username});

  Map<String, dynamic> toJson() => {'username': username};

  @override
  List<Object?> get props => [username];
}
