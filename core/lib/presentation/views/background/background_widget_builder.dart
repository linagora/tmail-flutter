
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackgroundWidgetBuilder {
  Key? _key;
  SvgPicture? _image;
  String? _text;

  final BuildContext _context;

  BackgroundWidgetBuilder(this._context);

  void key(Key key) {
    _key = key;
  }

  void image(SvgPicture image) {
    _image = image;
  }

  void text(String text) {
    _text = text;
  }

  Widget build() {
    return Center(
      key: _key ?? const Key('BackgroundWidgetBuilder'),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _image ?? const SizedBox.shrink(),
                  Padding(
                    padding: EdgeInsets.only(top: _image != null ? 16 : 0),
                    child: Text(
                      _text ?? '',
                      style: const TextStyle(color: AppColor.baseTextColor, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              height: MediaQuery.of(_context).size.height,
            ),
          )
        ]
      )
    );
  }
}