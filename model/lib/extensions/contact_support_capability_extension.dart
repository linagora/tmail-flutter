
import 'package:model/support/contact_support_capability.dart';

extension ContactSupportCapabilityExtension on ContactSupportCapability {

  bool get isMailAddressSupported =>
      supportMailAddress?.trim().isNotEmpty == true;

  bool get isHttpLinkSupported =>
      httpLink?.trim().isNotEmpty == true;
}