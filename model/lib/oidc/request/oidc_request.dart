
import 'package:equatable/equatable.dart';

class OIDCRequest with EquatableMixin {

  final String baseUrl;
  final String resourceUrl = 'https://gateway.upn.integration-open-paas.org';
  final String relUrl = 'http://openid.net/specs/connect/1.0/issuer';

  OIDCRequest({required this.baseUrl});

  @override
  List<Object?> get props => [baseUrl, resourceUrl, relUrl];
}