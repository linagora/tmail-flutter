import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/widgets/destination_picker_folder_item.dart';

void main() {
  testWidgets('uses the mailbox neutral color for All folders', (tester) async {
    final imagePaths = ImagePaths();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DestinationPickerFolderItem(
          isSelected: false,
          isDesktop: true,
          text: 'All folders',
          folderIcon: imagePaths.icFolderMailbox,
          selectedIcon: imagePaths.icSelectedSB,
          onTap: () {},
        ),
      ),
    ));

    expect(
      tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
      const ColorFilter.mode(AppColor.gray424244, BlendMode.srcIn),
    );
  });
}
