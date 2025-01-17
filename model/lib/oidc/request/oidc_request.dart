
import 'package:equatable/equatable.dart';

class OIDCRequest with EquatableMixin {

  final String baseUrl;
  final String resourceUrl;
  static const String relUrl = 'http://openid.net/specs/connect/1.0/issuer';
  final bool acceptSelfSigned;

  OIDCRequest({required this.baseUrl, required this.resourceUrl, this.acceptSelfSigned = false});

  @override
  List<Object?> get props => [baseUrl, resourceUrl, relUrl, acceptSelfSigned];
}