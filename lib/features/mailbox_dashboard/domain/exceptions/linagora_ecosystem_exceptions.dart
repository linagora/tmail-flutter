import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundLinagoraEcosystem extends AppBaseException {
  NotFoundLinagoraEcosystem([super.message]);

  @override
  String get exceptionName => 'NotFoundLinagoraEcosystem';
}
