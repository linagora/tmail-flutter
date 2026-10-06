import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/drag_drog_file_mixin.dart';

import '../../../../fixtures/widget_fixtures.dart';

class _DropHandler with DragDropFileMixin {}

/// Readable, so it is not a folder, but its size lookup fails.
class _SizeFailingXFile extends XFile {
  _SizeFailingXFile(super.path);

  @override
  Future<int> length() => Future.error(const FileSystemException('size lookup failed'));
}

typedef _DropResult = ({List<FileInfo> files, int folderCount});

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

  testWidgets(
    'onDragDone maps the dropped file by path and size and skips the folder dropped with it',
    _expectMixedDropKeepsOnlyTheFile,
    skip: Platform.isWindows,
  );

  testWidgets(
    'onDragDone returns no file when mapping a dropped file fails',
    _expectFailedMappingReturnsNoFile,
  );
}

Future<void> _expectMixedDropKeepsOnlyTheFile(WidgetTester tester) async {
  await tester.runAsync(() async {
    final dir = Directory.systemTemp.createTempSync('dropped');
    addTearDown(() => dir.deleteSync(recursive: true));
    final folder = Directory('${dir.path}/docs')..createSync();
    final note = File('${dir.path}/note.txt')..writeAsStringSync('hello drop');

    final result = await _dropAndPump(tester, [XFile(folder.path), XFile(note.path, mimeType: 'text/plain')]);

    expect(result.folderCount, 1);
    final file = result.files.single as FilePathInfo;
    expect(file.filePath, note.path);
    expect(file.fileName, 'note.txt');
    expect(file.fileSize, 'hello drop'.length);
  });
}

Future<void> _expectFailedMappingReturnsNoFile(WidgetTester tester) async {
  await tester.runAsync(() async {
    final dir = Directory.systemTemp.createTempSync('dropped');
    addTearDown(() => dir.deleteSync(recursive: true));
    final note = File('${dir.path}/note.txt')..writeAsStringSync('hello drop');

    final result = await _dropAndPump(
      tester,
      [_SizeFailingXFile(note.path)],
      onDialogError: () => tester.tap(find.text('Close')),
    );

    expect(result.folderCount, 0);
    expect(result.files, isEmpty);
  });
}

/// Runs inside `runAsync`: real file reads complete between pumps, and the
/// loading dialog gets the frames it needs to run and close.
Future<_DropResult> _dropAndPump(
  WidgetTester tester,
  List<XFile> files, {
  Future<void> Function()? onDialogError,
}) async {
  late BuildContext context;
  await tester.pumpWidget(WidgetFixtures.makeTestableWidget(
    child: Builder(builder: (ctx) {
      context = ctx;
      return const SizedBox.shrink();
    }),
  ));
  await tester.pump();

  var done = false;
  final pending = _DropHandler().onDragDone(
    context: context,
    details: DropDoneDetails(files: files, localPosition: Offset.zero, globalPosition: Offset.zero),
  )..whenComplete(() => done = true);

  for (var i = 0; i < 100 && !done; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await tester.pump();
    if (onDialogError != null && find.text('Close').evaluate().isNotEmpty) {
      await onDialogError();
    }
  }
  expect(done, isTrue, reason: 'the drop never finished');
  return pending;
}
