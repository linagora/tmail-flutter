
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/utils/build_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:model/upload/file_info.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef InsertImageActionCallback = Function(InlineImage image);

class InsertImageDialogBuilder {

  final _inputFileController = TextEditingController();
  final _inputUrlController = TextEditingController();

  final InsertImageActionCallback? insertActionCallback;
  final BuildContext _context;

  FileInfo? fileSelected;
  String? validateFailed;

  InsertImageDialogBuilder(this._context, {
    this.insertActionCallback
  });

  Future show() async {
    await showDialog(
      context: _context,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).insertImage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black)),
              titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
              titlePadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              scrollable: true,
              elevation: 10,
              content: Container(
                color: Colors.white,
                width: 300,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).selectFromFile,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      TextFormField(
                          controller: _inputFileController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: buildButtonWrapText(
                                AppLocalizations.of(context).chooseImage,
                                radius: 5,
                                height: 30,
                                padding: const EdgeInsets.only(right: 8),
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                                bgColor: AppColor.colorShadowComposer,
                                onTap: () => _selectFromFile(setState)),
                            suffixIcon: fileSelected != null
                                ? IconButton(
                                    splashRadius: 10,
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        fileSelected = null;
                                        _inputFileController.text = '';
                                      });
                                    })
                                : const SizedBox.shrink(),
                            errorText: validateFailed,
                            errorMaxLines: 2,
                            border: InputBorder.none,
                          )),
                      const SizedBox(height: 20),
                      Text(AppLocalizations.of(context).urlLink,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _inputUrlController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: AppLocalizations.of(context).urlLink,
                          errorText: validateFailed,
                          errorMaxLines: 2,
                        ),
                      ),
                    ]),
              ),
              actionsPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              actions: [
                buildButtonWrapText(
                    AppLocalizations.of(context).cancel,
                    radius: 5,
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                    bgColor: AppColor.colorShadowComposer,
                    onTap: () => popBack()),
                buildButtonWrapText(
                    AppLocalizations.of(context).insert,
                    radius: 5,
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                    onTap: () => _insertImageAction(context, setState))
              ],
            );
          }),
        );
      });
  }

  void _selectFromFile(StateSetter setState) async {
    final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withReadStream: true);

    final platformFile = filePickerResult?.files.single;
    if (platformFile != null) {
      fileSelected = FileInfo(
          platformFile.name,
          BuildUtils.isWeb ? '' : platformFile.path ?? '',
          platformFile.size,
          readStream: platformFile.readStream);

      setState(() {
        _inputFileController.text = fileSelected!.fileName;
      });
    }
  }

  void _insertImageAction(BuildContext context, StateSetter setState) {
    final inputFile = _inputFileController.text;
    final inputUrl = _inputUrlController.text;

    if (inputFile.isEmpty && inputUrl.isEmpty) {
      setState(() {
        validateFailed = AppLocalizations.of(context).insertImageErrorFileEmpty;
      });
    } else if (inputFile.isNotEmpty && inputUrl.isNotEmpty) {
      setState(() {
        validateFailed = AppLocalizations.of(context).insertImageErrorDuplicate;
      });
    } else if (inputFile.isNotEmpty && fileSelected != null) {
      if (insertActionCallback != null) {
        insertActionCallback!.call(InlineImage(ImageSource.local, fileInfo: fileSelected));
      }
      popBack();
    } else {
      if (insertActionCallback != null) {
        insertActionCallback!.call(InlineImage(ImageSource.network, link: inputUrl));
      }
      popBack();
    }
  }
}