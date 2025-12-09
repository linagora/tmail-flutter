import 'package:flutter/material.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';

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
  translateVietnamese;

  String getLabel(BuildContext context) {
    final localizations = ScribeLocalizations.of(context)!;
    switch (this) {
      case AIScribeMenuAction.correctGrammar:
        return localizations.categoryCorrectGrammar;
      case AIScribeMenuAction.improveMakeShorter:
        return localizations.actionMakeShorter;
      case AIScribeMenuAction.improveExpandContext:
        return localizations.actionExpandContext;
      case AIScribeMenuAction.improveEmojify:
        return localizations.actionEmojify;
      case AIScribeMenuAction.improveTransformToBullets:
        return localizations.actionTransformToBullets;
      case AIScribeMenuAction.changeToneProfessional:
        return localizations.actionMoreProfessional;
      case AIScribeMenuAction.changeToneCasual:
        return localizations.actionMoreCasual;
      case AIScribeMenuAction.changeTonePolite:
        return localizations.actionMorePolite;
      case AIScribeMenuAction.translateFrench:
        return localizations.languageFrench;
      case AIScribeMenuAction.translateEnglish:
        return localizations.languageEnglish;
      case AIScribeMenuAction.translateRussian:
        return localizations.languageRussian;
      case AIScribeMenuAction.translateVietnamese:
        return localizations.languageVietnamese;
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

  String getFullLabel(BuildContext context) {
    final categoryLabel = category.getLabel(context);
    if (category.hasSubmenu) {
      return '$categoryLabel > ${getLabel(context)}';
    } else {
      return getLabel(context);
    }
  }
}

enum AIScribeMenuCategory {
  correctGrammar,
  improve,
  changeTone,
  translate;

  String getLabel(BuildContext context) {
    final localizations = ScribeLocalizations.of(context)!;
    switch (this) {
      case AIScribeMenuCategory.correctGrammar:
        return localizations.categoryCorrectGrammar;
      case AIScribeMenuCategory.improve:
        return localizations.categoryImprove;
      case AIScribeMenuCategory.changeTone:
        return localizations.categoryChangeTone;
      case AIScribeMenuCategory.translate:
        return localizations.categoryTranslate;
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
