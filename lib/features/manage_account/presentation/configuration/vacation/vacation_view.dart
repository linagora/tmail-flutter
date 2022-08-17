
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/border_button_field.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/configuration/vacation/vacation_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/configuration/vacation/widgets/vacation_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:toggle_switch/toggle_switch.dart';

class VacationView extends GetWidget<VacationController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  VacationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: ResponsiveWidget(
          responsiveUtils: _responsiveUtils,
          desktop: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 200,
                      color: Colors.white,
                      child: Text(
                        AppLocalizations.of(context).vacationResponder,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black))),
                    const SizedBox(width: 16),
                    ToggleSwitch(
                      minWidth: 150.0,
                      cornerRadius: 20.0,
                      activeBgColors: const [[Colors.green], [Colors.redAccent]],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      initialLabelIndex: 1,
                      totalSwitches: VacationResponderStatus.values.length,
                      labels: VacationResponderStatus.values
                          .map((status) => status.getTitle(context))
                          .toList(),
                      radiusStyle: true,
                      onToggle: (index) {
                        log('VacationView::build():ToggleSwitch:index: $index');
                        final newStatus = index == 0
                            ? VacationResponderStatus.activated
                            : VacationResponderStatus.deactivated;
                        controller.updateVacationPresentation(newStatus: newStatus);
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Obx(() => AbsorbPointer(
                    absorbing: controller.isVacationDeactivated,
                    child: Row(children: [
                      Container(
                        width: 200,
                        color: Colors.white,
                        child: Text(
                          AppLocalizations.of(context).startDate,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  controller.isVacationDeactivated ? 0.5 : 1.0)))),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => BorderButtonField<DateTime>(
                          value: controller.vacationPresentation.value.startDate,
                          mouseCursor: SystemMouseCursors.text,
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  controller.isVacationDeactivated ? 0.5 : 1.0)),
                          hintText: AppLocalizations.of(context).startDate,
                          icon: const Icon(
                              Icons.date_range,
                              color: AppColor.colorIconTextField,
                              size: 20),
                          tapActionCallback: (value) =>
                              controller.selectDate(context, DateType.start, value)))),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => BorderButtonField<TimeOfDay>(
                          value: controller.vacationPresentation.value.startTime,
                          mouseCursor: SystemMouseCursors.text,
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  controller.isVacationDeactivated ? 0.5 : 1.0)),
                          hintText: AppLocalizations.of(context).noStartTime,
                          icon: const Icon(
                              Icons.timer,
                              color: AppColor.colorIconTextField,
                              size: 20),
                          tapActionCallback: (value) =>
                              controller.selectTime(context, DateType.start, value)))),
                    ]),
                  )),
                  const SizedBox(height: 20),
                  Obx(() => AbsorbPointer(
                    absorbing: controller.isVacationDeactivated,
                    child: Container(
                      width: 200,
                      color: Colors.white,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColor.primaryColor.withOpacity(
                            controller.isVacationDeactivated ? 0.5 : 1.0),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: controller.vacationPresentation.value.vacationStopEnabled,
                        onChanged: (value) =>
                            controller.updateVacationPresentation(vacationStopEnabled: value),
                        title: Text(AppLocalizations.of(context).vacationStopsAt,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    controller.isVacationDeactivated ? 0.5 : 1.0))),
                      ),
                    ),
                  )),
                  Obx(() => AbsorbPointer(
                    absorbing: !controller.canChangeEndDate,
                    child: Row(children: [
                      Container(
                        width: 200,
                        color: Colors.white,
                        child: Text(
                          AppLocalizations.of(context).endDate,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  !controller.canChangeEndDate ? 0.5 : 1.0)))),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => BorderButtonField<DateTime>(
                          value: controller.vacationPresentation.value.endDate,
                          mouseCursor: SystemMouseCursors.text,
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  !controller.canChangeEndDate ? 0.5 : 1.0)),
                          hintText: AppLocalizations.of(context).noEndDate,
                          icon: const Icon(
                              Icons.date_range,
                              color: AppColor.colorIconTextField,
                              size: 20),
                          tapActionCallback: (value) =>
                              controller.selectDate(context, DateType.end, value)))),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => BorderButtonField<TimeOfDay>(
                          value: controller.vacationPresentation.value.endTime,
                          mouseCursor: SystemMouseCursors.text,
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  !controller.canChangeEndDate ? 0.5 : 1.0)),
                          hintText: AppLocalizations.of(context).noEndTime,
                          icon: const Icon(
                              Icons.timer,
                              color: AppColor.colorIconTextField,
                              size: 20),
                          tapActionCallback: (value) =>
                              controller.selectTime(context, DateType.end, value)))),
                    ])
                  )),
                  const SizedBox(height: 20),
                  Obx(() => AbsorbPointer(
                    absorbing: controller.isVacationDeactivated,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 200,
                        color: Colors.white,
                        child: Text(
                            AppLocalizations.of(context).messageBody,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    controller.isVacationDeactivated ? 0.5 : 1.0)))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMessageBodyWidget(
                          context,
                          controller.isVacationDeactivated ? 0.5 : 1.0))
                    ]),
                  )),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: buildTextButton(
                        AppLocalizations.of(context).save,
                        width: 128,
                        height: 44,
                        radius: 10,
                        onTap: () => controller.saveVacation(context)),
                  )
                ]
            ),
          ),
          mobile: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_responsiveUtils.isPortraitMobile(context))
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        AppLocalizations.of(context).vacationResponder,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                    const SizedBox(height: 16),
                    ToggleSwitch(
                      minWidth: 150.0,
                      cornerRadius: 20.0,
                      activeBgColors: const [[Colors.green], [Colors.redAccent]],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      initialLabelIndex: 1,
                      totalSwitches: VacationResponderStatus.values.length,
                      labels: VacationResponderStatus.values
                          .map((status) => status.getTitle(context))
                          .toList(),
                      radiusStyle: true,
                      onToggle: (index) {
                        log('VacationView::build():ToggleSwitch:index: $index');
                        final newStatus = index == 0
                            ? VacationResponderStatus.activated
                            : VacationResponderStatus.deactivated;
                        controller.updateVacationPresentation(newStatus: newStatus);
                      },
                    )
                  ])
                else
                  Row(children: [
                    Expanded(
                      child: Text(
                          AppLocalizations.of(context).vacationResponder,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black)),
                    ),
                    const SizedBox(width: 16),
                    ToggleSwitch(
                      minWidth: 150.0,
                      cornerRadius: 20.0,
                      activeBgColors: const [[Colors.green], [Colors.redAccent]],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      initialLabelIndex: 1,
                      totalSwitches: VacationResponderStatus.values.length,
                      labels: VacationResponderStatus.values
                          .map((status) => status.getTitle(context))
                          .toList(),
                      radiusStyle: true,
                      onToggle: (index) {
                        log('VacationView::build():ToggleSwitch:index: $index');
                        final newStatus = index == 0
                            ? VacationResponderStatus.activated
                            : VacationResponderStatus.deactivated;
                        controller.updateVacationPresentation(newStatus: newStatus);
                      },
                    )
                  ]),
                const SizedBox(height: 20),
                Obx(() => AbsorbPointer(
                  absorbing: controller.isVacationDeactivated,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        AppLocalizations.of(context).startDate,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black.withOpacity(
                                controller.isVacationDeactivated ? 0.5 : 1.0))),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: Obx(() => BorderButtonField<DateTime>(
                          value: controller.vacationPresentation.value.startDate,
                          mouseCursor: SystemMouseCursors.text,
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  controller.isVacationDeactivated ? 0.5 : 1.0)),
                          hintText: AppLocalizations.of(context).startDate,
                          icon: const Icon(
                              Icons.date_range,
                              color: AppColor.colorIconTextField,
                              size: 20),
                          tapActionCallback: (value) =>
                              controller.selectDate(context, DateType.start, value)))),
                      const SizedBox(width: 16),
                      Expanded(child: Obx(() => BorderButtonField<TimeOfDay>(
                          value: controller.vacationPresentation.value.startTime,
                          mouseCursor: SystemMouseCursors.text,
                          textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  controller.isVacationDeactivated ? 0.5 : 1.0)),
                          hintText: AppLocalizations.of(context).noStartTime,
                          icon: const Icon(
                              Icons.timer,
                              color: AppColor.colorIconTextField,
                              size: 20),
                          tapActionCallback: (value) =>
                              controller.selectTime(context, DateType.start, value))))
                    ]),
                  ]),
                )),
                const SizedBox(height: 20),
                Obx(() => AbsorbPointer(
                  absorbing: controller.isVacationDeactivated,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColor.primaryColor.withOpacity(
                        controller.isVacationDeactivated ? 0.5 : 1.0),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: controller.vacationPresentation.value.vacationStopEnabled,
                    onChanged: (value) =>
                        controller.updateVacationPresentation(vacationStopEnabled: value),
                    title: Text(AppLocalizations.of(context).vacationStopsAt,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black.withOpacity(
                                controller.isVacationDeactivated ? 0.5 : 1.0))),
                  ),
                )),
                Obx(() => AbsorbPointer(
                    absorbing: !controller.canChangeEndDate,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                          AppLocalizations.of(context).endDate,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(
                                  !controller.canChangeEndDate ? 0.5 : 1.0))),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: Obx(() => BorderButtonField<DateTime>(
                            value: controller.vacationPresentation.value.endDate,
                            mouseCursor: SystemMouseCursors.text,
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    !controller.canChangeEndDate ? 0.5 : 1.0)),
                            hintText: AppLocalizations.of(context).noEndDate,
                            icon: const Icon(
                                Icons.date_range,
                                color: AppColor.colorIconTextField,
                                size: 20),
                            tapActionCallback: (value) =>
                                controller.selectDate(context, DateType.end, value)))),
                        const SizedBox(width: 16),
                        Expanded(child: Obx(() => BorderButtonField<TimeOfDay>(
                            value: controller.vacationPresentation.value.endTime,
                            mouseCursor: SystemMouseCursors.text,
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    !controller.canChangeEndDate ? 0.5 : 1.0)),
                            hintText: AppLocalizations.of(context).noEndTime,
                            icon: const Icon(
                                Icons.timer,
                                color: AppColor.colorIconTextField,
                                size: 20),
                            tapActionCallback: (value) =>
                                controller.selectTime(context, DateType.end, value))))
                      ]),
                    ])
                )),
                const SizedBox(height: 20),
                Obx(() => AbsorbPointer(
                  absorbing: controller.isVacationDeactivated,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        AppLocalizations.of(context).messageBody,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black.withOpacity(
                                controller.isVacationDeactivated ? 0.5 : 1.0))),
                    const SizedBox(height: 16),
                    _buildMessageBodyWidget(
                        context,
                        controller.isVacationDeactivated ? 0.5 : 1.0)
                  ]),
                )),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: buildTextButton(
                      AppLocalizations.of(context).save,
                      width: 128,
                      height: 44,
                      radius: 10,
                      onTap: () => controller.saveVacation(context)),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBodyWidget(BuildContext context, double opacity) {
    return (TextFieldBuilder()
      ..key(const Key('message_body_editor'))
      ..cursorColor(Colors.black)
      ..addController(controller.messageBodyEditorController)
      ..textStyle(TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.black.withOpacity(opacity),
          fontSize: 16))
      ..textDecoration((VacationInputDecorationBuilder()
          ..setContentPadding(const EdgeInsets.symmetric(
              vertical: BuildUtils.isWeb ? 16 : 12,
              horizontal: 12))
          ..setHintStyle(TextStyle(
              color: AppColor.colorHintInputCreateMailbox.withOpacity(opacity),
              fontSize: 16))
          ..setHintText(AppLocalizations.of(context).hintMessageBodyVacation))
        .build())
      ..minLines(8)
      ..maxLines(null))
    .build();
  }
}