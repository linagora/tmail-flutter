((a,b,c)=>{a[b]=a[b]||{}
a[b][c]=a[b][c]||[]
a[b][c].push({p:"main.dart.js_8",e:"beginPart"})})(self,"$__dart_deferred_initializers__","eventLog")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,C,B={
bVh(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x){return new B.NF(f,x,l,h,g,v,k,q,s,t,d,u,j,i,o,m,n,r,w,e,p)},
NF:function NF(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x){var _=this
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
_.ax=o
_.ay=p
_.ch=q
_.CW=r
_.cx=s
_.cy=t
_.db=u
_.dx=v
_.dy=w
_.a=x},
arS:function arS(d){var _=this
_.f=_.e=_.d=$
_.w=_.r=null
_.x=!0
_.z=_.y=$
_.Q=!1
_.iI$=d
_.c=_.a=null},
cXY:function cXY(d,e){this.a=d
this.b=e},
cXZ:function cXZ(d){this.a=d},
cY_:function cY_(d,e){this.a=d
this.b=e},
cY0:function cY0(d){this.a=d},
cXX:function cXX(d){this.a=d},
cXW:function cXW(d){this.a=d},
awD:function awD(){},
Zv:function Zv(d,e,f){this.a=d
this.b=e
this.c=f},
bbA:function bbA(){},
dXD(d){var x,w,v,u,t,s,r,q,p="text/html"
if(!(C.d.q(d,A.bb("<[a-zA-Z][^>]*>",!0,!1,!1,!1))&&C.d.q(d,A.bb("</[a-zA-Z][^>]*>",!0,!1,!1,!1))))return d
try{new DOMParser().parseFromString(d,p).toString}catch(x){return d}w=new DOMParser().parseFromString('<div class="quote-toggle-container" >'+d+"</div>",p)
v=w.querySelectorAll(".quote-toggle-container > blockquote")
v.toString
u=y.f
t=new A.a5i(v,u)
for(s=1;t.gv(0)===0;){if(s>=3)return d
v=w.querySelectorAll(".quote-toggle-container"+C.d.b4(" > div",s)+" > blockquote")
v.toString
t=new A.a5i(v,u);++s}r=t.$ti.c.a(C.uU.gY(t.a))
q=new DOMParser().parseFromString('      <button class="quote-toggle-button collapsed" title="Show trimmed content">\n          <span class="dot"></span>\n          <span class="dot"></span>\n          <span class="dot"></span>\n      </button>',p).querySelector(".quote-toggle-button")
v=r.parentNode
if(v!=null&&q!=null)v.insertBefore(q,r).toString
v=w.documentElement
v=v==null?null:J.dPL(v)
return v==null?d:v},
dyC(){if(!C.d.q(window.navigator.userAgent.toLowerCase(),"iphone"))var x=C.d.q(window.navigator.userAgent.toLowerCase(),"android")&&C.d.q(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x},
dyD(){if(!C.d.q(window.navigator.userAgent.toLowerCase(),"ipad"))var x=C.d.q(window.navigator.userAgent.toLowerCase(),"android")&&!C.d.q(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x}},D
J=c[1]
A=c[0]
C=c[2]
B=a.updateHolder(c[12],B)
D=c[22]
B.NF.prototype={
a1(){return new B.arS(null)}}
B.arS.prototype={
aA(){var x,w=this
w.b_j()
x=w.a
w.e=x.e
w.f=x.d
w.y=x.cx
w.atX()
x=window
x.toString
x=A.ii(x,"message",w.gbfs(),!1,y.B)
w.z!==$&&A.cO()
w.z=x},
bft(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{x=C.as.fe(0,new A.qZ([],[]).rv(d.data,!0))
w=J.ah(x,"view")
t=n.d
t===$&&A.d()
if(!J.t(w,t))return
v=J.ah(x,"type")
if(n.gauE()){t=v
t=(t==null?m:C.d.q(t,"toDart: onScrollChanged"))===!0}else t=!1
if(t){t=n.a.ax
t.toString
n.bf_(x,t)
return}else{if(n.gauE()){t=v
t=(t==null?m:C.d.q(t,"toDart: onScrollEnd"))===!0}else t=!1
if(t){t=n.a.ax
t.toString
s=J.ah(x,"velocity")
r=J.dqR(s==null?0:s,800)
q=t.f
p=C.c.gbp(q).at
p.toString
t.iP(C.j.fE(p+r,C.c.gbp(q).geU(),C.c.gbp(q).gef()),C.fs,C.hJ)
return}else{t=v
if(n.a.Q!=null)t=(t==null?m:C.d.q(t,"toDart: iframeKeydown"))===!0
else t=!1
if(t){n.bg7(x)
return}}}if(J.t(J.ah(x,"message"),"iframeHasBeenLoaded"))n.Q=!0
if(!n.Q)return
t=v
if((t==null?m:C.d.q(t,"toDart: htmlHeight"))===!0)n.bdb(J.ah(x,"height"))
else{t=v
t=(t==null?m:C.d.q(t,"toDart: htmlWidth"))===!0
if(t)n.a.toString
if(t)n.bdc(J.ah(x,"width"))
else{t=v
if((t==null?m:C.d.q(t,"toDart: OpenLink"))===!0){t=J.ah(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"&&C.d.b5(t,"mailto:")){q=n.a.y
if(q!=null)q.$1(A.jf(t))}}else{t=v
if((t==null?m:C.d.q(t,"toDart: onClickHyperLink"))===!0){t=J.ah(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"){q=n.a.z
if(q!=null)q.$1(A.jf(t))}}}}}}catch(o){u=A.O(o)
A.y(A.J(n).l(0)+"::_handleMessageEvent:Exception = "+A.e(u),C.w)}},
gauE(){var x=this.a.ax
if(x!=null)x=x.f.length!==0===!0
else x=!1
return x},
bf_(d,e){var x,w,v,u,t,s,r,q
try{t=J.ah(d,"deltaY")
x=t==null?0:t
s=e.f
r=C.c.gbp(s).at
r.toString
w=r+x
r=B.dyC()||B.dyD()
if(r){v=J.dqW(w,C.c.gbp(s).geU(),C.c.gbp(s).gef())
e.iP(v,C.ae,C.oh)}else if(w<C.c.gbp(s).geU())e.il(C.c.gbp(s).geU())
else if(w>C.c.gbp(s).gef())e.il(C.c.gbp(s).gef())
else e.il(w)}catch(q){u=A.O(q)
A.y(A.J(this).l(0)+"::_handleIframeOnScrollChangedListener:Exception = "+A.e(u),C.w)}},
bdb(d){var x,w,v,u,t,s,r=this
if(d==null){x=r.e
x===$&&A.d()
w=x}else w=d
x=r.c
if(x!=null){v=J.ayk(w,r.a.db)
A.y(A.J(r).l(0)+"::_handleContentHeightEvent: ScrollHeightWithBuffer = "+A.e(v),C.h)
x=r.a.dy
u=J.axw(v)
t=r.y
if(x){t===$&&A.d()
s=u.q4(v,t)}else{t===$&&A.d()
s=u.ny(v,t)}if(s)r.U(new B.cXY(r,v))}if(r.c!=null&&r.x)r.U(new B.cXZ(r))},
bdc(d){var x,w,v=this
if(d==null){x=v.f
x===$&&A.d()
w=x}else w=d
if(v.c!=null&&J.dqQ(w,v.a.cy)&&v.a.as)v.U(new B.cY_(v,w))},
bg7(d){var x,w,v,u
try{v=J.ao(d)
x=new B.Zv(A.aN(v.j(d,"key")),A.aN(v.j(d,"code")),J.t(v.j(d,"shift"),!0))
A.y(A.J(this).l(0)+"::_handleOnIFrameKeyboardEvent:\ud83d\udce5 Shortcut pressed: "+A.e(x),C.h)
v=this.a.Q
if(v!=null)v.$1(x)}catch(u){w=A.O(u)
A.y(A.J(this).l(0)+"::_handleOnIFrameKeyboardEvent: Exception = "+A.e(w),C.w)}},
ba(d){var x,w,v=this
v.bo(d)
x=d.f
A.y(A.J(v).l(0)+"::didUpdateWidget():Old-Direction: "+x.l(0)+" | Current-Direction: "+v.a.f.l(0),C.h)
w=v.a
if(w.c!==d.c||w.f!==x)v.atX()
x=v.a
w=x.e
if(w!==d.e)v.e=w
x=x.d
if(x!==d.d)v.f=x},
bbE(d){var x,w=$.bp0(),v=J.rI(d,y.D)
for(x=0;x<d;++x)v[x]=w.uH(255)
return C.qp.ghF().bA(v)},
atX(){var x,w,v,u=this,t="\n          \n          ",s=u.d=u.bbE(10),r=u.a,q=r.c,p=!r.dy,o=p?'          const resizeObserver = new ResizeObserver((entries) => {\n            var height = document.body.scrollHeight;\n            window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n          });\n        ':"",n=r.y!=null,m=n?'                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':"",l=r.z!=null,k=l?'                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':""
l=l?"                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                ":""
n=n?"                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                ":""
p=p?"resizeObserver.observe(document.body);":""
if(r.ay)q=B.dXD(q)
r=y.x
x=A.c(["    .tmail-tooltip .tooltiptext {\n      visibility: hidden;\n      max-width: 400px;\n      background-color: black;\n      color: #fff;\n      text-align: center;\n      border-radius: 6px;\n      padding: 5px 8px 5px 8px;\n      white-space: nowrap; \n      overflow: hidden;\n      text-overflow: ellipsis;\n      position: absolute;\n      z-index: 1;\n    }\n    .tmail-tooltip:hover .tooltiptext {\n      visibility: visible;\n    }\n  "],r)
if(u.a.ay)x.push("    <style>\n      .quote-toggle-button + blockquote {\n        display: block; /* Default display */\n      }\n      .quote-toggle-button.collapsed + blockquote {\n        display: none;\n      }\n      .quote-toggle-button {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        width: 20px;\n        height: 20px;\n        gap: 2px;\n        background-color: #d7e2f5;\n        padding: 0;\n        margin: 8px 0;\n        border-radius: 50%;\n        transition: background-color 0.2s ease-in-out;\n        border: none;\n        cursor: pointer;\n        -webkit-appearance: none;\n        -moz-appearance: none;\n        appearance: none;\n        -webkit-user-select: none; /* Safari */\n        -moz-user-select: none; /* Firefox */\n        -ms-user-select: none; /* IE 10+ */\n        user-select: none; /* Standard syntax */\n        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */\n      }\n      .quote-toggle-button:hover {\n        background-color: #cdcdcd !important;\n      }\n      .dot {\n        width: 3.75px;\n        height: 3.75px;\n        background-color: #55687d;\n        border-radius: 50%;\n      }\n    </style>")
if(u.a.ch)x.push("    html, body {\n      overflow: hidden;\n      overscroll-behavior: none;\n      scrollbar-width: none; /* Firefox */\n      -ms-overflow-style: none; /* IE/Edge */\n    }\n    ::-webkit-scrollbar {\n        display: none;\n      }\n  ")
w=C.c.ik(x)
s=A.c(["      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n          window.removeEventListener('load', handleOnLoad);\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes(\"toIframe:\")) {\n            var data = JSON.parse(e.data);\n            if (data[\"view\"].includes(\""+s+'")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n\n        '+o+"\n        \n        "+m+"\n        \n        \n        \n        "+k+'\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getWidth"}), "*");\n          \n          '+l+t+n+t+p+"\n        }\n      </script>\n    ","    <script type=\"text/javascript\">\n      document.addEventListener('wheel', function(e) {\n        e.ctrlKey && e.preventDefault();\n      }, {\n        passive: false,\n      });\n      window.addEventListener('keydown', disableZoomControl);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', disableZoomControl);\n      });\n      \n      function disableZoomControl(event) {\n        if (event.metaKey || event.ctrlKey) {\n          switch (event.key) {\n            case '=':\n            case '-':\n              event.preventDefault();\n              break;\n          }\n        }\n      }\n    </script>\n  ","    <script type=\"text/javascript\">\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  ",'      <script type="text/javascript">\n        const displayWidth = '+A.e(u.a.d)+";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          // Remove width and height properties from style string\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          // Extract width and height values with units from style string\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          // Normalize style attribute to ensure proper responsive behavior\n          let style = attrs['style'];\n          \n          if (!style) {\n            attrs['style'] = 'max-width:100%;height:auto;display:inline;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          // Ensure proper style string formatting\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          // Add responsive defaults if missing\n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;';\n          }\n    \n          if (!style.includes('height')) {\n            style += 'height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          // Normalize width/height attributes and remove if necessary\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          // Remove attribute if value is null or undefined\n          if (widthStr === null || widthStr === undefined) {\n            delete attrs['width'];\n          } else if (displayWidth !== undefined) {\n            const widthValue = parseFloat(widthStr);\n            if (!isNaN(widthValue)) {\n              if (widthValue > displayWidth) {\n                delete attrs['width'];\n                delete attrs['height'];\n              }\n            }\n          }\n    \n          // Remove height attribute if value is null or undefined\n          if (heightStr === null || heightStr === undefined) {\n            delete attrs['height'];\n          }\n        }\n    \n        function normalizeImageSize(attrs) {\n          // Apply both style and attribute normalization\n          normalizeWidthHeightAttribute(attrs);\n          normalizeStyleAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          // Process all images on the page\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            // Handle style attribute\n            if (attrs.style !== null && attrs.style !== undefined) {\n              img.setAttribute('style', attrs.style);\n            } else {\n              img.removeAttribute('style');\n            }\n    \n            // Handle width attribute\n            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {\n              img.setAttribute('width', attrs.width);\n            } else {\n              img.removeAttribute('width');\n            }\n    \n            // Handle height attribute\n            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {\n              img.setAttribute('height', attrs.height);\n            } else {\n              img.removeAttribute('height');\n            }\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          // Error-safe wrapper for the normalization function\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        // Run normalization when page loads\n        window.onload = safeApplyImageNormalization;\n      </script>\n    "],r)
if(u.a.ay)s.push("    <script>\n      document.addEventListener('DOMContentLoaded', function() {\n        const buttons = document.querySelectorAll('.quote-toggle-button');\n        buttons.forEach(button => {\n          button.onclick = function() {\n            const blockquote = this.nextElementSibling;\n            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {\n              this.classList.toggle('collapsed');\n              if (this.classList.contains('collapsed')) {\n                this.title = 'Show trimmed content';\n              } else {\n                this.title = 'Hide expanded content';\n              }\n            }\n          };\n        });\n      });\n    </script>")
if(u.a.ax!=null){r=B.dyC()||B.dyD()
p=u.d
s.push(r?'    <script type="text/javascript">\n      let lastY = 0;\n      let lastTime = 0;\n      let velocity = 0;\n    \n      function onTouchStart(e) { \n        lastY = e.touches[0].clientY;\n        lastTime = performance.now();\n        velocity = 0;\n      }\n    \n      function onTouchMove(e) { \n        const now = performance.now();\n        const y = e.touches[0].clientY;\n        const dy = lastY - y;\n        const dt = now - lastTime;\n    \n        if (dt > 0) {\n          velocity = dy / dt; // px per ms\n          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity\n        }\n    \n        lastY = y;\n        lastTime = now;\n    \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+'",\n          type: "toDart: onScrollChanged",\n          deltaY: dy,\n        }), \'*\');\n      }\n    \n      function onTouchEnd(e) { \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+"\",\n          type: \"toDart: onScrollEnd\",\n          velocity: velocity,\n        }), '*');\n      }\n    \n      window.addEventListener('touchstart', onTouchStart, { passive: true });\n      window.addEventListener('touchmove', onTouchMove, { passive: true });\n      window.addEventListener('touchend', onTouchEnd, { passive: true });\n    \n      window.addEventListener('pagehide', () => {\n        window.removeEventListener('touchstart', onTouchStart);\n        window.removeEventListener('touchmove', onTouchMove);\n        window.removeEventListener('touchend', onTouchEnd);\n      });\n    </script>\n\n  ":'    <script type="text/javascript">\n      function onWheel(e) { \n        const deltaY = event.deltaY;\n        window.parent.postMessage(JSON.stringify({\n          "view": "'+p+'",\n          "type": "toDart: onScrollChanged",\n          "deltaY": deltaY\n        }), "*");\n      }\n      \n      window.addEventListener(\'wheel\', onWheel, { passive: true });\n      \n      window.addEventListener(\'pagehide\', (event) => {\n        window.removeEventListener(\'wheel\', onWheel);\n      });\n    </script>\n  ')}if(u.a.Q!=null)s.push("    <script type=\"text/javascript\">\n      window.addEventListener('keydown', handleIframeKeydown);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', handleIframeKeydown);\n      });\n      \n      function handleIframeKeydown(event) {\n        const payload = {\n          view: '"+u.d+"',\n          type: 'toDart: iframeKeydown',\n          key: event.key,\n          code: event.code,\n          shift: event.shiftKey\n        };\n        window.parent.postMessage(JSON.stringify(payload), \"*\");\n      }\n    </script>\n  ")
v=C.c.ik(s)
s=u.y
s===$&&A.d()
r=u.a
p=r.cy
o=r.f
n=r.r
m=r.w
r=r.x
r=m?"    body {\n      font-weight: 400;\n      font-size: "+r+"px;\n      font-style: normal;\n    }\n    \n    p {\n      margin: 0px;\n    }\n  ":""
o=o===C.aB?'dir="rtl"':""
n=n!=null?"margin: "+A.e(n)+";":""
u.w='      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      <style>\n            @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");\n      font-weight: 400;\n      font-style: normal;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");\n      font-weight: 500;\n      font-style: medium;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");\n      font-weight: 600;\n      font-style: semi-bold;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");\n      font-weight: 700;\n      font-style: bold;\n    }\n    \n    body {\n      font-family: \'Inter\', sans-serif;\n    }\n  \n        \n        '+r+"\n        \n        .tmail-content {\n          min-height: "+A.e(s)+"px;\n          min-width: "+p+"px;\n          overflow: auto;\n          overflow-wrap: break-word;\n          word-break: break-word;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n        \n        pre {\n          white-space: pre-wrap;\n        }\n        \n        table {\n          white-space: normal !important;\n        }\n              \n        @media only screen and (max-width: 600px) {\n          table {\n            width: 100% !important;\n          }\n          \n          a {\n            width: -webkit-fill-available !important;\n          }\n        }\n        \n        "+w+"\n      </style>\n      </head>\n      <body "+o+' style = "overflow-x: hidden; '+n+'";>\n      <div class="tmail-content">'+q+"</div>\n      "+v+"\n      </body>\n      </html> \n    "
u.r=A.bI(!0,y.e)},
t(d){var x=this
x.wG(d)
if(x.a.dy)return x.aoM()
else return A.fc(new B.cY0(x))},
aoM(){var x,w=this,v=null,u=A.J(w).l(0),t=w.e
t===$&&A.d()
A.y(u+"::_buildHtmlElementView: ActualHeight: "+A.e(t),C.h)
t=A.c([],y.u)
u=w.w
if((u==null?v:C.d.aL(u).length!==0)===!0)t.push(A.XO(new B.cXX(w),w.r,y.e))
if(w.x)t.push(D.a3R)
x=new A.cA(C.ac,v,C.a2,C.G,t,v)
w.a.toString
u=w.f
u===$&&A.d()
return new A.b2(u,v,x,v)},
p(){this.w=null
var x=this.z
x===$&&A.d()
x.ap(0)
this.aG()},
gtd(){return this.a.CW}}
B.awD.prototype={
aA(){this.aO()
if(this.a.CW)this.vm()},
iH(){var x=this.iI$
if(x!=null){x.aX()
x.i9()
this.iI$=null}this.pk()}}
B.Zv.prototype={
aIP(d,e,f){return this.a.toLowerCase()===e.toLowerCase()&&this.c===f},
Av(d,e){return this.aIP(0,e,!1)},
gC(){return[this.a,this.b,this.c]}}
B.bbA.prototype={}
var z=a.updateTypes(["~(qw)"])
B.cXY.prototype={
$0(){var x=this.a
x.e=this.b
x.x=!1},
$S:0}
B.cXZ.prototype={
$0(){this.a.x=!1},
$S:0}
B.cY_.prototype={
$0(){return this.a.f=this.b},
$S:0}
B.cY0.prototype={
$2(d,e){var x=this.a,w=x.y
w===$&&A.d()
x.y=Math.min(e.d,w)
return x.aoM()},
$S:210}
B.cXX.prototype={
$2(d,e){var x,w,v,u,t=null
if(e.b!=null){x=this.a
w=A.dv2(!0,new A.b7(A.e(x.w)+"-"+A.e(x.a.a),y.q),new B.cXW(x),"iframe")
v=x.a.dx
u=x.e
x=x.f
if(v!=null){u===$&&A.d()
x===$&&A.d()
return A.aa(t,w,C.k,t,new A.av(0,1/0,0,v),t,t,u,t,t,t,t,t,x)}else{u===$&&A.d()
x===$&&A.d()
return new A.b2(x,u,w,t)}}else return C.y},
$S:217}
B.cXW.prototype={
$1(d){var x,w
y.C.a(d)
x=this.a
w=x.f
w===$&&A.d()
d.width=C.j.l(w)
w=x.e
w===$&&A.d()
d.height=C.j.l(w)
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
$S:652};(function aliases(){var x=B.awD.prototype
x.b_j=x.aA})();(function installTearOffs(){var x=a._instance_1u
x(B.arS.prototype,"gbfs","bft",0)})();(function inheritance(){var x=a.mixinHard,w=a.mixin,v=a.inherit,u=a.inheritMany
v(B.NF,A.ag)
v(B.awD,A.af)
v(B.arS,B.awD)
u(A.vx,[B.cXY,B.cXZ,B.cY_])
u(A.vy,[B.cY0,B.cXX])
v(B.cXW,A.p_)
v(B.bbA,A.a2)
v(B.Zv,B.bbA)
x(B.awD,A.rc)
w(B.bbA,A.p)})()
A.Eo(b.typeUniverse,JSON.parse('{"NF":{"ag":[],"j":[],"k":[]},"arS":{"af":["NF"]},"Zv":{"p":[]}}'))
var y={C:A.aq("yI"),x:A.aq("P<f>"),u:A.aq("P<j>"),B:A.aq("qw"),q:A.aq("b7<f>"),f:A.aq("a5i<ia>"),e:A.aq("C"),D:A.aq("D")};(function constants(){D.aSW=new A.b2(30,30,C.rt,null)
D.aKR=new A.a_(C.cv,D.aSW,null)
D.a3R=new A.dJ(C.db,null,null,D.aKR,null)})()};
((a,b)=>{a[b]=a.current
a.eventLog.push({p:"main.dart.js_8",e:"endPart",h:b})})($__dart_deferred_initializers__,"GFiHUaL9JdpTfdfMVA8FWNwJSIs=");