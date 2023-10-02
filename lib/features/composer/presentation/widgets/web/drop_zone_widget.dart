
import 'package:core/presentation/resources/image_paths.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/drop_zone_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnAddAttachmentFromDropZone = Function(Attachment attachment);

class DropZoneWidget extends StatefulWidget {

  final double? width;
  final double? height;
  final OnAddAttachmentFromDropZone? addAttachmentFromDropZone;

  const DropZoneWidget({
    super.key,
    this.width,
    this.height,
    this.addAttachmentFromDropZone
  });

  @override
  State<DropZoneWidget> createState() => _DropZoneWidgetState();
}

class _DropZoneWidgetState extends State<DropZoneWidget> {

  final _imagePaths = Get.find<ImagePaths>();

  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Attachment>(
      builder: (context, candidateData, rejectedData) {
        if (_isDragging) {
          return Padding(
            padding: DropZoneWidgetStyle.margin,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(DropZoneWidgetStyle.radius),
              color: DropZoneWidgetStyle.borderColor,
              strokeWidth: DropZoneWidgetStyle.borderWidth,
              dashPattern: DropZoneWidgetStyle.dashSize,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const ShapeDecoration(
                  color: DropZoneWidgetStyle.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(DropZoneWidgetStyle.radius)),
                  ),
                ),
                width: widget.width,
                height: widget.height,
                padding: DropZoneWidgetStyle.padding,
                alignment: AlignmentDirectional.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(_imagePaths.icDropZoneIcon),
                    const SizedBox(height: DropZoneWidgetStyle.space),
                    Text(
                      AppLocalizations.of(context).dropFileHereToAttachThem,
                      style: DropZoneWidgetStyle.labelTextStyle,
                    )
                  ]
                ),
              ),
            ),
          );
        } else {
          return SizedBox(width: widget.width, height: widget.height);
        }
      },
      onAccept: widget.addAttachmentFromDropZone,
      onLeave: (attachment) {
        if (_isDragging) {
          setState(() => _isDragging = false);
        }
      },
      onMove: (details) {
        if (!_isDragging) {
          setState(() => _isDragging = true);
        }
      },
    );
  }
}
