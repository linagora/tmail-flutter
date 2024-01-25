import 'package:equatable/equatable.dart';

class OpenIdConfiguration with EquatableMixin {
  final String? issuer;
  final String? tokenEndpoint;
  final String? endSessionEndpoint;

  OpenIdConfiguration({
    required this.issuer,
    required this.tokenEndpoint,
    required this.endSessionEndpoint
  });

  @override
  List<Object?> get props => [issuer, tokenEndpoint, endSessionEndpoint];
}