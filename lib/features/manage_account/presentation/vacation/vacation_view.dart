
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/border_button_field.dart';
import 'package:tmail_ui_user/features/base/widget/text_input_field_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/date_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/vacation/vacation_responder_status.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';
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
          padding: SettingsUtils.getMarginViewForSettingDetails(context, _responsiveUtils),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_responsiveUtils.isWebDesktop(context))
                   ...[
                     Text(AppLocalizations.of(context).vacation,
                         style: const TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.w500,
                             color: Colors.black)),
                     const SizedBox(height: 8)
                   ],
                  Text(AppLocalizations.of(context).vacationSettingExplanation,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: AppColor.colorVacationSettingExplanation)),
                  const SizedBox(height: 24),
                  Row(children: [
                    Obx(() {
                      return InkWell(
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
                              height: 24)
                      );
                    }),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(AppLocalizations.of(context).vacationSettingToggleButtonAutoReply,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.black)
                      ),
                    )
                  ]),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Column(children: [
                      Obx(() => AbsorbPointer(
                        absorbing: controller.isVacationDeactivated,
                        child: Opacity(
                          opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                          child: _responsiveUtils.isPortraitMobile(context)
                            ? Column(children: [
                                BorderButtonField<DateTime>(
                                    label: AppLocalizations.of(context).startDate,
                                    value: controller.vacationPresentation.value.startDate,
                                    mouseCursor: SystemMouseCursors.text,
                                    backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                    isEmpty: !controller.isVacationDeactivated &&
                                        controller.vacationPresentation.value.startDateIsNull,
                                    hintText: AppLocalizations.of(context).startDate,
                                    tapActionCallback: (value) =>
                                        controller.selectDate(context, DateType.start, value)),
                                const SizedBox(height: 18),
                                BorderButtonField<TimeOfDay>(
                                    label: AppLocalizations.of(context).startTime,
                                    value: controller.vacationPresentation.value.startTime,
                                    mouseCursor: SystemMouseCursors.text,
                                    backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                    isEmpty: !controller.isVacationDeactivated &&
                                        controller.vacationPresentation.value.starTimeIsNull,
                                    hintText: AppLocalizations.of(context).noStartTime,
                                    tapActionCallback: (value) =>
                                        controller.selectTime(context, DateType.start, value)),
                              ])
                          : Row(children: [
                              Expanded(child: BorderButtonField<DateTime>(
                                  label: AppLocalizations.of(context).startDate,
                                  value: controller.vacationPresentation.value.startDate,
                                  mouseCursor: SystemMouseCursors.text,
                                  backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                  isEmpty: !controller.isVacationDeactivated &&
                                      controller.vacationPresentation.value.startDateIsNull,
                                  hintText: AppLocalizations.of(context).startDate,
                                  tapActionCallback: (value) =>
                                      controller.selectDate(context, DateType.start, value))),
                              const SizedBox(width: 24),
                              Expanded(child: BorderButtonField<TimeOfDay>(
                                  label: AppLocalizations.of(context).startTime,
                                  value: controller.vacationPresentation.value.startTime,
                                  mouseCursor: SystemMouseCursors.text,
                                  backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                  isEmpty: !controller.isVacationDeactivated &&
                                      controller.vacationPresentation.value.starTimeIsNull,
                                  hintText: AppLocalizations.of(context).noStartTime,
                                  tapActionCallback: (value) =>
                                      controller.selectTime(context, DateType.start, value))),
                            ]),
                        ),
                      )),
                      const SizedBox(height: 24),
                      Obx(() => AbsorbPointer(
                          absorbing: controller.isVacationDeactivated,
                          child: Opacity(
                            opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                            child: Row(children: [
                              Obx(() => InkWell(
                                  onTap: () {
                                    final value = !controller.vacationPresentation.value.vacationStopEnabled;
                                    controller.updateVacationPresentation(vacationStopEnabled: value);
                                  },
                                  child: SvgPicture.asset(
                                      controller.vacationPresentation.value.vacationStopEnabled
                                          ? _imagePaths.icSwitchOn
                                          : _imagePaths.icSwitchOff,
                                      fit: BoxFit.fill,
                                      width: 24,
                                      height: 24)
                              )
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(AppLocalizations.of(context).vacationStopsAt,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black)
                                ),
                              )
                            ]),
                          )
                      )),
                      const SizedBox(height: 24),
                      Obx(() => AbsorbPointer(
                          absorbing: !controller.canChangeEndDate,
                          child: Opacity(
                            opacity: !controller.canChangeEndDate ? 0.3 : 1.0,
                            child: _responsiveUtils.isPortraitMobile(context)
                              ? Column(children: [
                                  BorderButtonField<DateTime>(
                                      label: AppLocalizations.of(context).endDate,
                                      value: controller.vacationPresentation.value.endDate,
                                      mouseCursor: SystemMouseCursors.text,
                                      backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                      isEmpty: controller.canChangeEndDate &&
                                          controller.vacationPresentation.value.endDateIsNull,
                                      hintText: AppLocalizations.of(context).noEndDate,
                                      tapActionCallback: (value) =>
                                          controller.selectDate(context, DateType.end, value)),
                                  const SizedBox(height: 18),
                                  BorderButtonField<TimeOfDay>(
                                      label: AppLocalizations.of(context).endTime,
                                      value: controller.vacationPresentation.value.endTime,
                                      mouseCursor: SystemMouseCursors.text,
                                      backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                      isEmpty: controller.canChangeEndDate &&
                                          controller.vacationPresentation.value.endTimeIsNull,
                                      hintText: AppLocalizations.of(context).noEndTime,
                                      tapActionCallback: (value) =>
                                          controller.selectTime(context, DateType.end, value)),
                                ])
                              : Row(children: [
                                  Expanded(child: BorderButtonField<DateTime>(
                                      label: AppLocalizations.of(context).endDate,
                                      value: controller.vacationPresentation.value.endDate,
                                      mouseCursor: SystemMouseCursors.text,
                                      backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                      isEmpty: controller.canChangeEndDate &&
                                          controller.vacationPresentation.value.endDateIsNull,
                                      hintText: AppLocalizations.of(context).noEndDate,
                                      tapActionCallback: (value) =>
                                          controller.selectDate(context, DateType.end, value))),
                                  const SizedBox(width: 24),
                                  Expanded(child: BorderButtonField<TimeOfDay>(
                                      label: AppLocalizations.of(context).endTime,
                                      value: controller.vacationPresentation.value.endTime,
                                      mouseCursor: SystemMouseCursors.text,
                                      backgroundColor: AppColor.colorBackgroundVacationSettingField,
                                      isEmpty: controller.canChangeEndDate &&
                                          controller.vacationPresentation.value.endTimeIsNull,
                                      hintText: AppLocalizations.of(context).noEndTime,
                                      tapActionCallback: (value) =>
                                          controller.selectTime(context, DateType.end, value))),
                                ]),
                          )
                      )),
                      const SizedBox(height: 24),
                      Obx(() => AbsorbPointer(
                          absorbing: controller.isVacationDeactivated,
                          child: _responsiveUtils.isPortraitMobile(context)
                              ? Opacity(
                                  opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                                  child: TextInputFieldBuilder(
                                  label: AppLocalizations.of(context).subject,
                                  hint: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                                  editingController: controller.subjectTextController),
                                )
                              : Row(children: [
                                  Expanded(child: Opacity(
                                    opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                                    child: TextInputFieldBuilder(
                                        label: AppLocalizations.of(context).subject,
                                        hint: AppLocalizations.of(context).hintSubjectInputVacationSetting,
                                        editingController: controller.subjectTextController),
                                  )),
                                  const SizedBox(width: 24),
                                  const Expanded(child: SizedBox.shrink())
                                ])
                      )),
                      const SizedBox(height: 24),
                      Obx(() => AbsorbPointer(
                        absorbing: controller.isVacationDeactivated,
                        child: Opacity(
                          opacity: controller.isVacationDeactivated ? 0.3 : 1.0,
                          child: TextInputFieldBuilder(
                              label: AppLocalizations.of(context).message,
                              hint: AppLocalizations.of(context).hintMessageBodyVacation,
                              minLines: 10,
                              maxLines: null,
                              inputType: TextInputType.multiline,
                              backgroundColor: Colors.white,
                              error: controller.isVacationDeactivated
                                  ? null
                                  : controller.errorMessageBody.value,
                              onChangeInputAction: (value) => controller.updateMessageBody(context, value),
                              editingController: controller.messageTextController),
                        ),
                      )),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: buildTextButton(
                            AppLocalizations.of(context).saveChanges,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 16
                            ),
                            width: 156,
                            height: 44,
                            radius: 10,
                            onTap: () => controller.saveVacation(context)),
                      )
                    ]),
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }
}