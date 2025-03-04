
import 'package:model/oidc/response/oidc_link_dto.dart';
import 'package:model/oidc/response/oidc_response.dart';

class BaseUrlOidcResponse extends OIDCResponse {

  BaseUrlOidcResponse(Uri baseUri) : super(
    '',
    [
      OIDCLinkDto(baseUri, baseUri)
    ],
  );
}

