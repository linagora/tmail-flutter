
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

class RecentItemTileWidget<T> extends StatelessWidget {

  final T item;
  final EdgeInsets? contentPadding;
  final ImagePaths imagePath;

  const RecentItemTileWidget(this.item, {
      required this.imagePath,
      Key? key,
      this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: contentPadding ?? const EdgeInsets.all(12),
      child: Row(
        children: [
          SvgPicture.asset(imagePath.icClockSB),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_getTitle(item),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: Colors.black)),
          ),
        ],
      ),
    );
  }

  String _getTitle(T item) {
    if (item is RecentLoginUrl) {
      return item.url;
    }
    if(item is RecentLoginUsername) {
      return item.username;
    }
    return '';
  }
}