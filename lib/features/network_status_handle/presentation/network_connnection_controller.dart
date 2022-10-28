import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class NetworkConnectionController extends BaseController {
  final connectivityResult = Rxn<ConnectivityResult>();
  final _imagePaths = Get.find<ImagePaths>();
  final Connectivity _connectivity;
  final AppToast _appToast = Get.find<AppToast>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();

  bool _isEnableShowToastDisconnection = true;

  late StreamSubscription<ConnectivityResult> subscription;

  NetworkConnectionController(this._connectivity);

  @override
  void onReady() {
   subscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
     connectivityResult.value = result;
     if (_isEnableShowToastDisconnection && result == ConnectivityResult.none) {
       _showToastLostConnection();
     }
    }) ;
   super.onReady();
  }

  @override
  void onClose() {
    subscription.cancel();
    super.onClose();
  }

  @override
  void onDone() {}

  void setNetworkConnectivityState(ConnectivityResult newConnectivityResult) {
    connectivityResult.value = newConnectivityResult;
  }

  bool isNetworkConnectionAvailable() {
    return connectivityResult.value != ConnectivityResult.none;
  }

  void _showToastLostConnection() {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).no_internet_connection,
          actionName: AppLocalizations.of(currentContext!).skip,
          onActionClick: () {
            _isEnableShowToastDisconnection = false;
            ToastView.dismiss();
          },
          leadingIcon: SvgPicture.asset(
              _imagePaths.icNotConnection,
              width: 24,
              height: 24,
              fit: BoxFit.fill),
          backgroundColor: AppColor.textFieldErrorBorderColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!),
          infinityToast: true,
      );
    }
  }
}