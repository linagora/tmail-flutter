import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/views/toast/tmail_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class NetworkConnectionController extends GetxController {
  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  final _connectivityResult = Rxn<ConnectivityResult>();

  final Connectivity _connectivity;

  bool _isEnableShowToastDisconnection = true;

  StreamSubscription<ConnectivityResult>? _subscription;

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
    super.onClose();
  }

  Connectivity get connectivity => _connectivity;

  void _getCurrentNetworkConnectionState() async {
    final connectionResult = await _connectivity.checkConnectivity();
    log('NetworkConnectionController::_getCurrentNetworkConnectionState():connectionResult: $connectionResult');
    _setNetworkConnectivityState(connectionResult);
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
  }

  void _setNetworkConnectivityState(ConnectivityResult newConnectivityResult) {
    _connectivityResult.value = newConnectivityResult;
  }

  bool isNetworkConnectionAvailable() => _connectivityResult.value != ConnectivityResult.none;

  void _handleNetworkConnectionState() {
    if (_isEnableShowToastDisconnection && !isNetworkConnectionAvailable()) {
      _showToastLostConnection();
    } else {
      ToastView.dismiss();
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

  Future<bool> hasInternetConnection() async => isNetworkConnectionAvailable();
}