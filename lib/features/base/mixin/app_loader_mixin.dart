
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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

  Widget circularPercentLoadingWidget(double percent) {
    return Center(
        child: CircularPercentIndicator(
          percent: percent > 1.0 ? 1.0 : percent,
          backgroundColor: AppColor.colorBgMailboxSelected,
          progressColor: AppColor.primaryColor,
          lineWidth: 3,
          radius: 14,
        )
    );
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

  Widget loadingWidgetWithSizeColor({double? size, Color? color}) {
    return Center(child: SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(
            color: color ?? AppColor.colorLoading)));
  }
}