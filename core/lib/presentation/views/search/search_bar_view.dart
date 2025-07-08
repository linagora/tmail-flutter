
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

typedef OnOpenSearchViewAction = Function();

class SearchBarView extends StatelessWidget {

  final OnOpenSearchViewAction? onOpenSearchViewAction;
  final ImagePaths imagePaths;
  final EdgeInsetsGeometry? margin;
  final String? hintTextSearch;

   const SearchBarView({
     Key? key,
     required this.imagePaths,
     this.margin,
     this.hintTextSearch,
     this.onOpenSearchViewAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onOpenSearchViewAction,
        mouseCursor: SystemMouseCursors.text,
        splashColor: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
            alignment: Alignment.center,
            height: 44,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColor.colorBgSearchBar
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TMailButtonWidget.fromIcon(
                  icon: imagePaths.icSearchBar,
                  backgroundColor: Colors.transparent,
                  iconColor: AppColor.colorTextBody,
                  onTapActionCallback: onOpenSearchViewAction
                ),
                Expanded(
                  child: Text(
                    hintTextSearch ?? '',
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontSize: 17,
                      color: AppColor.colorHintSearchBar
                    )
                  ),
                )
              ]
            ),
        ),
      ),
    );
  }
}