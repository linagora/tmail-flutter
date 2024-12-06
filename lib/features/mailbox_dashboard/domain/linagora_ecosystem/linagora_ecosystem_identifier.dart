
import 'package:equatable/equatable.dart';

class LinagoraEcosystemIdentifier with EquatableMixin {
  static final linShareApiUrl = LinagoraEcosystemIdentifier('linShareApiUrl');
  static final linToApiUrl = LinagoraEcosystemIdentifier('linToApiUrl');
  static final twakeApiUrl = LinagoraEcosystemIdentifier('twakeApiUrl');
  static final linToApiKey = LinagoraEcosystemIdentifier('linToApiKey');
  static final mobileApps = LinagoraEcosystemIdentifier('mobileApps');
  static final twakeDrive = LinagoraEcosystemIdentifier('Twake Drive');
  static final twakeChat = LinagoraEcosystemIdentifier('Twake Chat');
  static final twakeSync = LinagoraEcosystemIdentifier('Twake Sync');
  static final linShare = LinagoraEcosystemIdentifier('LinShare');

  final String value;

  LinagoraEcosystemIdentifier(this.value);

  @override
  List<Object?> get props => [value];
}