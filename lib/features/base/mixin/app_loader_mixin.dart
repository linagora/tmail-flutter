
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

mixin AppLoaderMixin {

  Widget get loadingWidget {
    return const Center(child: SizedBox(
        width: 24,
        height: 24,
        child: CupertinoActivityIndicator(color: AppColor.colorLoading)));
  }

  Widget get horizontalLoadingWidget {
    return const Center(
        child: LinearProgressIndicator(
          color: AppColor.primaryColor,
          minHeight: 3,
          backgroundColor: AppColor.colorBgMailboxSelected));
  }

  Widget horizontalPercentLoadingWidget(double percent) {
    return Center(
        child: LinearPercentIndicator(
          lineHeight: 3.0,
          percent: percent > 1.0 ? 1.0 : percent,
          barRadius: const Radius.circular(4),
          backgroundColor: AppColor.colorBgMailboxSelected,
          progressColor: AppColor.primaryColor,
        ));
  }
}