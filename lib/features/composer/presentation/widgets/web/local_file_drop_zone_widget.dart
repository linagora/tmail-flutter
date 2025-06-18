
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/upload/file_info.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/drag_drog_file_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/web/drop_zone_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnSuperFileDrop = void Function(List<FileInfo> fileInfos);

class LocalFileDropZoneWidget extends StatelessWidget with DragDropFileMixin {

  final ImagePaths imagePaths;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry margin;
  final OnSuperFileDrop? onSuperDrop;

  const LocalFileDropZoneWidget({
    super.key,
    required this.imagePaths,
    this.width,
    this.height,
    this.margin = DropZoneWidgetStyle.margin,
    this.onSuperDrop,
  });

  static final allowedFormats = Formats.standardFormats.where((format) {
    return format != Formats.plainText
      && format != Formats.htmlText
      && format != Formats.uri
      && format != Formats.fileUri;
  }).cast<SimpleFileFormat>().toList();

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: allowedFormats,
      onDropOver: (_) => DropOperation.copy,
      onPerformDrop: (performDropEvent) => _onFileDrop(context, performDropEvent),
      hitTestBehavior: HitTestBehavior.opaque,
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

  Future<void> _onFileDrop(BuildContext context, PerformDropEvent performDropEvent) async {
    await showFutureLoadingDialogFullScreen(
      context: context,
      future: () async {
        final items = performDropEvent.session.items;
        final listFileInfo = await Future.wait(items.map(
          (item) async {
            final dataReaderFile = await item.dataReader?.getFileFuture(
              SimpleFileFormat(mimeTypes: item.platformFormats)
            );
            final bytes = await dataReaderFile?.readAll();
            return FileInfo(
              fileName: dataReaderFile?.fileName ?? await item.dataReader?.getSuggestedName() ?? '',
              fileSize: bytes?.length ?? 0,
              bytes: bytes,
              isInline: item.platformFormats.firstOrNull?.startsWith(Constant.imageType),
              type: item.platformFormats.firstOrNull ?? Constant.octetStreamMimeType,
            );
          },
        ));
        
        onSuperDrop?.call(listFileInfo);
      },
    );
  }
}

extension _DataReaderExtension on DataReader {
  Future<DataReaderFile?> getFileFuture(FileFormat format) {
    final c = Completer<DataReaderFile?>();
    final progress = getFile(
      format,
      (file) => c.complete(file),
      onError: (e) => c.completeError(e),
    );
    if (progress == null) {
      c.complete(null);
    }
    return c.future;
  }
}