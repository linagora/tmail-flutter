
import 'package:collection/collection.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_status.dart';

typedef UpdateFileUploadingState = UploadFileState? Function(UploadFileState? currentState);
typedef MatchedState = bool Function(UploadFileState? state);

class UploadFileStateList {

  final List<UploadFileState?> _uploadingStateFiles = <UploadFileState?>[];

  List<UploadFileState?> get uploadingStateFiles => _uploadingStateFiles.toList(growable: false);

  UploadFileStateList add(UploadFileState element) {
    _uploadingStateFiles.add(element);
    return this;
  }

  UploadFileStateList addAll(Iterable<UploadFileState> elements) {
    _uploadingStateFiles.addAll(elements);
    return this;
  }

  UploadFileStateList updateElementBy(
    MatchedState matchedState,
    UpdateFileUploadingState updateFileUploadingState,
  ) {
    final matchIndex = _uploadingStateFiles.indexWhere((element) => matchedState(element));
    if (matchIndex >= 0) {
      _uploadingStateFiles[matchIndex] = updateFileUploadingState(_uploadingStateFiles[matchIndex]);
    }
    return this;
  }

  UploadFileStateList updateElementByUploadTaskId(
    UploadTaskId uploadTaskId,
    UpdateFileUploadingState updateFileUploadingState,
  ) {
    return updateElementBy(
      (state) => state?.uploadTaskId == uploadTaskId,
      updateFileUploadingState
    );
  }

  bool get allSuccess {
    if (_uploadingStateFiles.isEmpty) {
      return false;
    }
    return _uploadingStateFiles
        .whereNotNull()
        .every((file) => file.uploadStatus == UploadFileStatus.succeed);
  }

  void clear() {
    _uploadingStateFiles.clear();
  }

  void deleteElementByUploadTaskId(UploadTaskId uploadTaskId) {
    final fileState = _uploadingStateFiles
        .firstWhereOrNull((fileState) => fileState?.uploadTaskId == uploadTaskId);

    if (fileState != null) {
      fileState.cancelToken?.cancel();
      _uploadingStateFiles.remove(fileState);
    }
  }

  UploadFileState? getUploadFileStateById(UploadTaskId uploadTaskId) {
    return _uploadingStateFiles.firstWhereOrNull((fileState) => fileState?.uploadTaskId == uploadTaskId);
  }
}