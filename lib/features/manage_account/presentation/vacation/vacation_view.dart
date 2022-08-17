
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/border_button_field.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_input_decoration_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class VacationView extends GetWidget<VacationController> {

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();

  VacationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _responsiveUtils.isWebDesktop(context)
          ? AppColor.colorBgDesktop
          : Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          margin: _responsiveUtils.isWebDesktop(context)
              ? const EdgeInsets.all(24)
              : EdgeInsets.zero,
          decoration: _responsiveUtils.isWebDesktop(context)
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                  color: Colors.white)
              : null,
          padding: _getPaddingView(context),
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
                      Obx(() {
                        return Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  controller.updateVacationPresentation(newStatus: VacationResponderStatus.deactivated);
                                },
                                child: Text(AppLocalizations.of(context).deactivated,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black.withOpacity(
                                          controller.isVacationDeactivated ? 1.0 : 0.3))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3, right: 16, left: 16),
                              child: InkWell(
                                onTap: () {
                                  final newStatus = controller.isVacationDeactivated
                                      ? VacationResponderStatus.activated
                                      : VacationResponderStatus.deactivated;
                                  controller.updateVacationPresentation(newStatus: newStatus);
                                },
                                child: SvgPicture.asset(
                                    controller.isVacationDeactivated
                                        ? _imagePaths.icSwitchOff
                                        : _imagePaths.icSwitchOn,
                                    fit: BoxFit.fill,
                                    width: 24,
                                    height: 24)),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  controller.updateVacationPresentation(newStatus: VacationResponderStatus.activated);
                                },
                                child: Text(AppLocalizations.of(context).activated,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black.withOpacity(
                                          controller.isVacationDeactivated ? 0.3 : 1.0))),
                              ),
                            )
                          ]);
                      })
                    ]),
                    const SizedBox(height: 16),
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
                            isEmpty: !controller.isVacationDeactivated &&
                                controller.vacationPresentation.value.startDateIsNull,
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    controller.isVacationDeactivated ? 0.5 : 1.0)),
                            hintText: AppLocalizations.of(context).startDate,
                            icon: SvgPicture.asset(_imagePaths.icCalendar),
                            tapActionCallback: (value) =>
                                controller.selectDate(context, DateType.start, value)))),
                        const SizedBox(width: 16),
                        Expanded(child: Obx(() => BorderButtonField<TimeOfDay>(
                            value: controller.vacationPresentation.value.startTime,
                            mouseCursor: SystemMouseCursors.text,
                            isEmpty: !controller.isVacationDeactivated &&
                                controller.vacationPresentation.value.starTimeIsNull,
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    controller.isVacationDeactivated ? 0.5 : 1.0)),
                            hintText: AppLocalizations.of(context).noStartTime,
                            icon: SvgPicture.asset(_imagePaths.icClock),
                            tapActionCallback: (value) =>
                                controller.selectTime(context, DateType.start, value)))),
                      ]),
                    )),
                    const SizedBox(height: 16),
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
                            isEmpty: controller.canChangeEndDate &&
                                controller.vacationPresentation.value.endDateIsNull,
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    !controller.canChangeEndDate ? 0.5 : 1.0)),
                            hintText: AppLocalizations.of(context).noEndDate,
                            icon: SvgPicture.asset(_imagePaths.icCalendar),
                            tapActionCallback: (value) =>
                                controller.selectDate(context, DateType.end, value)))),
                        const SizedBox(width: 16),
                        Expanded(child: Obx(() => BorderButtonField<TimeOfDay>(
                            value: controller.vacationPresentation.value.endTime,
                            mouseCursor: SystemMouseCursors.text,
                            isEmpty: controller.canChangeEndDate &&
                                controller.vacationPresentation.value.endTimeIsNull,
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black.withOpacity(
                                    !controller.canChangeEndDate ? 0.5 : 1.0)),
                            hintText: AppLocalizations.of(context).noEndTime,
                            icon: SvgPicture.asset(_imagePaths.icClock),
                            tapActionCallback: (value) =>
                                controller.selectTime(context, DateType.end, value)))),
                      ])
                    )),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        AppLocalizations.of(context).vacationResponder,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                    const SizedBox(height: 10),
                    Obx(() {
                      return Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                controller.updateVacationPresentation(newStatus: VacationResponderStatus.deactivated);
                              },
                              child: Text(AppLocalizations.of(context).deactivated,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black.withOpacity(
                                          controller.isVacationDeactivated ? 1.0 : 0.3))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3, right: 16, left: 16),
                            child: InkWell(
                                onTap: () {
                                  final newStatus = controller.isVacationDeactivated
                                      ? VacationResponderStatus.activated
                                      : VacationResponderStatus.deactivated;
                                  controller.updateVacationPresentation(newStatus: newStatus);
                                },
                                child: SvgPicture.asset(
                                    controller.isVacationDeactivated
                                        ? _imagePaths.icSwitchOff
                                        : _imagePaths.icSwitchOn,
                                    fit: BoxFit.fill,
                                    width: 24,
                                    height: 24)),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                controller.updateVacationPresentation(newStatus: VacationResponderStatus.activated);
                              },
                              child: Text(AppLocalizations.of(context).activated,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black.withOpacity(
                                          controller.isVacationDeactivated ? 0.3 : 1.0))),
                            ),
                          )
                        ]);
                    })
                  ]),
                  const SizedBox(height: 16),
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
                            icon: SvgPicture.asset(_imagePaths.icCalendar),
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
                            icon: SvgPicture.asset(_imagePaths.icClock),
                            tapActionCallback: (value) =>
                                controller.selectTime(context, DateType.start, value))))
                      ]),
                    ]),
                  )),
                  const SizedBox(height: 16),
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
                              icon: SvgPicture.asset(_imagePaths.icCalendar),
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
                              icon: SvgPicture.asset(_imagePaths.icClock),
                              tapActionCallback: (value) =>
                                  controller.selectTime(context, DateType.end, value))))
                        ]),
                      ])
                  )),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildMessageBodyWidget(BuildContext context, double opacity) {
    return Obx(() {
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
              ..setErrorText(controller.isVacationDeactivated
                  ? null
                  : controller.errorMessageBody.value)
              ..setHintText(AppLocalizations
                  .of(context)
                  .hintMessageBodyVacation))
            .build())
          ..onChange((value) => controller.updateMessageBody(context, value))
          ..minLines(10)
          ..maxLines(null))
        .build();
    });
  }
  
  EdgeInsets _getPaddingView(BuildContext context) {
    if (BuildUtils.isWeb) {
      if (_responsiveUtils.isDesktop(context)) {
        return const EdgeInsets.all(16);
      } else {
        return const EdgeInsets.only(top: 16, bottom: 16, left: 0, right: 24);
      }
    } else {
      if (_responsiveUtils.isPortraitMobile(context)) {
        return const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 24);
      } else {
        return const EdgeInsets.only(top: 16, bottom: 16, left: 0, right: 24);
      }
    }
  }
}