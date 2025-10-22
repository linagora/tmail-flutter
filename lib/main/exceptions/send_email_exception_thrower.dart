import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendEmailExceptionThrower extends RemoteExceptionThrower {
  @override
  Future<void> throwException(error, stackTrace) async {
    log('SendEmailExceptionThrower::throwException(): $error | stackTrace: $stackTrace');
    final networkConnectionController = getBinding<NetworkConnectionController>();
    final realtimeNetworkConnectionStatus = await networkConnectionController?.hasInternetConnection();
    if (realtimeNetworkConnectionStatus == false) {
      logError('SendEmailExceptionThrower::throwException(): No realtime network connection');
      throw const NoNetworkError();
    } else {
      handleDioError(error);
    }
  }
}