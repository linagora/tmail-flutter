import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/email_rules_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/widgets/list_email_rules_widget.dart';

class EmailRulesView extends GetWidget<EmailRulesController> {
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  EmailRulesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
      body: Container(
        width: double.infinity,
        margin: _responsiveUtils.isWebDesktop(context)
            ? const EdgeInsets.only(left: 48, right: 24, top: 24, bottom: 24)
            : EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              _responsiveUtils.isWebDesktop(context) ? 20 : 0),
          child: Padding(
            padding: EdgeInsets.only(
                left: _responsiveUtils.isWebDesktop(context) ? 24 : 10,
                top: 24,
                right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmailRulesHeaderWidget(
                  imagePaths: _imagePaths,
                  responsiveUtils: _responsiveUtils,
                  createRule: () {
                    //TODO: createRule
                  },
                ),
                const SizedBox(height: 22),
                const Expanded(child: ListEmailRulesWidget())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
