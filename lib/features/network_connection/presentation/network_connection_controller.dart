import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class NetworkConnectionController extends GetxController {
  final connectivityResult = Rxn<ConnectivityResult>();

  final Connectivity _connectivity;
  final ImagePaths _imagePaths;
  final AppToast _appToast;

  bool _isEnableShowToastDisconnection = true;

  late StreamSubscription<ConnectivityResult> subscription;

  NetworkConnectionController(
    this._connectivity,
    this._imagePaths,
    this._appToast
  );

  @override
  void onInit() {
    super.onInit();
    log('NetworkConnectionController::onInit():');
    _listenNetworkConnectionChanged();
  }

  @override
  void onReady() {
    super.onReady();
    log('NetworkConnectionController::onReady():');
    _getCurrentNetworkConnectionState();
  }

  @override
  void onClose() {
    subscription.cancel();
    super.onClose();
  }

  void _getCurrentNetworkConnectionState() async {
    final currentConnectionResult = await _connectivity.checkConnectivity();
    log('NetworkConnectionController::onReady():_getCurrentNetworkConnectionState: $currentConnectionResult');
    _setNetworkConnectivityState(currentConnectionResult);
    _handleNetworkConnectionState();
  }

  void _listenNetworkConnectionChanged() {
    subscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        log('NetworkConnectionController::_listenNetworkConnectionChanged():onConnectivityChanged: $result');
        _setNetworkConnectivityState(result);
        _handleNetworkConnectionState();
      },
      onError: (error, stackTrace) {
        logError('NetworkConnectionController::_listenNetworkConnectionChanged():error: $error');
        logError('NetworkConnectionController::_listenNetworkConnectionChanged():stackTrace: $stackTrace');
      }
    );
  }

  void _setNetworkConnectivityState(ConnectivityResult newConnectivityResult) {
    connectivityResult.value = newConnectivityResult;
  }

  bool isNetworkConnectionAvailable() {
    return connectivityResult.value != ConnectivityResult.none;
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