// Generated by dart2js (NullSafetyMode.sound, trust primitives, omit checks, lax runtime type, csp, intern-composite-values), the Dart to JavaScript compiler version: 3.4.3.
((s, d, e) => {
  s[d] = s[d] || {};
  s[d][e] = s[d][e] || [];
  s[d][e].push({p: "main.dart.js_2", e: "beginPart"});
})(self, "$__dart_deferred_initializers__", "eventLog");
$__dart_deferred_initializers__.current = function(hunkHelpers, init, holdersList, $) {
  var B, C,
  A = {
    ApplicationLogoWidthTextWidget$(margin, onTapAction) {
      var t1;
      $.$get$Get();
      t1 = $.GetInstance__getInstance;
      if (t1 == null)
        t1 = $.GetInstance__getInstance = C.C_GetInstance;
      return new A.ApplicationLogoWidthTextWidget(t1.find$1$1$tag(0, null, type$.ImagePaths), onTapAction, margin, null);
    },
    ApplicationLogoWidthTextWidget: function ApplicationLogoWidthTextWidget(t0, t1, t2, t3) {
      var _ = this;
      _._application_logo_with_text_widget$_imagePaths = t0;
      _.onTapAction = t1;
      _.margin = t2;
      _.key = t3;
    },
    ApplicationVersionWidget: function ApplicationVersionWidget(t0, t1, t2, t3) {
      var _ = this;
      _.padding = t0;
      _.title = t1;
      _.textStyle = t2;
      _.key = t3;
    },
    _ApplicationVersionWidgetState: function _ApplicationVersionWidgetState(t0, t1) {
      var _ = this;
      _._application_version_widget$_applicationManager = t0;
      _._widget = _._versionStream = null;
      _._debugLifecycleState = t1;
      _._framework$_element = null;
    },
    _ApplicationVersionWidgetState_build_closure: function _ApplicationVersionWidgetState_build_closure(t0) {
      this.$this = t0;
    }
  },
  D;
  B = holdersList[0];
  C = holdersList[2];
  A = hunkHelpers.updateHolder(holdersList[9], A);
  D = holdersList[12];
  A.ApplicationLogoWidthTextWidget.prototype = {
    build$1(context) {
      var _null = null,
        value = $.$get$dotenv().maybeGet$2$fallback("PLATFORM", "other"),
        t1 = value.toLowerCase() === "saas" ? "assets/images/ic_logo_with_text_beta.svg" : "assets/images/ic_logo_with_text.svg";
      return B.TMailButtonWidget_TMailButtonWidget$fromIcon(C.Color_0, 20, C.Color_0, t1, _null, 33, _null, this.margin, 1 / 0, _null, this.onTapAction, C.EdgeInsets_0_0_0_0, _null);
    }
  };
  A.ApplicationVersionWidget.prototype = {
    createState$0() {
      $.$get$Get();
      var t1 = $.GetInstance__getInstance;
      if (t1 == null)
        t1 = $.GetInstance__getInstance = C.C_GetInstance;
      return new A._ApplicationVersionWidgetState(t1.find$1$1$tag(0, null, type$.ApplicationManager), C._StateLifecycle_0);
    }
  };
  A._ApplicationVersionWidgetState.prototype = {
    initState$0() {
      this.super$State$initState();
      this._versionStream = this._application_version_widget$_applicationManager.getVersion$0();
    },
    build$1(context) {
      return B.FutureBuilder$(new A._ApplicationVersionWidgetState_build_closure(this), this._versionStream, type$.String);
    },
    dispose$0() {
      this._versionStream = null;
      this.super$State$dispose();
    }
  };
  var typesOffset = hunkHelpers.updateTypes([]);
  A._ApplicationVersionWidgetState_build_closure.prototype = {
    call$2(context, snapshot) {
      var t2, t3, t4, _null = null,
        t1 = snapshot.data;
      if (t1 != null) {
        t2 = this.$this;
        t3 = t2._widget;
        t4 = t3.padding;
        if (t4 == null)
          t4 = C.EdgeInsets_0_8_0_0;
        t3 = t3.title;
        if (t3 == null)
          t3 = "v.";
        t1 = B.S(t1);
        t2 = t2._widget.textStyle;
        if (t2 == null) {
          t2 = B.Theme_of(context).textTheme.labelMedium;
          t2 = t2 == null ? _null : t2.copyWith$3$color$fontSize$fontWeight(C.Color_4285364357, 13, C.FontWeight_4_500);
        }
        return new B.Padding(t4, B.Text$(t3 + t1, _null, _null, _null, _null, _null, _null, _null, _null, t2, C.TextAlign_2, _null, _null, _null, _null), _null);
      } else
        return C.SizedBox_0_0_null_null;
    },
    $signature: 1786
  };
  (function inheritance() {
    var _inherit = hunkHelpers.inherit;
    _inherit(A.ApplicationLogoWidthTextWidget, B.StatelessWidget);
    _inherit(A.ApplicationVersionWidget, B.StatefulWidget);
    _inherit(A._ApplicationVersionWidgetState, B.State0);
    _inherit(A._ApplicationVersionWidgetState_build_closure, B.Closure2Args);
  })();
  B._Universe_addRules(init.typeUniverse, JSON.parse('{"ApplicationLogoWidthTextWidget":{"StatelessWidget":[],"Widget":[],"DiagnosticableTree":[]},"ApplicationVersionWidget":{"StatefulWidget":[],"Widget":[],"DiagnosticableTree":[]},"_ApplicationVersionWidgetState":{"State0":["ApplicationVersionWidget"]}}'));
  var type$ = {
    ApplicationManager: B.findType("ApplicationManager"),
    ImagePaths: B.findType("ImagePaths"),
    String: B.findType("String")
  };
  (function constants() {
    D.TextStyle_OkG0 = new B.TextStyle(true, C.Color_4278221567, null, null, null, null, 14, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
  })();
};
;
((d, h) => {
  d[h] = d.current;
  d.eventLog.push({p: "main.dart.js_2", e: "endPart", h: h});
})($__dart_deferred_initializers__, "sDqy+fAKqr+Kr0ndtoyqKWwZD9A=");
;