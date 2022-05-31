enum AuthenticationType {
  basic,
  oidc,
  none
}

extension AuthenticationTypeExtension on AuthenticationType {
  String asString() {
    switch (this) {
      case AuthenticationType.oidc:
        return 'oidc';
      case AuthenticationType.basic:
        return 'basic';
      default:
        return 'none';
    }
  }
}