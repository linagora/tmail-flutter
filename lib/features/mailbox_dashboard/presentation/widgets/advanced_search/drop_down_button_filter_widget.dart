import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';

class DateDropDownButton extends GetWidget<AdvancedFilterController> {
  const DateDropDownButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _buildDropDownButton<EmailReceiveTimeType>(
        items: EmailReceiveTimeType.values,
        itemSelected: controller.dateFilterSelectedFormAdvancedSearch.value,
        context: context,
        onChanged: (item) {
          controller.dateFilterSelectedFormAdvancedSearch.value = item!;
        },
      ),
    );
  }
}

class MailBoxDropDownButton extends StatelessWidget {
  const MailBoxDropDownButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


Widget _buildDropDownButton<T>({
  required List<T> items,
  required T itemSelected,
  required BuildContext context,
  required Function(T?)? onChanged,
}) {
  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  return DropdownButtonHideUnderline(
    child: DropdownButton2<T>(
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  StringConvert.writeNullToEmpty(_getTextItemDropdown<T>(
                    item: item,
                    context: context,
                  )),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: BuildUtils.isWeb ? null : TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      value: itemSelected,
      onChanged: onChanged,
      icon: SvgPicture.asset(_imagePaths.icDropDown),
      buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
      buttonDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.colorInputBorderCreateMailbox,
          width: 0.5,
        ),
        color: AppColor.colorInputBackgroundCreateMailbox,
      ),
      itemHeight: 44,
      buttonHeight: 44,
      selectedItemHighlightColor: AppColor.primaryColor.withOpacity(0.12),
      itemPadding: const EdgeInsets.symmetric(horizontal: 12),
      dropdownMaxHeight: 200,
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      dropdownElevation: 4,
      scrollbarRadius: const Radius.circular(40),
      scrollbarThickness: 6,
    ),
  );
}

String? _getTextItemDropdown<T>(
    {required T item, required BuildContext context}) {
  if (item is EmailReceiveTimeType) {
    return item.getTitle(context);
  }

  if (item is Mailbox) {
    return item.name?.name;
  }

  return null;
}
