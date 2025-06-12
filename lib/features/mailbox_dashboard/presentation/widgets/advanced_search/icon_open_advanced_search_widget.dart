import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart'  as search;
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IconOpenAdvancedSearchWidget extends StatelessWidget {
  IconOpenAdvancedSearchWidget({Key? key}) : super(key: key);

  final _imagePaths = Get.find<ImagePaths>();
  final search.SearchController searchController = Get.find<search.SearchController>();
  final AdvancedFilterController advancedFilterController = Get.find<AdvancedFilterController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (searchController.isAdvancedSearchViewOpen.isTrue) {
        return const SizedBox.shrink();
      }

      return TMailButtonWidget.fromIcon(
        icon: _imagePaths.icFilterAdvanced,
        iconSize: 22,
        iconColor: searchController.advancedSearchIsActivated.isTrue
          ? AppColor.primaryMain
          : AppColor.steelGray400,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: Colors.transparent,
        tooltipMessage: AppLocalizations.of(context).advancedSearch,
        onTapActionCallback: () => _onClickOpenAdvancedSearchView(context),
      );
    });
  }

  void _onClickOpenAdvancedSearchView(BuildContext context) {
    log('IconOpenAdvancedSearchWidget::_onClickOpenAdvancedSearchView:');
    advancedFilterController.initSearchFilterField(context);
    searchController.openAdvanceSearch();
  }
}
