import 'package:equatable/equatable.dart';

class FCMTokenDto with EquatableMixin {
  final String token;
  final String accountId;

  FCMTokenDto(
    this.token,
    this.accountId,
  );

  @override
  List<Object?> get props => [
    token,
    accountId,
  ];
}
