import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';

class IconOpenAdvancedSearchWidget extends StatelessWidget {
  IconOpenAdvancedSearchWidget(
    this._parentContext, {
    Key? key,
  }) : super(key: key);

  final _imagePaths = Get.find<ImagePaths>();
  final SearchController searchController = Get.find<SearchController>();
  final AdvancedFilterController advancedFilterController = Get.find<AdvancedFilterController>();
  final BuildContext _parentContext;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => buildIconWeb(
          minSize: 0,
          iconPadding: const EdgeInsets.only(right: 8),
          icon: SvgPicture.asset(_imagePaths.icFilterAdvanced,
              color: searchController.isAdvancedSearchViewOpen.isTrue || searchController.isAdvancedSearchHasApply.isTrue
                  ? AppColor.colorFilterMessageEnabled
                  : AppColor.colorFilterMessageDisabled,
              width: 16,
              height: 16),
          onTap: () {
            if(searchController.isAdvancedSearchViewOpen.isFalse && searchController.isAdvancedSearchHasApply.isFalse){
              advancedFilterController.initSearchFilterField(context);
            }
            searchController.showAdvancedFilterView(_parentContext);
          }),
    );
  }
}
