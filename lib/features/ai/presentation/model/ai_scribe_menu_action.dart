enum AIScribeMenuAction {
  translateFrench,
  translateEnglish,
  translateRussian,
  translateVietnamese,
  summarize,
}

extension AIScribeMenuActionExtension on AIScribeMenuAction {
  String get label {
    switch (this) {
      case AIScribeMenuAction.translateFrench:
        return 'French';
      case AIScribeMenuAction.translateEnglish:
        return 'English';
      case AIScribeMenuAction.translateRussian:
        return 'Russian';
      case AIScribeMenuAction.translateVietnamese:
        return 'Vietnamese';
      case AIScribeMenuAction.summarize:
        return 'Summarize';
    }
  }
}

enum AIScribeMenuCategory {
  translate,
  summarize,
}

extension AIScribeMenuCategoryExtension on AIScribeMenuCategory {
  String get label {
    switch (this) {
      case AIScribeMenuCategory.translate:
        return 'Translate';
      case AIScribeMenuCategory.summarize:
        return 'Summarize';
    }
  }

  List<AIScribeMenuAction> get actions {
    switch (this) {
      case AIScribeMenuCategory.translate:
        return [
          AIScribeMenuAction.translateFrench,
          AIScribeMenuAction.translateEnglish,
          AIScribeMenuAction.translateRussian,
          AIScribeMenuAction.translateVietnamese,
        ];
      case AIScribeMenuCategory.summarize:
        return [AIScribeMenuAction.summarize];
    }
  }

  bool get hasSubmenu {
    return actions.length > 1;
  }
}
