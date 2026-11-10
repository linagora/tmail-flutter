import 'package:file_picker/file_picker.dart';
import 'package:file_picker_web/file_picker_web.dart';

/// Stops the browser reading the file at pick time: file_picker then returns a
/// zero-copy `blob:` URL that can be re-opened once per upload attempt.
///
/// `cancelUploadOnWindowBlur` is off because file_picker_web would otherwise
/// treat the window regaining focus as "dialog cancelled" and, 500 ms later,
/// drop the pick if the `change` event has not arrived. Firefox only fills
/// `input.files` at `change`, which can come over a second after the focus
/// when many files are picked, so the whole selection was lost silently.
/// A real cancel is still reported through the input's own `cancel` event.
WebOptions lazyWebPickOptions() => const FilePickerWebOptions(
  withData: false,
  withReadStream: false,
  cancelUploadOnWindowBlur: false,
);
