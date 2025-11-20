import 'package:core/utils/app_logger.dart';
import 'package:flutter_emoji_mart/flutter_emoji_mart.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/reactions/domain/state/get_recent_reactions_state.dart';
import 'package:tmail_ui_user/features/reactions/domain/usecase/get_recent_reactions_interactor.dart';
import 'package:tmail_ui_user/features/reactions/domain/usecase/store_recent_reactions_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/asset_manager.dart';

extension HandleInsertEmojiToEditorExtension on ComposerController {
  void insertEmojiToEditor(String emoji) {
    log('$runtimeType::insertEmojiToEditor: Emoji is $emoji');
    richTextWebController?.insertEmoji(emoji);
    storeRecentReactions(emoji);
  }

  void handleOpenEmojiPicker() {
    log('$runtimeType::handleOpenEmojiPicker:');
    clearFocusRecipients();
    clearFocusSubject();
    richTextWebController?.editorController.setFocus();
  }

  void storeRecentReactions(String emoji) async {
    final emojiId = AssetManager().emojiData?.getIdByEmoji(emoji);
    log('$runtimeType::storeRecentReactions: EmojiId is $emojiId');
    if (emojiId?.trim().isNotEmpty == true) {
      final interactor = getBinding<StoreRecentReactionsInteractor>(
        tag: composerId,
      );
      if (interactor != null) {
        consumeState(interactor.execute(emojiId: emojiId!));
      }
    }
  }

  Future<Category?> getRecentReactions() async {
    final interactor = getBinding<GetRecentReactionsInteractor>(
      tag: composerId,
    );
    if (interactor == null) return Future.value(null);

    final result = await interactor.execute();

    final category = result.fold(
      (failure) => null,
      (success) =>
          success is GetRecentReactionsSuccess ? success.category : null,
    );
    log('$runtimeType::getRecentReactions: Category is $category');
    return category;
  }
}
