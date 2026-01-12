import 'package:core/presentation/resources/image_paths.dart';
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

  String getLabel(ScribeLocalizations localizations) {
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

  String getFullLabel(ScribeLocalizations localizations) {
    final categoryLabel = category.getLabel(localizations);
    if (category.hasSubmenu) {
      return '$categoryLabel > ${getLabel(localizations)}';
    } else {
      return getLabel(localizations);
    }
  }

  String? getIcon(ImagePaths imagePaths) {
    switch (this) {
      case AIScribeMenuAction.correctGrammar:
        return imagePaths.icAiGrammar;
      case AIScribeMenuAction.improveMakeShorter:
        return imagePaths.icAiShorter;
      case AIScribeMenuAction.improveExpandContext:
        return imagePaths.icAiMoreDetail;
      case AIScribeMenuAction.improveEmojify:
        return imagePaths.icAiEmojify;
      case AIScribeMenuAction.improveTransformToBullets:
        return imagePaths.icAiBullets;
      case AIScribeMenuAction.changeToneProfessional:
        return imagePaths.icAiMoreProfessional;
      case AIScribeMenuAction.changeToneCasual:
        return imagePaths.icAiMoreCasual;
      case AIScribeMenuAction.changeTonePolite:
        return imagePaths.icAiMorePolite;
      default:
        return null;
    }
  }
}

enum AIScribeMenuCategory {
  correctGrammar,
  translate,
  changeTone,
  improve;

  String getLabel(ScribeLocalizations localizations) {
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

  String getIcon(ImagePaths imagePaths) {
    switch (this) {
      case AIScribeMenuCategory.correctGrammar:
        return imagePaths.icAiGrammar;
      case AIScribeMenuCategory.improve:
        return imagePaths.icAiImprove;
      case AIScribeMenuCategory.changeTone:
        return imagePaths.icAiChangeTons;
      case AIScribeMenuCategory.translate:
        return imagePaths.icAiTranslate;
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
