
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';

mixin AppLoaderMixin {

  Widget get loadingWidget {
    return const Center(child: SizedBox(
        width: 24,
        height: 24,
        child: CupertinoActivityIndicator(color: AppColor.colorLoading)));
  }
}