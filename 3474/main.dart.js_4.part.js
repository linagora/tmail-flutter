// Generated by dart2js (NullSafetyMode.sound, trust primitives, omit checks, lax runtime type, csp, intern-composite-values), the Dart to JavaScript compiler version: 3.5.4.
((s, d, e) => {
  s[d] = s[d] || {};
  s[d][e] = s[d][e] || [];
  s[d][e].push({p: "main.dart.js_4", e: "beginPart"});
})(self, "$__dart_deferred_initializers__", "eventLog");
$__dart_deferred_initializers__.current = function(hunkHelpers, init, holdersList, $) {
  var A, C, D,
  B = {
    SloganBuilder$(arrangedByHorizontal, hoverColor, logo, onTapCallback, padding, paddingText, sizeLogo, text, textAlign, textStyle) {
      return new B.SloganBuilder(true, text, textStyle, textAlign, logo, sizeLogo, onTapCallback, paddingText, padding, hoverColor, null);
    },
    SloganBuilder: function SloganBuilder(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) {
      var _ = this;
      _.arrangedByHorizontal = t0;
      _.text = t1;
      _.textStyle = t2;
      _.textAlign = t3;
      _.logo = t4;
      _.sizeLogo = t5;
      _.onTapCallback = t6;
      _.paddingText = t7;
      _.padding = t8;
      _.hoverColor = t9;
      _.key = t10;
    },
    _SloganBuilder_StatelessWidget_ImageLoaderMixin: function _SloganBuilder_StatelessWidget_ImageLoaderMixin() {
    }
  };
  A = holdersList[0];
  C = holdersList[2];
  D = holdersList[11];
  B = hunkHelpers.updateHolder(holdersList[9], B);
  B.SloganBuilder.prototype = {
    build$1(context) {
      var t3, t4, _this = this, _null = null,
        t1 = A.BorderRadius$all(new A.Radius(8, 8)),
        t2 = _this.padding;
      if (t2 == null)
        t2 = C.EdgeInsets_0_0_0_0;
      t3 = A._setArrayType([], type$.JSArray_Widget);
      t4 = _this.logo;
      if (t4 != null)
        t3.push(_this.buildImage$2$imagePath$imageSize(t4, _this.sizeLogo));
      t4 = _this.text;
      if (t4 == null)
        t4 = "";
      t3.push(new A.Padding(_this.paddingText, A.Text$(t4, _null, _null, _null, _null, _null, _null, _null, _null, _this.textStyle, _this.textAlign, _null, _null, _null, _null), _null));
      return A.Material$(C.Duration_200000, true, _null, A.InkWell$(false, t1, true, new A.Padding(t2, A.Row$(t3, C.CrossAxisAlignment_2, _null, C.MainAxisAlignment_0, C.MainAxisSize_1, _null), _null), _null, true, _null, _null, _null, _this.hoverColor, _null, _null, _null, _null, _null, _null, _null, _this.onTapCallback, _null, _null, _null, 8, _null, _null, _null), C.Clip_0, _null, 0, _null, _null, _null, _null, _null, C.MaterialType_4);
    }
  };
  B._SloganBuilder_StatelessWidget_ImageLoaderMixin.prototype = {};
  var typesOffset = hunkHelpers.updateTypes([]);
  (function inheritance() {
    var _mixin = hunkHelpers.mixin,
      _inherit = hunkHelpers.inherit;
    _inherit(B._SloganBuilder_StatelessWidget_ImageLoaderMixin, A.StatelessWidget);
    _inherit(B.SloganBuilder, B._SloganBuilder_StatelessWidget_ImageLoaderMixin);
    _mixin(B._SloganBuilder_StatelessWidget_ImageLoaderMixin, D.ImageLoaderMixin);
  })();
  A._Universe_addRules(init.typeUniverse, JSON.parse('{"SloganBuilder":{"StatelessWidget":[],"Widget":[],"DiagnosticableTree":[]}}'));
  var type$ = {
    JSArray_Widget: A.findType("JSArray<Widget>")
  };
};
;
((d, h) => {
  d[h] = d.current;
  d.eventLog.push({p: "main.dart.js_4", e: "endPart", h: h});
})($__dart_deferred_initializers__, "QeUN3kXa9K3Lxb0CmTc7hSZkKnU=");
;