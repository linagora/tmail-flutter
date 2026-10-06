import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/drag_drog_file_mixin.dart';

class _DropHandler with DragDropFileMixin {}

void main() {
  testWidgets('onDragDone counts every folder of a folder-only drop', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(Builder(builder: (ctx) {
      context = ctx;
      return const SizedBox();
    }));

    final result = await tester.runAsync(() async {
      final first = Directory.systemTemp.createTempSync('dropped-folder');
      final second = Directory.systemTemp.createTempSync('dropped-folder');
      addTearDown(() {
        first.deleteSync(recursive: true);
        second.deleteSync(recursive: true);
      });
      return _DropHandler().onDragDone(
        context: context,
        details: DropDoneDetails(
          files: [XFile(first.path), XFile(second.path)],
          localPosition: Offset.zero,
          globalPosition: Offset.zero,
        ),
      );
    });

    expect(result!.folderCount, 2);
    expect(result.files, isEmpty);
  }, skip: Platform.isWindows);
}
