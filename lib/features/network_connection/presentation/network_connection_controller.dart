import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkConnectionController extends GetxController {
  static const Duration _timeoutInternetConnection = Duration(milliseconds: 5000);
  static const Duration _timeIntervalInternetConnection = Duration(milliseconds: 5000);

  final _connectivityResult = Rxn<List<ConnectivityResult>>();
  final _internetConnectionStatus = Rxn<InternetConnectionStatus>();

  final Connectivity _connectivity;

  final _internetConnectionChecker = InternetConnectionChecker.createInstance(
    checkTimeout: _timeoutInternetConnection,
    checkInterval: _timeIntervalInternetConnection
  );

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  NetworkConnectionController(this._connectivity);

  @override
  void onInit() {
    super.onInit();
    _listenNetworkConnectionChanged();
  }

  @override
  void onReady() {
    super.onReady();
    _getCurrentNetworkConnectionState();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    if (PlatformInfo.isMobile) {
      _internetSubscription?.cancel();
    }
    super.onClose();
  }

  Connectivity get connectivity => _connectivity;

  void _getCurrentNetworkConnectionState() async {
    final listConnectionResult = await Future.wait([
      _connectivity.checkConnectivity(),
      _internetConnectionChecker.connectionStatus,
    ]);
    log('NetworkConnectionController::_getCurrentNetworkConnectionState():listConnectionResult: $listConnectionResult');

    if (listConnectionResult[0] is List<ConnectivityResult>) {
      _setNetworkConnectivityState(listConnectionResult[0] as List<ConnectivityResult>);
    }

    if (listConnectionResult[1] is InternetConnectionStatus) {
      _setInternetConnectivityStatus(listConnectionResult[1] as InternetConnectionStatus);
    }
  }

  void _listenNetworkConnectionChanged() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        log('NetworkConnectionController::_listenNetworkConnectionChanged()::onConnectivityChanged: $result');
        _setNetworkConnectivityState(result);
      },
      onError: (error, stackTrace) {
        logWarning('NetworkConnectionController::_listenNetworkConnectionChanged()::onConnectivityChanged:error: $error | stackTrace: $stackTrace');
      }
    );

    _internetSubscription = _internetConnectionChecker.onStatusChange.listen(
      (status) {
        log('NetworkConnectionController::_listenNetworkConnectionChanged()::onStatusChange: $status');
        _setInternetConnectivityStatus(status);
      },
      onError: (error, stackTrace) {
        logWarning('NetworkConnectionController::_listenNetworkConnectionChanged()::onStatusChange:error: $error | stackTrace: $stackTrace');
      }
    );
  }

  void _setNetworkConnectivityState(List<ConnectivityResult> newConnectivityResult) {
    _connectivityResult.value = newConnectivityResult;
  }

  void _setInternetConnectivityStatus(InternetConnectionStatus newStatus) {
    _internetConnectionStatus.value = newStatus;
  }

  bool isNetworkConnectionAvailable() {
    return _internetConnectionStatus.value == InternetConnectionStatus.connected ||
        (_connectivityResult.value != null &&
         !_connectivityResult.value!.contains(ConnectivityResult.none));
  }

  Future<bool> hasInternetConnection() {
    return _internetConnectionChecker.hasConnection;
  }
}