
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

class RecentSearchItemTileWidget extends StatelessWidget {

  final imagePath = Get.find<ImagePaths>();

  final RecentSearch recentSearch;
  final EdgeInsetsGeometry? contentPadding;

  RecentSearchItemTileWidget(
      this.recentSearch, {
      Key? key,
      this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: contentPadding ?? const EdgeInsetsDirectional.all(12),
      child: Row(
        children: [
          SvgPicture.asset(imagePath.icClockSB),
          const SizedBox(width: 8),
          Expanded(
            child: Text(recentSearch.value,
                style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }
}