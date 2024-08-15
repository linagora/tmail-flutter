
import 'package:core/presentation/resources/image_paths.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/drop_zone_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:desktop_drop/desktop_drop.dart';

typedef OnLocalFileDropZoneListener = Function(DropDoneDetails details);

class LocalFileDropZoneWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry margin;
  final OnLocalFileDropZoneListener? onLocalFileDropZoneListener;

  const LocalFileDropZoneWidget({
    super.key,
    required this.imagePaths,
    this.width,
    this.height,
    this.margin = DropZoneWidgetStyle.margin,
    this.onLocalFileDropZoneListener
  });

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: onLocalFileDropZoneListener,
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: margin,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(DropZoneWidgetStyle.radius),
            color: DropZoneWidgetStyle.borderColor,
            strokeWidth: DropZoneWidgetStyle.borderWidth,
            dashPattern: DropZoneWidgetStyle.dashSize,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: DropZoneWidgetStyle.backgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(DropZoneWidgetStyle.radius)),
                ),
              ),
              padding: DropZoneWidgetStyle.padding,
              alignment: AlignmentDirectional.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: SvgPicture.asset(imagePaths.icDropZoneIcon)),
                  const SizedBox(height: DropZoneWidgetStyle.space),
                  Text(
                    AppLocalizations.of(context).dropFileHereToAttachThem,
                    style: DropZoneWidgetStyle.labelTextStyle,
                  )
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}
