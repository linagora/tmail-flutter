
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
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
        child: ResponsiveWidget(
          mobile: CustomScrollView(slivers: [
            SliverFillRemaining(child: _buildMessageBody(context))
          ]),
          landscapeMobile: SingleChildScrollView(child: _buildMessageBody(context)),
          responsiveUtils: responsiveUtils,
        ),
      )
    );
  }

  Widget _buildMessageBody(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: responsiveUtils.isLandscapeMobile(context)
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconSVG != null)
            SvgPicture.asset(
              iconSVG!,
              width: 212,
              height: 212,
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
    );
  }
}