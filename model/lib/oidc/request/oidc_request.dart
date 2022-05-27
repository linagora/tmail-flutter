
import 'package:equatable/equatable.dart';

class OIDCRequest with EquatableMixin {

  final String baseUrl;
  final String resourceUrl;
  static const String relUrl = 'http://openid.net/specs/connect/1.0/issuer';

  OIDCRequest({required this.baseUrl, required this.resourceUrl});

  @override
  List<Object?> get props => [baseUrl, resourceUrl, relUrl];
}