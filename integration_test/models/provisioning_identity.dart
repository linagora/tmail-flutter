import 'package:jmap_dart_client/jmap/identities/identity.dart';

class ProvisioningIdentity {
  final Identity identity;
  final bool isDefault;

  ProvisioningIdentity({
    required this.identity,
    this.isDefault = false,
  });
}