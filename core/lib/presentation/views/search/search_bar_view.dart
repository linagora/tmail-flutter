
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnOpenSearchViewAction = Function();

class SearchBarView extends StatelessWidget {

  final OnOpenSearchViewAction? onOpenSearchViewAction;
  final ImagePaths _imagePaths;
  final double? heightSearchBar;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final String? hintTextSearch;
  final double? maxSizeWidth;
  final Widget? rightButton;
  final double? radius;

   const SearchBarView(this._imagePaths, {Key? key,
    this.heightSearchBar,
    this.padding,
    this.margin,
    this.hintTextSearch,
    this.maxSizeWidth,
    this.rightButton,
    this.onOpenSearchViewAction,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        key: const Key('search_bar_widget'),
        alignment: Alignment.center,
        height: heightSearchBar ?? 40,
        width: maxSizeWidth ?? double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 10),
            color: AppColor.colorBgSearchBar),
        padding: padding ?? EdgeInsets.zero,
        margin: margin ?? EdgeInsets.zero,
        child: InkWell(
          onTap: onOpenSearchViewAction,
          mouseCursor: SystemMouseCursors.text,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              buildIconWeb(
                  splashRadius: 15,
                  minSize: 40,
                  iconPadding: EdgeInsets.zero,
                  icon: SvgPicture.asset(
                      _imagePaths.icSearchBar,
                      width: 16,
                      height: 16,
                      fit: BoxFit.fill),
                  onTap: onOpenSearchViewAction),
              Expanded(
                child: Text(
                    hintTextSearch ?? '',
                    maxLines: 1,
                    overflow: CommonTextStyle.defaultTextOverFlow,
                    softWrap: CommonTextStyle.defaultSoftWrap,
                    style: const TextStyle(
                        fontSize: kIsWeb ? 15 : 17,
                        color: AppColor.colorHintSearchBar)),
              ),
              if(rightButton != null)
                rightButton!
            ]
          ),
        ),
    );
  }
}