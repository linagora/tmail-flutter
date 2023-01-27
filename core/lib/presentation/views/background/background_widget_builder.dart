
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackgroundWidgetBuilder extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final String title;
  final String? iconSVG;
  final String? subTitle;
  final double? maxWidth;

  const BackgroundWidgetBuilder(
    this.title,
    this.responsiveUtils, {
    Key? key,
    this.iconSVG,
    this.subTitle,
    this.maxWidth
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('background_widget'),
      child: SizedBox(
        width: maxWidth ?? 360,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (iconSVG != null)
                      SvgPicture.asset(
                        iconSVG!,
                        width: responsiveUtils.isLandscapeMobile(context)
                          ? 120
                          : 212,
                        height: responsiveUtils.isLandscapeMobile(context)
                          ? 120
                          : 212,
                        fit: BoxFit.fill
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: iconSVG != null ? 12 : 0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.normal
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (subTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          subTitle!,
                          style: const TextStyle(
                            color: AppColor.colorSubtitle,
                            fontSize: 15,
                            fontWeight: FontWeight.normal
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                  ],
                ),
                height: MediaQuery.of(context).size.height,
              ),
            )
          ]
        ),
      )
    );
  }
}