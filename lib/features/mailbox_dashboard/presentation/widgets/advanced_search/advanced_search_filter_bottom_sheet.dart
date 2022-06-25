import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/advanced_search/advanced_search_filter_form.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

Future<void> showAdvancedSearchFilterBottomSheet(BuildContext context) async {
  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  await FullScreenActionSheetBuilder(
    context: context,
    child: AdvancedSearchInputForm(),
    cancelWidget: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: SvgPicture.asset(
        _imagePaths.icCloseAdvancedSearch,
        color: AppColor.colorHintSearchBar,
        width: 24,
        height: 24,
      ),
    ),
    titleWidget: Text(
      AppLocalizations.of(context).advancedSearch,
      style: const TextStyle(
        fontSize: 20,
        color: AppColor.colorNameEmail,
      ),
    ),
  ).show();
}
