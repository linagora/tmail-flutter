import 'package:equatable/equatable.dart';

class CompanyServerLoginInfo with EquatableMixin {
  final String email;

  const CompanyServerLoginInfo({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}
