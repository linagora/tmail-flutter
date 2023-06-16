
enum FontNameType {
  arial,
  arialBlack,
  brushScriptMT,
  comicSansMS,
  courierNew,
  helveticaNeue,
  helvetica,
  impact,
  lucidaGrande,
  tahoma,
  timesNewRoman,
  trebuchetMS,
  sansSerif,
  verdana;

  String get title {
    switch(this) {
      case FontNameType.arial:
        return 'Arial';
      case FontNameType.arialBlack:
        return 'Arial Black';
      case FontNameType.brushScriptMT:
        return 'Brush Script MT';
      case FontNameType.comicSansMS:
        return 'Comic Sans MS';
      case FontNameType.courierNew:
        return 'Courier New';
      case FontNameType.helveticaNeue:
        return 'Helvetica Neue';
      case FontNameType.helvetica:
        return 'Helvetica';
      case FontNameType.impact:
        return 'Impact';
      case FontNameType.lucidaGrande:
        return 'Lucida Grande';
      case FontNameType.tahoma:
        return 'Tahoma';
      case FontNameType.timesNewRoman:
        return 'Times New Roman';
      case FontNameType.trebuchetMS:
        return 'Trebuchet MS';
      case FontNameType.sansSerif:
        return 'Sans Serif';
      case FontNameType.verdana:
        return 'Verdana';
    }
  }

  String get value {
    switch(this) {
      case FontNameType.arial:
        return 'Arial';
      case FontNameType.arialBlack:
        return 'Arial Black';
      case FontNameType.brushScriptMT:
        return 'Brush Script MT';
      case FontNameType.comicSansMS:
        return 'Comic Sans MS';
      case FontNameType.courierNew:
        return 'Courier New';
      case FontNameType.helveticaNeue:
        return 'Helvetica Neue';
      case FontNameType.helvetica:
        return 'Helvetica';
      case FontNameType.impact:
        return 'Impact';
      case FontNameType.lucidaGrande:
        return 'Lucida Grande';
      case FontNameType.tahoma:
        return 'Tahoma';
      case FontNameType.timesNewRoman:
        return 'Times New Roman';
      case FontNameType.trebuchetMS:
        return 'Trebuchet MS';
      case FontNameType.sansSerif:
        return 'sans-serif';
      case FontNameType.verdana:
        return 'Verdana';
    }
  }
}