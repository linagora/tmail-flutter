
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

Future<dynamic> push(String routeName, {dynamic arguments}) async {
  return Get.toNamed(routeName, arguments: arguments);
}

Future<dynamic> pushAndPop(String routeName, {dynamic arguments}) async {
  return Get.offNamed(routeName, arguments: arguments);
}

Future<dynamic> popAndPush(String routeName, {dynamic arguments}) async {
  return Get.offAndToNamed(routeName, arguments: arguments);
}

Future<dynamic> pushAndPopAll(String routeName, {dynamic arguments}) async {
  return Get.offAllNamed(routeName, arguments: arguments);
}

void popBack({dynamic result, bool closeOverlays = false}) {
  Get.back(closeOverlays: closeOverlays, result: result);
}

bool canBack(BuildContext context) {
  return Navigator.of(context).canPop();
}

BuildContext? get currentContext => Get.context;

BuildContext? get currentOverlayContext => Get.overlayContext;

T? getBinding<T>({String? tag}) {
  if (Get.isRegistered<T>(tag: tag)) {
    return Get.find<T>(tag: tag);
  } else {
    return null;
  }
}