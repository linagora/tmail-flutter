import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/utils/app_logger.dart';
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
      () => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: buildIconWeb(
            splashRadius: 15,
            minSize: 40,
            iconPadding: const EdgeInsets.only(right: 2),
            icon: SvgPicture.asset(_imagePaths.icFilterAdvanced,
                colorFilter: searchController.isAdvancedSearchViewOpen.isTrue || searchController.advancedSearchIsActivated.isTrue
                    ? AppColor.colorFilterMessageEnabled.asFilter()
                    : AppColor.colorFilterMessageDisabled.asFilter(),
                width: 16,
                height: 16),
            onTap: () {
              log('IconOpenAdvancedSearchWidget::build(): clicked');
              advancedFilterController.initSearchFilterField(context);
              searchController.showAdvancedFilterView(_parentContext);
            }),
      ),
    );
  }
}
