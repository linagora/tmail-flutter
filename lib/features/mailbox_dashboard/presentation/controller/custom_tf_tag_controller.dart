import 'package:textfield_tags/textfield_tags.dart';

class CustomController extends TextfieldTagsController<String> {
  CustomController() : super();

  Function(String)? actionRemoveTag;
  Function(String)? actionAddTag;
  Function(String)? actionChangeText;

  void setActionRemoveTag(Function(String) action) {
    actionRemoveTag = action;
  }

  void setActionAddTag(Function(String) action) {
    actionAddTag = action;
  }

  void setActionChangeText(Function(String) action) {
    actionChangeText = action;
  }

  @override
  bool? onTagRemoved(String tag) {
    actionRemoveTag?.call(tag);
    return super.onTagRemoved(tag);
  }

  @override
  bool? onTagSubmitted(String tag) {
    // Handle comma-separated input
    final ts = [','];
    final separator = ts.cast<String?>().firstWhere(
        (element) => tag.contains(element!) && tag.indexOf(element) != 0,
        orElse: () => null);

    if (separator != null) {
      final splits = tag.split(separator);
      final indexer = splits.length > 1 ? splits.length - 2 : splits.length - 1;
      final val = splits.elementAt(indexer).trim();
      if (val.isNotEmpty) {
        actionAddTag?.call(val);
      }
    } else {
      actionAddTag?.call(tag);
    }

    return super.onTagSubmitted(tag);
  }

  @override
  bool? onTagChanged(String tag) {
    actionChangeText?.call(tag);
    return super.onTagChanged(tag);
  }
}
