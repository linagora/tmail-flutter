import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum ZoomState {
  activate,
  inactivate
}

class PaginationPDFViewer extends StatefulWidget {
  
  final PdfViewerController? pdfViewerController;

  const PaginationPDFViewer({
    super.key, 
    this.pdfViewerController,
  });

  @override
  State<PaginationPDFViewer> createState() => _PaginationPDFViewerState();
}

class _PaginationPDFViewerState extends State<PaginationPDFViewer> {
  static const double _maxZoomLevelDefault = 4.0;
  static const double _minZoomLevelDefault = 1.0;

  final ValueNotifier<ZoomState> _zoomInPageNotifier = ValueNotifier<ZoomState>(ZoomState.activate);
  final ValueNotifier<ZoomState> _zoomOutPageNotifier = ValueNotifier<ZoomState>(ZoomState.inactivate);
  final ValueNotifier<int> _pageCurrentNotifier = ValueNotifier<int>(1);

  double _zoomLevel = 1.0;

  @override
  void initState() {
    _zoomLevel = 1.0;
    _pageCurrentNotifier.value = 1;
    widget.pdfViewerController?.addListener(_pageChanged);
    super.initState();
  }

  @override
  void dispose() {
    _zoomLevel = 1.0;
    widget.pdfViewerController?.removeListener(_pageChanged);
    _pageCurrentNotifier.dispose();
    _zoomInPageNotifier.dispose();
    _zoomOutPageNotifier.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(5))
      ),
      height: 50,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).page,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 14
            ),
          ),
          const SizedBox(width: 12),
          ValueListenableBuilder(
            valueListenable: _pageCurrentNotifier, 
            builder: (_, value, __) {
              return Text(
                '$value',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 14
                ),
              );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '/',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 14
              ),
            ),
          ),
          Text(
            '${widget.pdfViewerController?.pageCount}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 14
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 12, end: 8),
            child: VerticalDivider(color: Colors.grey),
          ),
          ValueListenableBuilder(
            valueListenable: _zoomOutPageNotifier,
            builder: (_, state, __) {
              return IconButton(
                onPressed: _zoomOutPage,
                padding: const EdgeInsets.all(2),
                icon: Icon(
                  Icons.horizontal_rule,
                  color: _getColorByZoomState(state),
                  size: 24,
                ),
                focusColor: Colors.black.withOpacity(0.3),
                hoverColor: Colors.black.withOpacity(0.3),
                tooltip: AppLocalizations.of(context).zoomOut,
              );
            }
          ),
          const Padding(
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.zoom_in,
              color: Colors.white,
              size: 28,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _zoomInPageNotifier,
            builder: (_, state, __) {
              return IconButton(
                onPressed: _zoomInPage,
                padding: const EdgeInsets.all(2),
                icon: Icon(
                  Icons.add,
                  color: _getColorByZoomState(state),
                  size: 24,
                ),
                focusColor: Colors.black.withOpacity(0.3),
                hoverColor: Colors.black.withOpacity(0.3),
                tooltip: AppLocalizations.of(context).zoomIn,
              );
            }
          )
        ],
      ),
    );
  }

  Color _getColorByZoomState(ZoomState zoomState) {
    switch (zoomState) {
      case ZoomState.activate:
        return Colors.white;
      case ZoomState.inactivate:
        return Colors.grey;
    }
  }

  void _pageChanged({String? property}) {
    _pageCurrentNotifier.value = widget.pdfViewerController?.pageNumber ?? 1;
    _updateZoomState();
  }

  void _zoomInPage() {
    if (_zoomLevel < _maxZoomLevelDefault) {
      if (_zoomLevel >= 1.0 && _zoomLevel < 1.25) {
        _zoomLevel = 1.25;
      } else if (_zoomLevel >= 1.25 && _zoomLevel < 1.50) {
        _zoomLevel = 1.50;
      } else if (_zoomLevel >= 1.50 && _zoomLevel < 2.0) {
        _zoomLevel = 2.0;
      } else if (_zoomLevel >= 2.0 && _zoomLevel < 2.50) {
        _zoomLevel = 2.5;
      } else if (_zoomLevel >= 2.5 && _zoomLevel < 3.0) {
        _zoomLevel = 3.0;
      } else if (_zoomLevel >= 3.0 && _zoomLevel < 3.5) {
        _zoomLevel = 3.5;
      } else if (_zoomLevel >= 3.5 && _zoomLevel < 4.0) {
        _zoomLevel = 4.0;
      }
      _updateZoomState();
      widget.pdfViewerController?.setZoom(
        widget.pdfViewerController!.centerPosition,
        _zoomLevel,
      );
    }
  }

  void _zoomOutPage() {
    if (_zoomLevel > _minZoomLevelDefault) {
      if (_zoomLevel > 1.0 && _zoomLevel <= 1.25) {
        _zoomLevel = 1.0;
      } else if (_zoomLevel > 1.25 && _zoomLevel <= 1.50) {
        _zoomLevel = 1.25;
      } else if (_zoomLevel > 1.50 && _zoomLevel <= 2.0) {
        _zoomLevel = 1.50;
      } else if (_zoomLevel > 2.0 && _zoomLevel <= 2.50) {
        _zoomLevel = 2.0;
      } else if (_zoomLevel > 2.5 && _zoomLevel <= 3.0) {
        _zoomLevel = 2.5;
      } else if (_zoomLevel > 3.0 && _zoomLevel <= 3.5) {
        _zoomLevel = 3.0;
      } else if (_zoomLevel > 3.5 && _zoomLevel <= 4.0) {
        _zoomLevel = 3.5;
      }
      _updateZoomState();
      widget.pdfViewerController?.setZoom(
        widget.pdfViewerController!.centerPosition,
        _zoomLevel,
      );
    }
  }

  void _updateZoomState() {
    final zoomLevel = widget.pdfViewerController?.currentZoom ?? 1.0;
    log('_PaginationPDFViewerState::_updateZoomState:zoomLevel = $zoomLevel');
    if (zoomLevel <= _maxZoomLevelDefault && zoomLevel > _minZoomLevelDefault) {
      _zoomOutPageNotifier.value = ZoomState.activate;
    } else {
      _zoomOutPageNotifier.value = ZoomState.inactivate;
    }

    if (zoomLevel < _maxZoomLevelDefault && zoomLevel >= _minZoomLevelDefault) {
      _zoomInPageNotifier.value = ZoomState.activate;
    } else {
      _zoomInPageNotifier.value = ZoomState.inactivate;
    }
  }
}
