enum AIScribeMenuAction {
  correctGrammar,
  improveMakeShorter,
  improveExpandContext,
  improveEmojify,
  improveTransformToBullets,
  changeToneProfessional,
  changeToneCasual,
  changeTonePolite,
  translateFrench,
  translateEnglish,
  translateRussian,
  translateVietnamese,
}

extension AIScribeMenuActionExtension on AIScribeMenuAction {
  String get label {
    switch (this) {
      case AIScribeMenuAction.correctGrammar:
        return 'Correct grammar';
      case AIScribeMenuAction.improveMakeShorter:
        return 'Make it shorter';
      case AIScribeMenuAction.improveExpandContext:
        return 'Expand context';
      case AIScribeMenuAction.improveEmojify:
        return 'Emojify';
      case AIScribeMenuAction.improveTransformToBullets:
        return 'Transform to bullets';
      case AIScribeMenuAction.changeToneProfessional:
        return 'More professional';
      case AIScribeMenuAction.changeToneCasual:
        return 'More casual';
      case AIScribeMenuAction.changeTonePolite:
        return 'More polite';
      case AIScribeMenuAction.translateFrench:
        return 'French';
      case AIScribeMenuAction.translateEnglish:
        return 'English';
      case AIScribeMenuAction.translateRussian:
        return 'Russian';
      case AIScribeMenuAction.translateVietnamese:
        return 'Vietnamese';
    }
  }

  AIScribeMenuCategory get category {
    switch (this) {
      case AIScribeMenuAction.correctGrammar:
        return AIScribeMenuCategory.correctGrammar;
      case AIScribeMenuAction.improveMakeShorter:
      case AIScribeMenuAction.improveExpandContext:
      case AIScribeMenuAction.improveEmojify:
      case AIScribeMenuAction.improveTransformToBullets:
        return AIScribeMenuCategory.improve;
      case AIScribeMenuAction.changeToneProfessional:
      case AIScribeMenuAction.changeToneCasual:
      case AIScribeMenuAction.changeTonePolite:
        return AIScribeMenuCategory.changeTone;
      case AIScribeMenuAction.translateFrench:
      case AIScribeMenuAction.translateEnglish:
      case AIScribeMenuAction.translateRussian:
      case AIScribeMenuAction.translateVietnamese:
        return AIScribeMenuCategory.translate;

    }
  }

  String get fullLabel {
    final categoryLabel = category.label;
    if (category.hasSubmenu) {
      return '$categoryLabel > $label';
    } else {
      return label;
    }
  }
}

enum AIScribeMenuCategory {
  correctGrammar,
  improve,
  changeTone,
  translate,
}

extension AIScribeMenuCategoryExtension on AIScribeMenuCategory {
  String get label {
    switch (this) {
      case AIScribeMenuCategory.correctGrammar:
        return 'Correct grammar';
      case AIScribeMenuCategory.improve:
        return 'Improve';
      case AIScribeMenuCategory.changeTone:
        return 'Change tone';
      case AIScribeMenuCategory.translate:
        return 'Translate';
    }
  }

  List<AIScribeMenuAction> get actions {
    switch (this) {
      case AIScribeMenuCategory.correctGrammar:
        return [AIScribeMenuAction.correctGrammar];
      case AIScribeMenuCategory.improve:
        return [
          AIScribeMenuAction.improveMakeShorter,
          AIScribeMenuAction.improveExpandContext,
          AIScribeMenuAction.improveEmojify,
          AIScribeMenuAction.improveTransformToBullets,
        ];
      case AIScribeMenuCategory.changeTone:
        return [
          AIScribeMenuAction.changeToneProfessional,
          AIScribeMenuAction.changeToneCasual,
          AIScribeMenuAction.changeTonePolite,
        ];
      case AIScribeMenuCategory.translate:
        return [
          AIScribeMenuAction.translateFrench,
          AIScribeMenuAction.translateEnglish,
          AIScribeMenuAction.translateRussian,
          AIScribeMenuAction.translateVietnamese,
        ];
    }
  }

  bool get hasSubmenu {
    return actions.length > 1;
  }
}
