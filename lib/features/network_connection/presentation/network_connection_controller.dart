import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/views/toast/tmail_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class NetworkConnectionController extends GetxController {
  final _connectivityResult = Rxn<ConnectivityResult>();
  final _internetConnectionStatus = Rxn<InternetConnectionStatus>();

  final Connectivity _connectivity;
  final InternetConnectionChecker _internetConnectionChecker;
  final ImagePaths _imagePaths;
  final AppToast _appToast;

  bool _isEnableShowToastDisconnection = true;

  StreamSubscription<ConnectivityResult>? _subscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  NetworkConnectionController(
    this._connectivity,
    this._internetConnectionChecker,
    this._imagePaths,
    this._appToast,
  );

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

  void _getCurrentNetworkConnectionState() async {
    final listConnectionResult = await Future.wait([
      _connectivity.checkConnectivity(),
      if (PlatformInfo.isMobile)
        _internetConnectionChecker.connectionStatus,
    ]);
    log('NetworkConnectionController::_getCurrentNetworkConnectionState():listConnectionResult: $listConnectionResult');

    if (listConnectionResult[0] is ConnectivityResult) {
      _setNetworkConnectivityState(listConnectionResult[0] as ConnectivityResult);
    }

    if (PlatformInfo.isMobile && listConnectionResult[1] is InternetConnectionStatus) {
      _setInternetConnectivityStatus(listConnectionResult[1] as InternetConnectionStatus);
    }

    _handleNetworkConnectionState();
  }

  void _listenNetworkConnectionChanged() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        log('NetworkConnectionController::_listenNetworkConnectionChanged()::onConnectivityChanged: $result');
        _setNetworkConnectivityState(result);
        _handleNetworkConnectionState();
      },
      onError: (error, stackTrace) {
        logError('NetworkConnectionController::_listenNetworkConnectionChanged()::onConnectivityChanged:error: $error | stackTrace: $stackTrace');
      }
    );

    if (PlatformInfo.isMobile) {
      _internetSubscription = _internetConnectionChecker.onStatusChange.listen(
        (status) {
          log('NetworkConnectionController::_listenNetworkConnectionChanged()::onStatusChange: $status');
          _setInternetConnectivityStatus(status);
        },
        onError: (error, stackTrace) {
          logError('NetworkConnectionController::_listenNetworkConnectionChanged()::onStatusChange:error: $error | stackTrace: $stackTrace');
        }
      );
    }
  }

  void _setNetworkConnectivityState(ConnectivityResult newConnectivityResult) {
    _connectivityResult.value = newConnectivityResult;
  }

  void _setInternetConnectivityStatus(InternetConnectionStatus newStatus) {
    _internetConnectionStatus.value = newStatus;
  }

  bool isNetworkConnectionAvailable() {
    if (PlatformInfo.isWeb) {
      return _connectivityResult.value != ConnectivityResult.none;
    } else {
      return _connectivityResult.value != ConnectivityResult.none &&
        _internetConnectionStatus.value == InternetConnectionStatus.connected;
    }
  }

  void _handleNetworkConnectionState() {
    if (PlatformInfo.isWeb) {
      if (_isEnableShowToastDisconnection && !isNetworkConnectionAvailable()) {
        _showToastLostConnection();
      } else {
        ToastView.dismiss();
      }
    }
  }

  void _showToastLostConnection() {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).no_internet_connection,
        actionName: AppLocalizations.of(currentContext!).skip,
        onActionClick: () {
          _isEnableShowToastDisconnection = false;
          ToastView.dismiss();
        },
        leadingSVGIcon: _imagePaths.icNotConnection,
        backgroundColor: AppColor.textFieldErrorBorderColor,
        textColor: Colors.white,
        infinityToast: true,
      );
    }
  }
}