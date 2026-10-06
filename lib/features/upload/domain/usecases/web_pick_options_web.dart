import 'package:file_picker/file_picker.dart';
import 'package:file_picker_web/file_picker_web.dart';

/// Stops the browser reading the file at pick time: file_picker then returns a
/// zero-copy `blob:` URL that can be re-opened once per upload attempt.
WebOptions lazyWebPickOptions() =>
    const FilePickerWebOptions(withData: false, withReadStream: false);
