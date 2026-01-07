import 'package:labels/model/label.dart';

class ProvisioningLabel {
  final String displayName;

  ProvisioningLabel(this.displayName);

  Label toLabel() => Label(displayName: displayName);
}
