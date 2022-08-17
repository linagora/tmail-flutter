
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/configuration/configuration_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/configuration/vacation/vacation_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/configuration_tab_type.dart';

class ConfigurationView extends GetWidget<ConfigurationController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  ConfigurationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
      body: Container(
        margin: _responsiveUtils.isWebDesktop(context)
          ? const EdgeInsets.all(24)
          : EdgeInsets.zero,
        color: _responsiveUtils.isWebDesktop(context) ? null : Colors.white,
        decoration: _responsiveUtils.isWebDesktop(context)
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                color: Colors.white)
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              _responsiveUtils.isWebDesktop(context) ? 20 : 0),
          child: Padding(
            padding: const EdgeInsets.only(
                left: BuildUtils.isWeb ? 10 : 0,
                right: 10,
                bottom: 10),
            child: DefaultTabController(
                initialIndex: 0,
                length: 1,
                child: Scaffold(
                  appBar: TabBar(
                      unselectedLabelColor: AppColor.colorTextButtonHeaderThread,
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: AppColor.colorTextButtonHeaderThread),
                      labelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColor.primaryColor),
                      labelColor: AppColor.primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      isScrollable: true,
                      indicator: const CustomIndicator(
                        indicatorHeight: 4,
                        indicatorColor: AppColor.primaryColor,
                        indicatorSize: CustomIndicatorSize.full),
                      onTap: (index) {},
                      tabs: ConfigurationTabType.values
                        .map((tab) => Tab(text: tab.getTitle(context)))
                        .toList()
                  ),
                  body: Column(children: [
                    const Divider(color: AppColor.colorDividerMailbox, height: 0.5, thickness: 0.2),
                    Expanded(child: TabBarView(
                      children: [
                        VacationView(),
                      ],
                    ))
                  ]),
                )
            ),
          ),
        ),
      ),
    );
  }
}