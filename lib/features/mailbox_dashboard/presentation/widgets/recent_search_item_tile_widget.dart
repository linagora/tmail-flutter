
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

class RecentSearchItemTileWidget extends StatelessWidget {

  final imagePath = Get.find<ImagePaths>();

  final RecentSearch recentSearch;

  RecentSearchItemTileWidget(this.recentSearch, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          SvgPicture.asset(imagePath.icClockSB),
          const SizedBox(width: 8),
          Expanded(
            child: Text(recentSearch.value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }
}