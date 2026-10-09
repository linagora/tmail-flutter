abstract class AbstractComposerEditorAssertionRobot {
  /// [skeleton] is the editor's list structure with only list tags and text,
  /// e.g. `ul[li[one ul[li[two]]]]`.
  Future<void> expectEditorListSkeleton(String skeleton);
}
