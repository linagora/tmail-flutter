((a,b,c)=>{a[b]=a[b]||{}
a[b][c]=a[b][c]||[]
a[b][c].push({p:"main.dart.js_8",e:"beginPart"})})(self,"$__dart_deferred_initializers__","eventLog")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={
bRB(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){return new C.ME(f,a2,l,h,g,x,k,r,t,v,u,d,w,j,i,p,m,n,s,a1,e,a0,o,q)},
ME:function ME(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){var _=this
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
aqu:function aqu(d){var _=this
_.f=_.e=_.d=$
_.w=_.r=null
_.x=!0
_.z=_.y=$
_.Q=!1
_.as=null
_.ew$=d
_.c=_.a=null},
cSB:function cSB(d,e){this.a=d
this.b=e},
cSC:function cSC(d){this.a=d},
cSD:function cSD(d,e){this.a=d
this.b=e},
cSE:function cSE(d){this.a=d},
cSA:function cSA(d){this.a=d},
cSz:function cSz(d){this.a=d},
avb:function avb(){},
Yi:function Yi(d,e,f){this.a=d
this.b=e
this.c=f},
b8w:function b8w(){},
bUn(d){return new C.bUm(d)},
bUm:function bUm(d){this.e=d},
aIU:function aIU(d){this.a=null
this.b=d},
bUp:function bUp(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
bUq:function bUq(d,e,f,g,h,i){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i},
bUo:function bUo(d){this.a=d},
dPN(d){var x,w,v,u,t,s,r,q,p="text/html"
if(!(B.d.t(d,A.bo("<[a-zA-Z][^>]*>",!0,!1,!1,!1))&&B.d.t(d,A.bo("</[a-zA-Z][^>]*>",!0,!1,!1,!1))))return d
try{new DOMParser().parseFromString(d,p).toString}catch(x){return d}w=new DOMParser().parseFromString('<div class="quote-toggle-container" >'+d+"</div>",p)
v=w.querySelectorAll(".quote-toggle-container > blockquote")
v.toString
u=y.N
t=new A.a3U(v,u)
for(s=1;t.gA(0)===0;){if(s>=3)return d
v=w.querySelectorAll(".quote-toggle-container"+B.d.b0(" > div",s)+" > blockquote")
v.toString
t=new A.a3U(v,u);++s}r=t.$ti.c.a(B.uN.gX(t.a))
q=new DOMParser().parseFromString('      <button class="quote-toggle-button collapsed" title="Show trimmed content">\n          <span class="dot"></span>\n          <span class="dot"></span>\n          <span class="dot"></span>\n      </button>',p).querySelector(".quote-toggle-button")
v=r.parentNode
if(v!=null&&q!=null)v.insertBefore(q,r).toString
v=w.documentElement
v=v==null?null:J.dI0(v)
return v==null?d:v},
aQR(){if(!B.d.t(window.navigator.userAgent.toLowerCase(),"iphone"))var x=B.d.t(window.navigator.userAgent.toLowerCase(),"android")&&B.d.t(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x},
aQS(){if(!B.d.t(window.navigator.userAgent.toLowerCase(),"ipad"))var x=B.d.t(window.navigator.userAgent.toLowerCase(),"android")&&!B.d.t(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[12],C)
D=c[22]
C.ME.prototype={
Y(){return new C.aqu(null)}}
C.aqu.prototype={
aq(){var x,w=this
w.aXt()
x=w.a
w.e=x.e
w.f=x.d
w.y=x.cy
if(!C.aQR()&&!C.aQS()){x=w.a.fy
w.as=new C.aIU(x)}w.as0()
x=window
x.toString
x=A.jn(x,"message",w.gbcg(),!1,y._)
w.z!==$&&A.cQ()
w.z=x},
bch(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{x=B.ay.hh(0,new A.Ro([],[]).NB(d.data,!0))
w=J.ai(x,"view")
t=n.d
t===$&&A.d()
if(!J.t(w,t))return
v=J.ai(x,"type")
if(n.gasF()){t=v
t=(t==null?m:B.d.t(t,"toDart: onScrollChanged"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
n.bbN(x,t)
return}else{if(n.gasF()){t=v
t=(t==null?m:B.d.t(t,"toDart: onScrollEnd"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
s=J.ai(x,"velocity")
r=J.dkh(s==null?0:s,800)
q=t.f
p=B.c.gbl(q).at
p.toString
t.iL(B.j.fo(p+r,B.c.gbl(q).geO(),B.c.gbl(q).gea()),B.fo,B.hG)
return}else{t=v
q=n.a
if(q.Q!=null)t=(t==null?m:B.d.t(t,"toDart: iframeKeydown"))===!0
else t=!1
if(t){n.bcX(x)
return}else{t=v
if(q.fx)t=(t==null?m:B.d.t(t,"toDart: iframeClick"))===!0
else t=!1
if(t){n.bcW(x)
return}else{t=v
if((t==null?m:B.d.t(t,"toDart: iframeLinkHover"))===!0){n.bcY(x)
return}else{t=v
if((t==null?m:B.d.t(t,"toDart: iframeLinkOut"))===!0){n.bcZ(x)
return}}}}}}if(J.t(J.ai(x,"message"),"iframeHasBeenLoaded"))n.Q=!0
if(!n.Q)return
t=v
if((t==null?m:B.d.t(t,"toDart: htmlHeight"))===!0)n.ba_(J.ai(x,"height"))
else{t=v
t=(t==null?m:B.d.t(t,"toDart: htmlWidth"))===!0
if(t)n.a.toString
if(t)n.ba0(J.ai(x,"width"))
else{t=v
if((t==null?m:B.d.t(t,"toDart: OpenLink"))===!0){t=J.ai(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"&&B.d.bj(t,"mailto:")){q=n.a.y
if(q!=null)q.$1(A.jm(t))}}else{t=v
if((t==null?m:B.d.t(t,"toDart: onClickHyperLink"))===!0){t=J.ai(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"){q=n.a.z
if(q!=null)q.$1(A.jm(t))}}}}}}catch(o){u=A.O(o)
A.x(A.E(n).l(0)+"::_handleMessageEvent:Exception = "+A.e(u),B.w)}},
gasF(){var x=this.a.ay
if(x!=null)x=x.f.length!==0===!0
else x=!1
return x},
bbN(d,e){var x,w,v,u,t,s,r,q
try{t=J.ai(d,"deltaY")
x=t==null?0:t
s=e.f
r=B.c.gbl(s).at
r.toString
w=r+x
r=C.aQR()||C.aQS()
if(r){v=J.dkn(w,B.c.gbl(s).geO(),B.c.gbl(s).gea())
e.iL(v,B.af,B.oe)}else if(w<B.c.gbl(s).geO())e.ig(B.c.gbl(s).geO())
else if(w>B.c.gbl(s).gea())e.ig(B.c.gbl(s).gea())
else e.ig(w)}catch(q){u=A.O(q)
A.x(A.E(this).l(0)+"::_handleIframeOnScrollChangedListener:Exception = "+A.e(u),B.w)}},
ba_(d){var x,w,v,u,t,s,r=this
if(d==null){x=r.e
x===$&&A.d()
w=x}else w=d
x=r.c
if(x!=null){v=J.awR(w,r.a.dx)
A.x(A.E(r).l(0)+"::_handleContentHeightEvent: ScrollHeightWithBuffer = "+A.e(v),B.f)
x=r.a.fr
u=J.a5O(v)
t=r.y
if(x){t===$&&A.d()
s=u.pC(v,t)}else{t===$&&A.d()
s=u.ne(v,t)}if(s)r.W(new C.cSB(r,v))}if(r.c!=null&&r.x)r.W(new C.cSC(r))},
ba0(d){var x,w,v=this
if(d==null){x=v.f
x===$&&A.d()
w=x}else w=d
if(v.c!=null&&J.dkg(w,v.a.db)&&v.a.at)v.W(new C.cSD(v,w))},
bcX(d){var x,w,v,u
try{v=J.al(d)
x=new C.Yi(A.aJ(v.j(d,"key")),A.aJ(v.j(d,"code")),J.t(v.j(d,"shift"),!0))
A.x(A.E(this).l(0)+"::_handleOnIFrameKeyboardEvent:\ud83d\udce5 Shortcut pressed: "+A.e(x),B.f)
v=this.a.Q
if(v!=null)v.$1(x)}catch(u){w=A.O(u)
A.x(A.E(this).l(0)+"::_handleOnIFrameKeyboardEvent: Exception = "+A.e(w),B.w)}},
bcW(d){var x,w,v
try{A.x(A.E(this).l(0)+"::_handleOnIFrameClickEvent: "+A.e(d),B.f)
w=this.a.as
if(w!=null)w.$0()}catch(v){x=A.O(v)
A.x(A.E(this).l(0)+"::_handleOnIFrameClickEvent: Exception = "+A.e(x),B.w)}},
bcY(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{A.x(A.E(n).l(0)+"::_handleOnIFrameLinkHoverEvent: "+A.e(d),B.f)
t=J.al(d)
s=t.j(d,"url")
x=s==null?"":s
w=t.j(d,"rect")
if(w!=null){t=J.ai(w,"x")
t=t==null?m:J.uS(t)
if(t==null)t=0
r=J.ai(w,"y")
r=r==null?m:J.uS(r)
if(r==null)r=0
q=J.ai(w,"width")
q=q==null?m:J.uS(q)
if(q==null)q=0
p=J.ai(w,"height")
p=p==null?m:J.uS(p)
if(p==null)p=0
v=new A.a7(t,r,t+q,r+p)
t=n.c
if(t!=null){r=n.as
if(r!=null)r.ajP(0,t,x,v)}}}catch(o){u=A.O(o)
A.x(A.E(n).l(0)+"::_handleOnIFrameLinkHoverEvent: Exception = "+A.e(u),B.w)}},
bcZ(d){var x,w,v
try{A.x(A.E(this).l(0)+"::_handleOnIFrameLinkOutEvent: "+A.e(d),B.f)
w=this.as
if(w!=null)w.fT()}catch(v){x=A.O(v)
A.x(A.E(this).l(0)+"::_handleOnIFrameLinkOutEvent: Exception = "+A.e(x),B.w)}},
b4(d){var x,w,v=this
v.bm(d)
x=d.f
A.x(A.E(v).l(0)+"::didUpdateWidget():Old-Direction: "+x.l(0)+" | Current-Direction: "+v.a.f.l(0),B.f)
w=v.a
if(w.c!==d.c||w.f!==x)v.as0()
x=v.a
w=x.e
if(w!==d.e)v.e=w
x=x.d
if(x!==d.d)v.f=x},
b8x(d){var x,w=$.blN(),v=J.rj(d,y.S)
for(x=0;x<d;++x)v[x]=w.tT(255)
return B.qj.ghF().bH(v)},
as0(){var x,w,v,u=this,t="\n          \n          ",s=u.d=u.b8x(10),r=u.a,q=r.c,p=!r.fr,o=p?'          const resizeObserver = new ResizeObserver((entries) => {\n            var height = document.body.scrollHeight;\n            window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n          });\n        ':"",n=r.y!=null,m=n?'                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':"",l=r.z!=null,k=l?'                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':""
l=l?"                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                ":""
n=n?"                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                ":""
p=p?"resizeObserver.observe(document.body);":""
if(r.ch)q=C.dPN(q)
r=y.s
x=A.c([],r)
if(u.a.ch)x.push("    <style>\n      .quote-toggle-button + blockquote {\n        display: block; /* Default display */\n      }\n      .quote-toggle-button.collapsed + blockquote {\n        display: none;\n      }\n      .quote-toggle-button {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        width: 20px;\n        height: 20px;\n        gap: 2px;\n        background-color: #d7e2f5;\n        padding: 0;\n        margin: 8px 0;\n        border-radius: 50%;\n        transition: background-color 0.2s ease-in-out;\n        border: none;\n        cursor: pointer;\n        -webkit-appearance: none;\n        -moz-appearance: none;\n        appearance: none;\n        -webkit-user-select: none; /* Safari */\n        -moz-user-select: none; /* Firefox */\n        -ms-user-select: none; /* IE 10+ */\n        user-select: none; /* Standard syntax */\n        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */\n      }\n      .quote-toggle-button:hover {\n        background-color: #cdcdcd !important;\n      }\n      .dot {\n        width: 3.75px;\n        height: 3.75px;\n        background-color: #55687d;\n        border-radius: 50%;\n      }\n    </style>")
if(u.a.CW)x.push("    html, body {\n      overflow: hidden;\n      overscroll-behavior: none;\n      scrollbar-width: none; /* Firefox */\n      -ms-overflow-style: none; /* IE/Edge */\n    }\n    ::-webkit-scrollbar {\n        display: none;\n      }\n  ")
w=B.c.iF(x)
s=A.c(["      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n          window.removeEventListener('load', handleOnLoad);\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes(\"toIframe:\")) {\n            var data = JSON.parse(e.data);\n            if (data[\"view\"].includes(\""+s+'")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n\n        '+o+"\n        \n        "+m+"\n        \n        \n        \n        "+k+'\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getWidth"}), "*");\n          \n          '+l+t+n+t+p+"\n        }\n      </script>\n    ","    <script type=\"text/javascript\">\n      document.addEventListener('wheel', function(e) {\n        e.ctrlKey && e.preventDefault();\n      }, {\n        passive: false,\n      });\n      window.addEventListener('keydown', disableZoomControl);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', disableZoomControl);\n      });\n      \n      function disableZoomControl(event) {\n        if (event.metaKey || event.ctrlKey) {\n          switch (event.key) {\n            case '=':\n            case '-':\n              event.preventDefault();\n              break;\n          }\n        }\n      }\n    </script>\n  ","    <script type=\"text/javascript\">\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  ",'      <script type="text/javascript">\n        const displayWidth = '+A.e(u.a.d)+";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          // Remove width and height properties from style string\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          // Extract width and height values with units from style string\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          // Normalize style attribute to ensure proper responsive behavior\n          let style = attrs['style'];\n          \n          if (!style) {\n            attrs['style'] = 'max-width:100%;height:auto;display:inline;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          // Ensure proper style string formatting\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          // Add responsive defaults if missing\n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;';\n          }\n    \n          if (!style.includes('height')) {\n            style += 'height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          // Normalize width/height attributes and remove if necessary\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          // Remove attribute if value is null or undefined\n          if (widthStr === null || widthStr === undefined) {\n            delete attrs['width'];\n          } else if (displayWidth !== undefined) {\n            const widthValue = parseFloat(widthStr);\n            if (!isNaN(widthValue)) {\n              if (widthValue > displayWidth) {\n                delete attrs['width'];\n                delete attrs['height'];\n              }\n            }\n          }\n    \n          // Remove height attribute if value is null or undefined\n          if (heightStr === null || heightStr === undefined) {\n            delete attrs['height'];\n          }\n        }\n    \n        function normalizeImageSize(attrs) {\n          // Apply both style and attribute normalization\n          normalizeWidthHeightAttribute(attrs);\n          normalizeStyleAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          // Process all images on the page\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            // Handle style attribute\n            if (attrs.style !== null && attrs.style !== undefined) {\n              img.setAttribute('style', attrs.style);\n            } else {\n              img.removeAttribute('style');\n            }\n    \n            // Handle width attribute\n            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {\n              img.setAttribute('width', attrs.width);\n            } else {\n              img.removeAttribute('width');\n            }\n    \n            // Handle height attribute\n            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {\n              img.setAttribute('height', attrs.height);\n            } else {\n              img.removeAttribute('height');\n            }\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          // Error-safe wrapper for the normalization function\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        // Run normalization when page loads\n        window.onload = safeApplyImageNormalization;\n      </script>\n    "],r)
if(u.a.ch)s.push("    <script>\n      document.addEventListener('DOMContentLoaded', function() {\n        const buttons = document.querySelectorAll('.quote-toggle-button');\n        buttons.forEach(button => {\n          button.onclick = function() {\n            const blockquote = this.nextElementSibling;\n            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {\n              this.classList.toggle('collapsed');\n              if (this.classList.contains('collapsed')) {\n                this.title = 'Show trimmed content';\n              } else {\n                this.title = 'Hide expanded content';\n              }\n            }\n          };\n        });\n      });\n    </script>")
if(u.a.ay!=null){r=C.aQR()||C.aQS()
p=u.d
s.push(r?'    <script type="text/javascript">\n      let lastY = 0;\n      let lastTime = 0;\n      let velocity = 0;\n    \n      function onTouchStart(e) { \n        lastY = e.touches[0].clientY;\n        lastTime = performance.now();\n        velocity = 0;\n      }\n    \n      function onTouchMove(e) { \n        const now = performance.now();\n        const y = e.touches[0].clientY;\n        const dy = lastY - y;\n        const dt = now - lastTime;\n    \n        if (dt > 0) {\n          velocity = dy / dt; // px per ms\n          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity\n        }\n    \n        lastY = y;\n        lastTime = now;\n    \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+'",\n          type: "toDart: onScrollChanged",\n          deltaY: dy,\n        }), \'*\');\n      }\n    \n      function onTouchEnd(e) { \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+"\",\n          type: \"toDart: onScrollEnd\",\n          velocity: velocity,\n        }), '*');\n      }\n    \n      window.addEventListener('touchstart', onTouchStart, { passive: true });\n      window.addEventListener('touchmove', onTouchMove, { passive: true });\n      window.addEventListener('touchend', onTouchEnd, { passive: true });\n    \n      window.addEventListener('pagehide', () => {\n        window.removeEventListener('touchstart', onTouchStart);\n        window.removeEventListener('touchmove', onTouchMove);\n        window.removeEventListener('touchend', onTouchEnd);\n      });\n    </script>\n\n  ":'    <script type="text/javascript">\n      function onWheel(e) { \n        const deltaY = event.deltaY;\n        window.parent.postMessage(JSON.stringify({\n          "view": "'+p+'",\n          "type": "toDart: onScrollChanged",\n          "deltaY": deltaY\n        }), "*");\n      }\n      \n      window.addEventListener(\'wheel\', onWheel, { passive: true });\n      \n      window.addEventListener(\'pagehide\', (event) => {\n        window.removeEventListener(\'wheel\', onWheel);\n      });\n    </script>\n  ')}if(u.a.Q!=null)s.push("    <script type=\"text/javascript\">\n      window.addEventListener('keydown', handleIframeKeydown);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', handleIframeKeydown);\n      });\n      \n      function handleIframeKeydown(event) {\n        const payload = {\n          view: '"+u.d+"',\n          type: 'toDart: iframeKeydown',\n          key: event.key,\n          code: event.code,\n          shift: event.shiftKey\n        };\n        window.parent.postMessage(JSON.stringify(payload), \"*\");\n      }\n    </script>\n  ")
if(u.a.fx)s.push("    <script type=\"text/javascript\">\n      document.addEventListener('click', function (e) {\n        try {\n          const payload = {\n            view: '"+u.d+"',\n            type: 'toDart: iframeClick',\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        } catch (_) {}\n      });\n    </script>\n  ")
if(!C.aQR()&&!C.aQS()){r=u.d
s.push('    <script type="text/javascript">\n      document.addEventListener("mouseover", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const rect = target.getBoundingClientRect();\n          \n          const payload = {\n            view: \''+r+'\',\n            type: \'toDart: iframeLinkHover\',\n            url: target.href,\n            rect: {\n              x: rect.x,\n              y: rect.y,\n              width: rect.width,\n              height: rect.height\n            }\n          };\n          window.parent.postMessage(JSON.stringify(payload), "*");\n        }\n      });\n    \n      document.addEventListener("mouseout", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const payload = {\n            view: \''+r+"',\n            type: 'toDart: iframeLinkOut'\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        }\n      });\n    </script>\n  ")}v=B.c.iF(s)
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
u.w='      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      <style>\n            @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");\n      font-weight: 400;\n      font-style: normal;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");\n      font-weight: 500;\n      font-style: medium;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");\n      font-weight: 600;\n      font-style: semi-bold;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");\n      font-weight: 700;\n      font-style: bold;\n    }\n    \n    body {\n      font-family: \'Inter\', sans-serif;\n    }\n  \n        \n        '+r+"\n        \n        .tmail-content {\n          min-height: "+A.e(s)+"px;\n          min-width: "+p+"px;\n          overflow: auto;\n          overflow-wrap: break-word;\n          word-break: break-word;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n        \n        pre {\n          white-space: pre-wrap;\n        }\n        \n        table {\n          white-space: normal !important;\n        }\n              \n        @media only screen and (max-width: 600px) {\n          table {\n            width: 100% !important;\n          }\n          \n          a {\n            width: -webkit-fill-available !important;\n          }\n        }\n        \n        "+w+"\n      </style>\n      </head>\n      <body "+o+' style = "overflow-x: hidden; '+n+'";>\n      <div class="tmail-content">'+q+"</div>\n      "+v+"\n      </body>\n      </html> \n    "
u.r=A.bL(!0,y.y)},
u(d){var x=this
x.vY(d)
if(x.a.fr)return x.amP()
else return A.f5(new C.cSE(x))},
amP(){var x,w=this,v=null,u=A.E(w).l(0),t=w.e
t===$&&A.d()
A.x(u+"::_buildHtmlElementView: ActualHeight: "+A.e(t),B.f)
t=A.c([],y.p)
u=w.w
if((u==null?v:B.d.aH(u).length!==0)===!0)t.push(A.WA(new C.cSA(w),w.r,y.y))
if(w.x)t.push(D.a3p)
x=new A.cw(B.ad,v,B.a2,B.G,t,v)
w.a.toString
u=w.f
u===$&&A.d()
return new A.b_(u,v,x,v)},
p(){var x,w=this
w.w=null
x=w.z
x===$&&A.d()
x.ak(0)
if(!C.aQR()&&!C.aQS()){x=w.as
if(x!=null)x.fT()
w.as=null}w.az()},
grB(){return this.a.cx}}
C.avb.prototype={
aq(){this.aJ()
if(this.a.cx)this.uB()},
iE(){var x=this.ew$
if(x!=null){x.aR()
x.i6()
this.ew$=null}this.oR()}}
C.Yi.prototype={
aGF(d,e,f){return this.a.toLowerCase()===e.toLowerCase()&&this.c===f},
zE(d,e){return this.aGF(0,e,!1)},
gB(){return[this.a,this.b,this.c]}}
C.b8w.prototype={}
C.bUm.prototype={}
C.aIU.prototype={
ajP(d,e,f,g){var x,w,v,u,t,s,r,q,p,o,n=this,m={}
if(n.a!=null){n.fT()
A.ac8(new C.bUp(n,e,f,g),y.P)
return}x=A.oW(e,y.u)
if(x==null)return
w=e.gal()
v=g.hp(w instanceof A.a4?A.dm(w.cw(0,null),B.r):B.r)
u=y.w
t=A.L(e,B.t,u).w.a.a
u=A.L(e,B.t,u).w
s=t<400?t-24:400
r=v.d
q=r+28+4>u.a.b
p=q?v.b-28-4:r+4
o=m.a=v.a
if((o+s>t?m.a=t-s-12:o)<12)m.a=12
m=A.mt(new C.bUq(m,n,q,p,s,f),!1,!1,!1)
n.a=m
x.on(0,m)},
fT(){var x=this.a
if(x!=null)x.ey(0)
this.a=null}}
var z=a.updateTypes(["~(vG)","~()"])
C.cSB.prototype={
$0(){var x=this.a
x.e=this.b
x.x=!1},
$S:0}
C.cSC.prototype={
$0(){this.a.x=!1},
$S:0}
C.cSD.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.cSE.prototype={
$2(d,e){var x=this.a,w=x.y
w===$&&A.d()
x.y=Math.min(e.d,w)
return x.amP()},
$S:211}
C.cSA.prototype={
$2(d,e){var x,w,v,u,t=null
if(e.b!=null){x=this.a
w=A.doy(!0,new A.b6(A.e(x.w)+"-"+A.e(x.a.a),y.O),new C.cSz(x),"iframe")
v=x.a.dy
u=x.e
x=x.f
if(v!=null){u===$&&A.d()
x===$&&A.d()
return A.a9(t,w,B.k,t,new A.at(0,1/0,0,v),t,t,u,t,t,t,t,t,x)}else{u===$&&A.d()
x===$&&A.d()
return new A.b_(x,u,w,t)}}else return B.y},
$S:198}
C.cSz.prototype={
$1(d){var x,w
y.v.a(d)
x=this.a
w=x.f
w===$&&A.d()
d.width=B.j.l(w)
w=x.e
w===$&&A.d()
d.height=B.j.l(w)
x=x.w
d.srcdoc=x==null?"":x
x=d.style
x.border="none"
x=d.style
x.overflow="hidden"
x=d.style
x.width="100%"
x=d.style
x.height="100%"},
$S:643}
C.bUp.prototype={
$0(){var x=this,w=x.b
if(w.e!=null)x.a.ajP(0,w,x.c,x.d)},
$S:9}
C.bUq.prototype={
$1(d){var x=this,w=null,v=x.b,u=A.jh(0,A.cW(B.c6,w,B.M,!1,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,v.gDf(),w,w,w,w,w,w,w,w,!1,B.a3),w),t=x.a.a,s=A.c([new A.c0(0,B.Y,B.n.aE(0.15),B.r,20)],y.V)
v=v.b.e
if(v==null)v=D.aWO
return A.dg0(new C.bUo(x.c),new A.cw(B.ad,w,B.a2,B.G,A.c([u,A.mx(w,A.d_(A.cr(B.C,!0,B.ql,A.a9(w,A.ad(x.f,w,1,B.D,w,w,v,w,w,w),B.k,w,new A.at(0,x.e,28,1/0),new A.ba(B.n,w,w,B.ql,s,w,w,B.B),w,w,w,w,B.m3,w,w,w),B.k,w,0,w,w,w,w,w,B.ax)),w,t,x.d,w)],y.p),w),B.hB,B.y_,new A.bE(0,1,y.t),y.i)},
$S:375}
C.bUo.prototype={
$3(d,e,f){var x=this.a?-1:1
return A.ms(A.aYL(f,new A.G(0,x*(1-e)*8)),null,e)},
$S:436};(function aliases(){var x=C.avb.prototype
x.aXt=x.aq})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
x(C.aqu.prototype,"gbcg","bch",0)
w(C.aIU.prototype,"gDf","fT",1)})();(function inheritance(){var x=a.mixinHard,w=a.mixin,v=a.inherit,u=a.inheritMany
v(C.ME,A.ag)
v(C.avb,A.ae)
v(C.aqu,C.avb)
u(A.v1,[C.cSB,C.cSC,C.cSD,C.bUp])
u(A.v2,[C.cSE,C.cSA])
u(A.oH,[C.cSz,C.bUq,C.bUo])
u(A.a5,[C.b8w,C.bUm,C.aIU])
v(C.Yi,C.b8w)
x(C.avb,A.qP)
w(C.b8w,A.j)})()
A.DL(b.typeUniverse,JSON.parse('{"ME":{"ag":[],"i":[]},"aqu":{"ae":["ME"]},"Yi":{"j":[]}}'))
var y=(function rtii(){var x=A.ar
return{v:x("Fn"),V:x("N<c0>"),s:x("N<f>"),p:x("N<i>"),w:x("ni"),_:x("vG"),P:x("b4"),u:x("Gj"),t:x("bE<aq>"),O:x("b6<f>"),N:x("a3U<l9>"),y:x("B"),i:x("aq"),S:x("F")}})();(function constants(){D.aS7=new A.b_(30,30,B.rm,null)
D.aK6=new A.W(B.cj,D.aS7,null)
D.a3p=new A.dD(B.d9,null,null,D.aK6,null)
D.aWO=new A.ah(!0,B.m,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)})()};
((a,b)=>{a[b]=a.current
a.eventLog.push({p:"main.dart.js_8",e:"endPart",h:b})})($__dart_deferred_initializers__,"L6lKOzuO14u0q5O5s1wrT0YAlNc=");