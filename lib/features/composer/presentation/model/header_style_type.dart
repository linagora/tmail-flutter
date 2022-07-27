
import 'package:flutter/material.dart';

enum HeaderStyleType {
  normal,
  blockquote,
  code,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6;

  String get styleName {
    switch (this) {
      case HeaderStyleType.normal:
        return 'Normal';
      case HeaderStyleType.blockquote:
        return 'Quote';
      case HeaderStyleType.code:
        return 'Code';
      case HeaderStyleType.h1:
        return 'Header 1';
      case HeaderStyleType.h2:
        return 'Header 2';
      case HeaderStyleType.h3:
        return 'Header 3';
      case HeaderStyleType.h4:
        return 'Header 4';
      case HeaderStyleType.h5:
        return 'Header 5';
      case HeaderStyleType.h6:
        return 'Header 6';
    }
  }

  String get styleValue {
    switch (this) {
      case HeaderStyleType.normal:
        return 'p';
      case HeaderStyleType.blockquote:
        return 'blockquote';
      case HeaderStyleType.code:
        return 'pre';
      case HeaderStyleType.h1:
        return 'h1';
      case HeaderStyleType.h2:
        return 'h2';
      case HeaderStyleType.h3:
        return 'h3';
      case HeaderStyleType.h4:
        return 'h4';
      case HeaderStyleType.h5:
        return 'h5';
      case HeaderStyleType.h6:
        return 'h6';
    }
  }

  double get textSize {
    switch(this) {
      case HeaderStyleType.normal:
        return 16;
      case HeaderStyleType.blockquote:
        return 16;
      case HeaderStyleType.code:
        return 13;
      case HeaderStyleType.h1:
        return 32;
      case HeaderStyleType.h2:
        return 24;
      case HeaderStyleType.h3:
        return 18;
      case HeaderStyleType.h4:
        return 16;
      case HeaderStyleType.h5:
        return 13;
      case HeaderStyleType.h6:
        return 11;
    }
  }

  FontWeight get fontWeight {
    switch(this) {
      case HeaderStyleType.normal:
      case HeaderStyleType.blockquote:
      case HeaderStyleType.code:
        return FontWeight.normal;
      case HeaderStyleType.h1:
      case HeaderStyleType.h2:
      case HeaderStyleType.h3:
      case HeaderStyleType.h4:
      case HeaderStyleType.h5:
      case HeaderStyleType.h6:
        return FontWeight.bold;
    }
  }
}