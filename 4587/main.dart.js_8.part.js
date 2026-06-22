((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={
ccs(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){return new C.Ry(f,a2,l,h,g,x,k,r,t,v,u,d,w,j,i,p,m,n,s,a1,e,a0,o,q)},
esn(d,e,f,g){if(g===e)return!1
return d?g>=f:g>f},
Ry:function Ry(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.r=h
_.w=i
_.x=j
_.y=k
_.z=l
_.Q=m
_.as=n
_.at=o
_.ay=p
_.ch=q
_.CW=r
_.cx=s
_.cy=t
_.db=u
_.dx=v
_.dy=w
_.fr=x
_.fx=a0
_.fy=a1
_.a=a2},
azu:function azu(d){var _=this
_.f=_.e=_.d=$
_.w=_.r=null
_.x=!0
_.z=_.y=$
_.Q=!1
_.as=null
_.jo$=d
_.c=_.a=null},
dkj:function dkj(d,e){this.a=d
this.b=e},
dkk:function dkk(d){this.a=d},
dkl:function dkl(d,e){this.a=d
this.b=e},
dkm:function dkm(d){this.a=d},
dki:function dki(d){this.a=d},
dkh:function dkh(d){this.a=d},
aEN:function aEN(){},
a3v:function a3v(d,e,f){this.a=d
this.b=e
this.c=f},
boq:function boq(){},
cff(d){return new C.cfe(d)},
cfe:function cfe(d){this.e=d},
aUP:function aUP(d){this.a=null
this.b=d},
cfh:function cfh(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
cfi:function cfi(d,e,f,g,h,i){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i},
cfg:function cfg(d){this.a=d},
esv(d){var x,w,v,u,t,s,r,q,p="text/html"
if(!(B.d.q(d,$.ecd())&&B.d.q(d,$.ecc())))return d
try{new DOMParser().parseFromString(d,p).toString}catch(x){return d}w=new DOMParser().parseFromString('<div class="quote-toggle-container" >'+d+"</div>",p)
v=w.querySelectorAll(".quote-toggle-container > blockquote")
v.toString
u=y.N
t=new A.aaA(v,u)
for(s=1;t.gB(0)===0;){if(s>=3)return d
v=w.querySelectorAll(".quote-toggle-container"+B.d.aY(" > div",s)+" > blockquote")
v.toString
t=new A.aaA(v,u);++s}r=t.$ti.c.a(B.w2.ga0(t.a))
q=new DOMParser().parseFromString('      <button class="quote-toggle-button collapsed" title="Show trimmed content">\n          <span class="dot"></span>\n          <span class="dot"></span>\n          <span class="dot"></span>\n      </button>',p).querySelector(".quote-toggle-button")
v=r.parentNode
if(v!=null&&q!=null)v.insertBefore(q,r).toString
v=w.documentElement
v=v==null?null:J.ejt(v)
return v==null?d:v}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[12],C)
D=c[22]
C.Ry.prototype={
a_(){return new C.azu(null)}}
C.azu.prototype={
aq(){var x,w=this
w.b9R()
x=w.a
w.e=x.e
w.f=x.d
w.y=x.cy
if(!A.FI()&&!A.FJ()){x=w.a.fy
w.as=new C.aUP(x)}w.aGs()
x=window
x.toString
x=A.jM(x,"message",w.gbsw(),!1,y._)
w.z!==$&&A.cC()
w.z=x},
bsx(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{x=B.aw.h8(0,new A.My([],[]).La(d.data,!0))
w=J.ag(x,"view")
t=n.d
t===$&&A.d()
if(!J.v(w,t))return
v=J.ag(x,"type")
if(n.gaC1()){t=v
t=(t==null?m:B.d.q(t,"toDart: onScrollChanged"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
n.brW(x,t)
return}else{if(n.gaC1()){t=v
t=(t==null?m:B.d.q(t,"toDart: onScrollEnd"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
s=J.ag(x,"velocity")
r=J.dRD(s==null?0:s,800)
q=t.f
p=B.c.gbz(q).at
p.toString
t.jx(B.i.eb(p+r,B.c.gbz(q).gfd(),B.c.gbz(q).geA()),B.fJ,B.i5)
return}else{t=v
q=n.a
if(q.Q!=null)t=(t==null?m:B.d.q(t,"toDart: iframeKeydown"))===!0
else t=!1
if(t){n.btd(x)
return}else{t=v
if(q.fx)t=(t==null?m:B.d.q(t,"toDart: iframeClick"))===!0
else t=!1
if(t){n.btc(x)
return}else{t=v
if((t==null?m:B.d.q(t,"toDart: iframeLinkHover"))===!0){n.bte(x)
return}else{t=v
if((t==null?m:B.d.q(t,"toDart: iframeLinkOut"))===!0){n.btf(x)
return}}}}}}if(J.v(J.ag(x,"message"),"iframeHasBeenLoaded"))n.Q=!0
if(!n.Q)return
t=v
if((t==null?m:B.d.q(t,"toDart: htmlHeight"))===!0)n.bq2(J.ag(x,"height"))
else{t=v
t=(t==null?m:B.d.q(t,"toDart: htmlWidth"))===!0
if(t)n.a.toString
if(t)n.bq3(J.ag(x,"width"))
else{t=v
if((t==null?m:B.d.q(t,"toDart: OpenLink"))===!0){t=J.ag(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"&&B.d.aP(t,"mailto:")){q=n.a.y
if(q!=null)q.$1(A.iE(t))}}else{t=v
if((t==null?m:B.d.q(t,"toDart: onClickHyperLink"))===!0){t=J.ag(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"){q=n.a.z
if(q!=null)q.$1(A.iE(t))}}}}}}catch(o){u=A.M(o)
A.w(A.G(n).l(0)+"::_handleMessageEvent:Exception = "+A.e(u),m,m,B.q,m,!1)}},
gaC1(){var x=this.a.ay
if(x!=null)x=x.f.length!==0===!0
else x=!1
return x},
brW(d,e){var x,w,v,u,t,s,r,q
try{t=J.ag(d,"deltaY")
x=t==null?0:t
s=e.f
r=B.c.gbz(s).at
r.toString
w=r+x
r=A.FI()||A.FJ()
if(r){v=J.ada(w,B.c.gbz(s).gfd(),B.c.gbz(s).geA())
e.jx(v,B.a7,B.pl)}else if(w<B.c.gbz(s).gfd())e.iO(B.c.gbz(s).gfd())
else if(w>B.c.gbz(s).geA())e.iO(B.c.gbz(s).geA())
else e.iO(w)}catch(q){u=A.M(q)
A.w(A.G(this).l(0)+"::_handleIframeOnScrollChangedListener:Exception = "+A.e(u),null,null,B.q,null,!1)}},
bq2(d){var x,w,v,u,t=this
if(d==null){x=t.e
x===$&&A.d()
w=x}else w=d
x=t.c
if(x!=null){v=A.hd(w)+t.a.dx
A.w(A.G(t).l(0)+"::_handleContentHeightEvent: ScrollHeightWithBuffer = "+A.e(v),null,null,B.h,null,!1)
x=t.e
x===$&&A.d()
u=t.y
u===$&&A.d()
if(C.esn(t.a.fr,x,u,v))t.X(new C.dkj(t,v))}if(t.c!=null&&t.x)t.X(new C.dkk(t))},
bq3(d){var x,w,v=this
if(d==null){x=v.f
x===$&&A.d()
w=x}else w=d
if(v.c!=null&&J.dRC(w,v.a.db)&&v.a.at)v.X(new C.dkl(v,w))},
btd(d){var x,w,v,u,t=null
try{v=J.al(d)
x=new C.a3v(A.aE(v.j(d,"key")),A.aE(v.j(d,"code")),J.v(v.j(d,"shift"),!0))
A.w(A.G(this).l(0)+"::_handleOnIFrameKeyboardEvent:\ud83d\udce5 Shortcut pressed: "+A.e(x),t,t,B.h,t,!1)
v=this.a.Q
if(v!=null)v.$1(x)}catch(u){w=A.M(u)
A.w(A.G(this).l(0)+"::_handleOnIFrameKeyboardEvent: Exception = "+A.e(w),t,t,B.q,t,!1)}},
btc(d){var x,w,v,u=null
try{A.w(A.G(this).l(0)+"::_handleOnIFrameClickEvent: "+A.e(d),u,u,B.h,u,!1)
w=this.a.as
if(w!=null)w.$0()}catch(v){x=A.M(v)
A.w(A.G(this).l(0)+"::_handleOnIFrameClickEvent: Exception = "+A.e(x),u,u,B.q,u,!1)}},
bte(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{A.w(A.G(n).l(0)+"::_handleOnIFrameLinkHoverEvent: "+A.e(d),m,m,B.h,m,!1)
t=J.al(d)
s=t.j(d,"url")
x=s==null?"":s
w=t.j(d,"rect")
if(w!=null){t=J.ag(w,"x")
t=t==null?m:J.xw(t)
if(t==null)t=0
r=J.ag(w,"y")
r=r==null?m:J.xw(r)
if(r==null)r=0
q=J.ag(w,"width")
q=q==null?m:J.xw(q)
if(q==null)q=0
p=J.ag(w,"height")
p=p==null?m:J.xw(p)
if(p==null)p=0
v=new A.a9(t,r,t+q,r+p)
t=n.c
if(t!=null){r=n.as
if(r!=null)r.as7(0,t,x,v)}}}catch(o){u=A.M(o)
A.w(A.G(n).l(0)+"::_handleOnIFrameLinkHoverEvent: Exception = "+A.e(u),m,m,B.q,m,!1)}},
btf(d){var x,w,v,u=null
try{A.w(A.G(this).l(0)+"::_handleOnIFrameLinkOutEvent: "+A.e(d),u,u,B.h,u,!1)
w=this.as
if(w!=null)w.ev()}catch(v){x=A.M(v)
A.w(A.G(this).l(0)+"::_handleOnIFrameLinkOutEvent: Exception = "+A.e(x),u,u,B.q,u,!1)}},
bc(d){var x,w,v=this
v.bp(d)
x=d.f
A.w(A.G(v).l(0)+"::didUpdateWidget():Old-Direction: "+x.l(0)+" | Current-Direction: "+v.a.f.l(0),null,null,B.h,null,!1)
w=v.a
if(w.c!==d.c||w.f!==x)v.aGs()
x=v.a
w=x.e
if(w!==d.e)v.e=w
x=x.d
if(x!==d.d)v.f=x},
aGs(){var x,w,v,u=this,t="\n          \n          ",s=u.d=A.dWB(10),r=u.a,q=r.c,p=!r.fr,o=p?"            clearTimeout(_resizeDebounceTimer);\n            if (typeof resizeObserver !== 'undefined') resizeObserver.disconnect();\n          ":"",n=p?'          var _lastResizeHeight = 0;\n          var _resizeDebounceTimer;\n          const resizeObserver = new ResizeObserver((entries) => {\n            clearTimeout(_resizeDebounceTimer);\n            _resizeDebounceTimer = setTimeout(function() {\n              var height = document.body.scrollHeight;\n              if (height === _lastResizeHeight) return;\n              _lastResizeHeight = height;\n              window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n            }, 50);\n          });\n        ':"",m=r.y!=null,l=m?'                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':"",k=r.z!=null,j=k?'                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':""
k=k?"                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                ":""
m=m?"                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                ":""
p=p?"resizeObserver.observe(document.body);":""
if(r.ch)q=C.esv(q)
r=y.s
x=A.c([],r)
if(u.a.ch)x.push("    <style>\n      .quote-toggle-button + blockquote {\n        display: block; /* Default display */\n      }\n      .quote-toggle-button.collapsed + blockquote {\n        display: none;\n      }\n      .quote-toggle-button {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        width: 20px;\n        height: 20px;\n        gap: 2px;\n        background-color: #d7e2f5;\n        padding: 0;\n        margin: 8px 0;\n        border-radius: 50%;\n        transition: background-color 0.2s ease-in-out;\n        border: none;\n        cursor: pointer;\n        -webkit-appearance: none;\n        -moz-appearance: none;\n        appearance: none;\n        -webkit-user-select: none; /* Safari */\n        -moz-user-select: none; /* Firefox */\n        -ms-user-select: none; /* IE 10+ */\n        user-select: none; /* Standard syntax */\n        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */\n      }\n      .quote-toggle-button:hover {\n        background-color: #cdcdcd !important;\n      }\n      .dot {\n        width: 3.75px;\n        height: 3.75px;\n        background-color: #55687d;\n        border-radius: 50%;\n      }\n    </style>")
if(u.a.CW)x.push("    html, body {\n      overflow: hidden;\n      overscroll-behavior: none;\n      scrollbar-width: none; /* Firefox */\n      -ms-overflow-style: none; /* IE/Edge */\n    }\n    ::-webkit-scrollbar {\n        display: none;\n      }\n  ")
w=B.c.iN(x)
s=A.c(["      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n          window.removeEventListener('load', handleOnLoad);\n          "+o+'\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes("toIframe:")) {\n            var data = JSON.parse(e.data);\n            if (data["view"].includes("'+s+'")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n\n        '+n+"\n        \n        "+l+"\n        \n        \n        \n        "+j+'\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getWidth"}), "*");\n          \n          '+k+t+m+t+p+"\n        }\n      </script>\n    ","    <script type=\"text/javascript\">\n      document.addEventListener('wheel', function(e) {\n        e.ctrlKey && e.preventDefault();\n      }, {\n        passive: false,\n      });\n      window.addEventListener('keydown', disableZoomControl);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', disableZoomControl);\n      });\n      \n      function disableZoomControl(event) {\n        if (event.metaKey || event.ctrlKey) {\n          switch (event.key) {\n            case '=':\n            case '-':\n              event.preventDefault();\n              break;\n          }\n        }\n      }\n    </script>\n  ","    <script type=\"text/javascript\">\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  ",'      <script type="text/javascript">\n        const displayWidth = '+A.e(u.a.d)+";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          // Remove width and height properties from style string\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          // Extract width and height values with units from style string\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          // Normalize style attribute to ensure proper responsive behavior\n          let style = attrs['style'];\n          \n          if (!style) {\n            attrs['style'] = 'max-width:100%;height:auto;display:inline;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          // Ensure proper style string formatting\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          // Add responsive defaults if missing\n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;';\n          }\n    \n          if (!style.includes('height')) {\n            style += 'height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          // Normalize width/height attributes and remove if necessary\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          // Remove attribute if value is null or undefined\n          if (widthStr === null || widthStr === undefined) {\n            delete attrs['width'];\n          } else if (displayWidth !== undefined) {\n            const widthValue = parseFloat(widthStr);\n            if (!isNaN(widthValue)) {\n              if (widthValue > displayWidth) {\n                delete attrs['width'];\n                delete attrs['height'];\n              }\n            }\n          }\n    \n          // Remove height attribute if value is null or undefined\n          if (heightStr === null || heightStr === undefined) {\n            delete attrs['height'];\n          }\n        }\n    \n        function normalizeImageSize(attrs) {\n          // Apply both style and attribute normalization\n          normalizeWidthHeightAttribute(attrs);\n          normalizeStyleAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          // Process all images on the page\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            // Handle style attribute\n            if (attrs.style !== null && attrs.style !== undefined) {\n              img.setAttribute('style', attrs.style);\n            } else {\n              img.removeAttribute('style');\n            }\n    \n            // Handle width attribute\n            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {\n              img.setAttribute('width', attrs.width);\n            } else {\n              img.removeAttribute('width');\n            }\n    \n            // Handle height attribute\n            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {\n              img.setAttribute('height', attrs.height);\n            } else {\n              img.removeAttribute('height');\n            }\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          // Error-safe wrapper for the normalization function\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        // Run normalization when page loads\n        window.onload = safeApplyImageNormalization;\n      </script>\n    "],r)
if(u.a.ch)s.push("    <script>\n      document.addEventListener('DOMContentLoaded', function() {\n        const buttons = document.querySelectorAll('.quote-toggle-button');\n        buttons.forEach(button => {\n          button.onclick = function() {\n            const blockquote = this.nextElementSibling;\n            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {\n              this.classList.toggle('collapsed');\n              if (this.classList.contains('collapsed')) {\n                this.title = 'Show trimmed content';\n              } else {\n                this.title = 'Hide expanded content';\n              }\n            }\n          };\n        });\n      });\n    </script>")
if(u.a.ay!=null){r=A.FI()||A.FJ()
p=u.d
s.push(r?'    <script type="text/javascript">\n      let lastY = 0;\n      let lastTime = 0;\n      let velocity = 0;\n    \n      function onTouchStart(e) { \n        lastY = e.touches[0].clientY;\n        lastTime = performance.now();\n        velocity = 0;\n      }\n    \n      function onTouchMove(e) { \n        const now = performance.now();\n        const y = e.touches[0].clientY;\n        const dy = lastY - y;\n        const dt = now - lastTime;\n    \n        if (dt > 0) {\n          velocity = dy / dt; // px per ms\n          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity\n        }\n    \n        lastY = y;\n        lastTime = now;\n    \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+'",\n          type: "toDart: onScrollChanged",\n          deltaY: dy,\n        }), \'*\');\n      }\n    \n      function onTouchEnd(e) { \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+"\",\n          type: \"toDart: onScrollEnd\",\n          velocity: velocity,\n        }), '*');\n      }\n    \n      window.addEventListener('touchstart', onTouchStart, { passive: true });\n      window.addEventListener('touchmove', onTouchMove, { passive: true });\n      window.addEventListener('touchend', onTouchEnd, { passive: true });\n    \n      window.addEventListener('pagehide', () => {\n        window.removeEventListener('touchstart', onTouchStart);\n        window.removeEventListener('touchmove', onTouchMove);\n        window.removeEventListener('touchend', onTouchEnd);\n      });\n    </script>\n\n  ":'    <script type="text/javascript">\n      function onWheel(e) { \n        const deltaY = event.deltaY;\n        window.parent.postMessage(JSON.stringify({\n          "view": "'+p+'",\n          "type": "toDart: onScrollChanged",\n          "deltaY": deltaY\n        }), "*");\n      }\n      \n      window.addEventListener(\'wheel\', onWheel, { passive: true });\n      \n      window.addEventListener(\'pagehide\', (event) => {\n        window.removeEventListener(\'wheel\', onWheel);\n      });\n    </script>\n  ')}if(u.a.Q!=null)s.push("    <script type=\"text/javascript\">\n      window.addEventListener('keydown', handleIframeKeydown);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', handleIframeKeydown);\n      });\n      \n      function handleIframeKeydown(event) {\n        const payload = {\n          view: '"+u.d+"',\n          type: 'toDart: iframeKeydown',\n          key: event.key,\n          code: event.code,\n          shift: event.shiftKey\n        };\n        window.parent.postMessage(JSON.stringify(payload), \"*\");\n      }\n    </script>\n  ")
if(u.a.fx)s.push("    <script type=\"text/javascript\">\n      document.addEventListener('click', function (e) {\n        try {\n          const payload = {\n            view: '"+u.d+"',\n            type: 'toDart: iframeClick',\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        } catch (_) {}\n      });\n    </script>\n  ")
if(!A.FI()&&!A.FJ()){r=u.d
s.push('    <script type="text/javascript">\n      document.addEventListener("mouseover", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const rect = target.getBoundingClientRect();\n          \n          const payload = {\n            view: \''+r+'\',\n            type: \'toDart: iframeLinkHover\',\n            url: target.href,\n            rect: {\n              x: rect.x,\n              y: rect.y,\n              width: rect.width,\n              height: rect.height\n            }\n          };\n          window.parent.postMessage(JSON.stringify(payload), "*");\n        }\n      });\n    \n      document.addEventListener("mouseout", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const payload = {\n            view: \''+r+"',\n            type: 'toDart: iframeLinkOut'\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        }\n      });\n    </script>\n  ")}v=B.c.iN(s)
s=u.y
s===$&&A.d()
r=u.a
p=r.db
o=r.f
n=r.r
m=r.w
r=r.x
r=m?"    body {\n      font-weight: 400;\n      font-size: "+r+"px;\n      font-style: normal;\n    }\n    \n    p {\n      margin: 0px;\n    }\n  ":""
o=o===B.aE?'dir="rtl"':""
n=n!=null?"margin: "+A.e(n)+";":""
u.w='      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      <style>\n            @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");\n      font-weight: 400;\n      font-style: normal;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");\n      font-weight: 500;\n      font-style: medium;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");\n      font-weight: 600;\n      font-style: semi-bold;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");\n      font-weight: 700;\n      font-style: bold;\n    }\n    \n    body {\n      font-family: \'Inter\', sans-serif;\n    }\n  \n        \n        '+r+"\n        \n        *, *::before, *::after {\n          box-sizing: border-box;\n        }\n\n        .tmail-content {\n          min-height: "+A.e(s)+"px;\n          min-width: "+p+"px;\n          overflow: auto;\n          overflow-wrap: break-word;\n          word-break: break-word;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n        \n        pre {\n          white-space: pre-wrap;\n        }\n        \n        table {\n          white-space: normal !important;\n        }\n              \n        @media only screen and (max-width: 600px) {\n          table {\n            width: 100% !important;\n          }\n          \n          a {\n            width: -webkit-fill-available !important;\n          }\n        }\n        \n        table, td, th {\n          word-break: normal !important;\n        }\n        \n        "+w+"\n      </style>\n      </head>\n      <body "+o+' style = "overflow-x: hidden; '+n+'";>\n      <div class="tmail-content">'+q+"</div>\n      <style>html, body { height: auto !important; }</style>\n      "+v+"\n      </body>\n      </html> \n    "
u.r=A.bP(!0,y.y)},
t(d){var x=this
x.yz(d)
if(x.a.fr)return x.avA()
else return A.eQ(new C.dkm(x))},
avA(){var x,w=this,v=null,u=A.G(w).l(0),t=w.e
t===$&&A.d()
A.w(u+"::_buildHtmlElementView: ActualHeight: "+A.e(t),v,v,B.h,v,!1)
t=A.c([],y.p)
u=w.w
if((u==null?v:B.d.ad(u).length!==0)===!0)t.push(A.QZ(new C.dki(w),w.r,y.y))
if(w.x)t.push(D.a7y)
x=new A.cv(B.a3,v,B.Z,B.F,t,v)
w.a.toString
u=w.f
u===$&&A.d()
return new A.b4(u,v,x,v)},
p(){var x,w=this
w.w=null
x=w.z
x===$&&A.d()
x.ag(0)
if(!A.FI()&&!A.FJ()){x=w.as
if(x!=null)x.ev()
w.as=null}w.aD()},
guE(){return this.a.cx}}
C.aEN.prototype={
aq(){this.aO()
if(this.a.cx)this.wG()},
j5(){var x=this.jo$
if(x!=null){x.b3()
x.il()
this.jo$=null}this.qo()}}
C.a3v.prototype={
aRI(d,e,f){return this.a.toLowerCase()===e.toLowerCase()&&this.c===f},
D3(d,e){return this.aRI(0,e,!1)},
gC(){return[this.a,this.b,this.c]}}
C.boq.prototype={}
C.cfe.prototype={}
C.aUP.prototype={
as7(d,e,f,g){var x,w,v,u,t,s,r,q,p,o,n=this,m={}
if(n.a!=null){n.ev()
A.ajF(new C.cfh(n,e,f,g),y.P)
return}x=A.mf(e,!1)
if(x==null)return
w=e.gap()
v=g.iB(w instanceof A.a7?A.cY(w.ca(0,null),B.r):B.r)
u=y.w
t=A.Q(e,B.w,u).w.a.a
u=A.Q(e,B.w,u).w
s=t<400?t-24:400
r=v.d
q=r+28+4>u.a.b
p=q?v.b-28-4:r+4
o=m.a=v.a
if((o+s>t?m.a=t-s-12:o)<12)m.a=12
m=A.mM(new C.cfi(m,n,q,p,s,f),!1,!1,!1)
n.a=m
x.lM(0,m)},
ev(){var x=this.a
if(x!=null)x.e2(0)
this.a=null}}
var z=a.updateTypes(["~(yo)","~()"])
C.dkj.prototype={
$0(){var x=this.a
x.e=this.b
x.x=!1},
$S:0}
C.dkk.prototype={
$0(){this.a.x=!1},
$S:0}
C.dkl.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.dkm.prototype={
$2(d,e){var x=this.a,w=x.y
w===$&&A.d()
x.y=Math.min(e.d,w)
return x.avA()},
$S:106}
C.dki.prototype={
$2(d,e){var x,w,v,u,t=null
if(e.b!=null){x=this.a
w=new A.al8(new C.dkh(x),new A.aT(A.e(x.w)+"-"+A.e(x.a.a),y.O))
v=x.a.dy
u=x.e
x=x.f
if(v!=null){u===$&&A.d()
x===$&&A.d()
return A.a8(t,w,B.k,t,new A.as(0,1/0,0,v),t,t,u,t,t,t,t,t,x)}else{u===$&&A.d()
x===$&&A.d()
return new A.b4(x,u,w,t)}}else return B.x},
$S:206}
C.dkh.prototype={
$1(d){var x=this.a,w=x.f
w===$&&A.d()
d.width=B.i.l(w)
w=x.e
w===$&&A.d()
d.height=B.i.l(w)
x=x.w
d.srcdoc=x==null?"":x},
$S:785}
C.cfh.prototype={
$0(){var x=this,w=x.b
if(w.e!=null)x.a.as7(0,w,x.c,x.d)},
$S:7}
C.cfi.prototype={
$1(d){var x=this,w=null,v=x.b,u=A.jG(0,A.cU(B.c0,w,B.N,!1,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,v.gqU(),w,w,w,w,w,w,w,w,!1,B.a1),w),t=x.a.a,s=A.c([new A.c7(0,B.U,B.n.au(0.15),B.r,20)],y.V)
v=v.b.e
if(v==null)v=D.b33
return A.dMm(new C.cfg(x.c),new A.cv(B.a3,w,B.Z,B.F,A.c([u,A.kJ(w,A.cV(A.ct(!1,B.D,!0,B.kr,A.a8(w,A.aj(x.f,w,1,B.A,w,w,v,w,w,w),B.k,w,new A.as(0,x.e,28,1/0),new A.bb(B.n,w,w,B.kr,s,w,w,B.B),w,w,w,w,B.mM,w,w,w),B.k,w,0,w,w,w,w,w,B.aJ)),w,t,x.d,w)],y.p),w),B.fP,B.zx,new A.bG(0,1,y.t),y.i)},
$S:341}
C.cfg.prototype={
$3(d,e,f){var x=this.a?-1:1
return A.nq(A.avO(f,new A.D(0,x*(1-e)*8)),null,e)},
$S:342};(function aliases(){var x=C.aEN.prototype
x.b9R=x.aq})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
x(C.azu.prototype,"gbsw","bsx",0)
w(C.aUP.prototype,"gqU","ev",1)})();(function inheritance(){var x=a.mixinHard,w=a.mixin,v=a.inherit,u=a.inheritMany
v(C.Ry,A.ah)
v(C.aEN,A.af)
v(C.azu,C.aEN)
u(A.xL,[C.dkj,C.dkk,C.dkl,C.cfh])
u(A.xM,[C.dkm,C.dki])
u(A.qx,[C.dkh,C.cfi,C.cfg])
u(A.X,[C.boq,C.cfe,C.aUP])
v(C.a3v,C.boq)
x(C.aEN,A.tV)
w(C.boq,A.o)})()
A.HC(b.typeUniverse,JSON.parse('{"Ry":{"ah":[],"j":[],"p":[]},"azu":{"af":["Ry"]},"a3v":{"o":[]}}'))
var y=(function rtii(){var x=A.ao
return{V:x("N<c7>"),s:x("N<h>"),p:x("N<j>"),w:x("oV"),_:x("yo"),P:x("b0"),t:x("bG<aq>"),O:x("aT<h>"),N:x("aaA<iM>"),y:x("B"),i:x("aq")}})();(function constants(){D.aZn=new A.b4(30,30,B.z9,null)
D.aQP=new A.Z(B.cq,D.aZn,null)
D.a7y=new A.e4(B.d6,null,null,D.aQP,null)
D.b33=new A.an(!0,B.m,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)})();(function lazyInitializers(){var x=a.lazyFinal
x($,"fkv","ecd",()=>A.aY("<[a-zA-Z][^>\\s]*[^>]*>",!0,!1,!1,!1))
x($,"fku","ecc",()=>A.aY("</[a-zA-Z][^>]{0,128}>",!0,!1,!1,!1))})()};
(a=>{a["N1pzwl1JiAXGf7GdYH75OpiwDPI="]=a.current})($__dart_deferred_initializers__);