
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

Future<dynamic> push(String routeName, {dynamic arguments}) async {
  return Get.toNamed(routeName, arguments: arguments);
}

Future<dynamic> pushAndPop(String routeName, {dynamic arguments}) async {
  return Get.offNamed(routeName, arguments: arguments);
}

Future<dynamic> pushAndPopAll(String routeName, {dynamic arguments}) async {
  return Get.offAllNamed(routeName, arguments: arguments);
}

void popBack({dynamic result}) {
  Get.back(result: result);
}

bool canBack(BuildContext context) {
  return Navigator.of(context).canPop();
}

BuildContext? get currentContext => Get.context;

BuildContext? get currentOverlayContext => Get.overlayContext;