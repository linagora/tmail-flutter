// Generated by dart2js (NullSafetyMode.sound, trust primitives, omit checks, lax runtime type, csp, intern-composite-values), the Dart to JavaScript compiler version: 3.5.4.
((s, d, e) => {
  s[d] = s[d] || {};
  s[d][e] = s[d][e] || [];
  s[d][e].push({p: "main.dart.js_11", e: "beginPart"});
})(self, "$__dart_deferred_initializers__", "eventLog");
$__dart_deferred_initializers__.current = function(hunkHelpers, init, holdersList, $) {
  var A, C,
  B = {DownloadAttachmentLoadingBar: function DownloadAttachmentLoadingBar(t0, t1) {
      this.viewState = t0;
      this.key = t1;
    },
    EmailPreviewerView$() {
      return new B.EmailPreviewerView(null);
    },
    EmailPreviewerView: function EmailPreviewerView(t0) {
      this.key = t0;
    },
    EmailPreviewerView_build_closure: function EmailPreviewerView_build_closure(t0, t1) {
      this.$this = t0;
      this.context = t1;
    },
    EmailPreviewerView_build__closure: function EmailPreviewerView_build__closure(t0) {
      this.context = t0;
    },
    EmailPreviewerView_build__closure0: function EmailPreviewerView_build__closure0(t0, t1) {
      this.$this = t0;
      this.context = t1;
    },
    EmailPreviewerView_build_closure0: function EmailPreviewerView_build_closure0(t0) {
      this.$this = t0;
    }
  },
  D, E;
  A = holdersList[0];
  C = holdersList[2];
  B = hunkHelpers.updateHolder(holdersList[8], B);
  D = holdersList[12];
  E = holdersList[13];
  B.DownloadAttachmentLoadingBar.prototype = {
    build$1(context) {
      var t1 = this.viewState;
      if (t1 instanceof A.StartDownloadAttachmentForWeb)
        return D.LinearProgressIndicator_UVb;
      if (t1 instanceof A.DownloadingAttachmentForWeb)
        return A.LinearPercentIndicator$(E.Color_4293128703, C.Radius_1_1, 5, C.EdgeInsets_0_0_0_0, t1.progress / 100, C.Color_4278221567);
      else
        return C.SizedBox_0_0_null_null;
    }
  };
  B.EmailPreviewerView.prototype = {
    build$1(context) {
      var _null = null;
      return A.Scaffold$(_null, C.Color_4294967295, new A.Stack(C.AlignmentDirectional_m1_m1, _null, C.StackFit_0, C.Clip_1, A._setArrayType([new A.Obx(new B.EmailPreviewerView_build_closure(this, context), _null), new A.Align(C.AlignmentDirectional_0_m1, _null, _null, new A.Obx(new B.EmailPreviewerView_build_closure0(this), _null), _null)], type$.JSArray_Widget), _null), _null, _null, true, _null, _null, _null);
    },
    _buildEMLPreviewerWidget$2(context, emlPreviewer) {
      var t3, t4,
        t1 = type$.MediaQuery,
        t2 = A.InheritedModel_inheritFrom(context, null, t1).data;
      t1 = A.InheritedModel_inheritFrom(context, null, t1).data;
      t3 = A.Directionality_maybeOf(context);
      if (t3 == null)
        t3 = C.TextDirection_1;
      t4 = $.$get$GetWidget__cache();
      A.Expando__checkType(this);
      return A.HtmlContentViewerOnWeb$(true, emlPreviewer.content, t3, t1.size._dy, false, null, A._instanceType(this)._eval$1("GetWidget.S")._as(t4._jsWeakMap.get(this)).get$onClickHyperLink(), t2.size._dx);
    }
  };
  var typesOffset = hunkHelpers.updateTypes(["DownloadAttachmentLoadingBar()"]);
  B.EmailPreviewerView_build_closure.prototype = {
    call$0() {
      var t3,
        t1 = this.$this,
        t2 = $.$get$GetWidget__cache();
      A.Expando__checkType(t1);
      t3 = this.context;
      return A._instanceType(t1)._eval$1("GetWidget.S")._as(t2._jsWeakMap.get(t1)).emlContentViewState.get$value(0).fold$2(0, new B.EmailPreviewerView_build__closure(t3), new B.EmailPreviewerView_build__closure0(t1, t3));
    },
    $signature: 3
  };
  B.EmailPreviewerView_build__closure.prototype = {
    call$1(failure) {
      var _null = null;
      A.Localizations_of(this.context, C.Type_AppLocalizations_CTL, type$.AppLocalizations).toString;
      return A.Center$(A.Text$(A.Intl__message("Cannot preview this eml file", _null, "previewEmailFromEMLFileFailed", _null, _null), _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null, _null), _null, _null);
    },
    $signature: 1831
  };
  B.EmailPreviewerView_build__closure0.prototype = {
    call$1(success) {
      var _this = this;
      if (success instanceof A.GetPreviewEmailEMLContentSharedSuccess)
        return _this.$this._buildEMLPreviewerWidget$2(_this.context, success.emlPreviewer);
      else if (success instanceof A.GetPreviewEMLContentInMemorySuccess)
        return _this.$this._buildEMLPreviewerWidget$2(_this.context, success.emlPreviewer);
      else if (success instanceof A.PreviewEmailFromEmlFileSuccess)
        return _this.$this._buildEMLPreviewerWidget$2(_this.context, success.emlPreviewer);
      else
        return D.Center_yTp;
    },
    $signature: 52
  };
  B.EmailPreviewerView_build_closure0.prototype = {
    call$0() {
      var t1 = this.$this,
        t2 = $.$get$GetWidget__cache();
      A.Expando__checkType(t1);
      return new B.DownloadAttachmentLoadingBar(A._instanceType(t1)._eval$1("GetWidget.S")._as(t2._jsWeakMap.get(t1)).downloadAttachmentState.get$value(0), null);
    },
    $signature: typesOffset + 0
  };
  (function inheritance() {
    var _inherit = hunkHelpers.inherit,
      _inheritMany = hunkHelpers.inheritMany;
    _inherit(B.DownloadAttachmentLoadingBar, A.StatelessWidget);
    _inherit(B.EmailPreviewerView, A.GetWidget);
    _inheritMany(A.Closure0Args, [B.EmailPreviewerView_build_closure, B.EmailPreviewerView_build_closure0]);
    _inheritMany(A.Closure, [B.EmailPreviewerView_build__closure, B.EmailPreviewerView_build__closure0]);
  })();
  A._Universe_addRules(init.typeUniverse, JSON.parse('{"DownloadAttachmentLoadingBar":{"StatelessWidget":[],"Widget":[],"DiagnosticableTree":[]},"EmailPreviewerView":{"GetWidget":["EmailPreviewerController"],"Widget":[],"DiagnosticableTree":[],"GetWidget.S":"EmailPreviewerController"}}'));
  var type$ = {
    AppLocalizations: A.findType("AppLocalizations"),
    JSArray_Widget: A.findType("JSArray<Widget>"),
    MediaQuery: A.findType("MediaQuery")
  };
  (function constants() {
    D.Center_yTp = new A.Center(C.Alignment_0_0, null, null, E.CupertinoLoadingWidget_null_null_null, null);
    D.LinearProgressIndicator_UVb = new A.LinearProgressIndicator(5, C.BorderRadius_ww8, null, E.Color_4293128703, C.Color_4278221567, null, null, null, null);
  })();
};
;
((d, h) => {
  d[h] = d.current;
  d.eventLog.push({p: "main.dart.js_11", e: "endPart", h: h});
})($__dart_deferred_initializers__, "VNdd+fNGw6plGAVIHtYEM80OShw=");
;