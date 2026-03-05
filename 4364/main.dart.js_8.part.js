((a,b,c)=>{a[b]=a[b]||{}
a[b][c]=a[b][c]||[]
a[b][c].push({p:"main.dart.js_8",e:"beginPart"})})(self,"$__dart_deferred_initializers__","eventLog")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={
c37(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){return new C.Pn(f,a2,l,h,g,x,k,r,t,v,u,d,w,j,i,p,m,n,s,a1,e,a0,o,q)},
Pn:function Pn(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){var _=this
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
avz:function avz(d){var _=this
_.f=_.e=_.d=$
_.w=_.r=null
_.x=!0
_.z=_.y=$
_.Q=!1
_.as=null
_.ja$=d
_.c=_.a=null},
d9o:function d9o(d,e){this.a=d
this.b=e},
d9p:function d9p(d){this.a=d},
d9q:function d9q(d,e){this.a=d
this.b=e},
d9r:function d9r(d){this.a=d},
d9n:function d9n(d){this.a=d},
d9m:function d9m(d){this.a=d},
aAz:function aAz(){},
a0V:function a0V(d,e,f){this.a=d
this.b=e
this.c=f},
bi7:function bi7(){},
c5X(d){return new C.c5W(d)},
c5W:function c5W(d){this.e=d},
aQ3:function aQ3(d){this.a=null
this.b=d},
c5Z:function c5Z(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
c6_:function c6_(d,e,f,g,h,i){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i},
c5Y:function c5Y(d){this.a=d},
ee1(d){var x,w,v,u,t,s,r,q,p="text/html"
if(!(B.d.q(d,$.dZk())&&B.d.q(d,$.dZj())))return d
try{new DOMParser().parseFromString(d,p).toString}catch(x){return d}w=new DOMParser().parseFromString('<div class="quote-toggle-container" >'+d+"</div>",p)
v=w.querySelectorAll(".quote-toggle-container > blockquote")
v.toString
u=y.N
t=new A.a7X(v,u)
for(s=1;t.gu(0)===0;){if(s>=3)return d
v=w.querySelectorAll(".quote-toggle-container"+B.d.ba(" > div",s)+" > blockquote")
v.toString
t=new A.a7X(v,u);++s}r=t.$ti.c.a(B.vC.gZ(t.a))
q=new DOMParser().parseFromString('      <button class="quote-toggle-button collapsed" title="Show trimmed content">\n          <span class="dot"></span>\n          <span class="dot"></span>\n          <span class="dot"></span>\n      </button>',p).querySelector(".quote-toggle-button")
v=r.parentNode
if(v!=null&&q!=null)v.insertBefore(q,r).toString
v=w.documentElement
v=v==null?null:J.e59(v)
return v==null?d:v}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[12],C)
D=c[22]
C.Pn.prototype={
Y(){return new C.avz(null)}}
C.avz.prototype={
ar(){var x,w=this
w.b3Q()
x=w.a
w.e=x.e
w.f=x.d
w.y=x.cy
if(!A.IO()&&!A.IP()){x=w.a.fy
w.as=new C.aQ3(x)}w.axk()
x=window
x.toString
x=A.jo(x,"message",w.gbld(),!1,y._)
w.z!==$&&A.cv()
w.z=x},
ble(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{x=B.aH.hg(0,new A.Ur([],[]).Qr(d.data,!0))
w=J.ad(x,"view")
t=n.d
t===$&&A.d()
if(!J.v(w,t))return
v=J.ad(x,"type")
if(n.gay1()){t=v
t=(t==null?m:B.d.q(t,"toDart: onScrollChanged"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
n.bkI(x,t)
return}else{if(n.gay1()){t=v
t=(t==null?m:B.d.q(t,"toDart: onScrollEnd"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
s=J.ad(x,"velocity")
r=J.dEL(s==null?0:s,800)
q=t.f
p=B.c.gbt(q).at
p.toString
t.jg(B.i.el(p+r,B.c.gbt(q).gf6(),B.c.gbt(q).geo()),B.fB,B.hV)
return}else{t=v
q=n.a
if(q.Q!=null)t=(t==null?m:B.d.q(t,"toDart: iframeKeydown"))===!0
else t=!1
if(t){n.blU(x)
return}else{t=v
if(q.fx)t=(t==null?m:B.d.q(t,"toDart: iframeClick"))===!0
else t=!1
if(t){n.blT(x)
return}else{t=v
if((t==null?m:B.d.q(t,"toDart: iframeLinkHover"))===!0){n.blV(x)
return}else{t=v
if((t==null?m:B.d.q(t,"toDart: iframeLinkOut"))===!0){n.blW(x)
return}}}}}}if(J.v(J.ad(x,"message"),"iframeHasBeenLoaded"))n.Q=!0
if(!n.Q)return
t=v
if((t==null?m:B.d.q(t,"toDart: htmlHeight"))===!0)n.biU(J.ad(x,"height"))
else{t=v
t=(t==null?m:B.d.q(t,"toDart: htmlWidth"))===!0
if(t)n.a.toString
if(t)n.biV(J.ad(x,"width"))
else{t=v
if((t==null?m:B.d.q(t,"toDart: OpenLink"))===!0){t=J.ad(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"&&B.d.aL(t,"mailto:")){q=n.a.y
if(q!=null)q.$1(A.jn(t))}}else{t=v
if((t==null?m:B.d.q(t,"toDart: onClickHyperLink"))===!0){t=J.ad(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"){q=n.a.z
if(q!=null)q.$1(A.jn(t))}}}}}}catch(o){u=A.N(o)
A.y(A.J(n).l(0)+"::_handleMessageEvent:Exception = "+A.e(u),m,m,B.w,m,!1)}},
gay1(){var x=this.a.ay
if(x!=null)x=x.f.length!==0===!0
else x=!1
return x},
bkI(d,e){var x,w,v,u,t,s,r,q
try{t=J.ad(d,"deltaY")
x=t==null?0:t
s=e.f
r=B.c.gbt(s).at
r.toString
w=r+x
r=A.IO()||A.IP()
if(r){v=J.aan(w,B.c.gbt(s).gf6(),B.c.gbt(s).geo())
e.jg(v,B.ab,B.oU)}else if(w<B.c.gbt(s).gf6())e.iF(B.c.gbt(s).gf6())
else if(w>B.c.gbt(s).geo())e.iF(B.c.gbt(s).geo())
else e.iF(w)}catch(q){u=A.N(q)
A.y(A.J(this).l(0)+"::_handleIframeOnScrollChangedListener:Exception = "+A.e(u),null,null,B.w,null,!1)}},
biU(d){var x,w,v,u,t,s,r=this
if(d==null){x=r.e
x===$&&A.d()
w=x}else w=d
x=r.c
if(x!=null){v=J.aCl(w,r.a.dx)
A.y(A.J(r).l(0)+"::_handleContentHeightEvent: ScrollHeightWithBuffer = "+A.e(v),null,null,B.h,null,!1)
x=r.a.fr
u=J.Lq(v)
t=r.y
if(x){t===$&&A.d()
s=u.p5(v,t)}else{t===$&&A.d()
s=u.mA(v,t)}if(s)r.V(new C.d9o(r,v))}if(r.c!=null&&r.x)r.V(new C.d9p(r))},
biV(d){var x,w,v=this
if(d==null){x=v.f
x===$&&A.d()
w=x}else w=d
if(v.c!=null&&J.dEK(w,v.a.db)&&v.a.at)v.V(new C.d9q(v,w))},
blU(d){var x,w,v,u,t=null
try{v=J.al(d)
x=new C.a0V(A.aM(v.j(d,"key")),A.aM(v.j(d,"code")),J.v(v.j(d,"shift"),!0))
A.y(A.J(this).l(0)+"::_handleOnIFrameKeyboardEvent:\ud83d\udce5 Shortcut pressed: "+A.e(x),t,t,B.h,t,!1)
v=this.a.Q
if(v!=null)v.$1(x)}catch(u){w=A.N(u)
A.y(A.J(this).l(0)+"::_handleOnIFrameKeyboardEvent: Exception = "+A.e(w),t,t,B.w,t,!1)}},
blT(d){var x,w,v,u=null
try{A.y(A.J(this).l(0)+"::_handleOnIFrameClickEvent: "+A.e(d),u,u,B.h,u,!1)
w=this.a.as
if(w!=null)w.$0()}catch(v){x=A.N(v)
A.y(A.J(this).l(0)+"::_handleOnIFrameClickEvent: Exception = "+A.e(x),u,u,B.w,u,!1)}},
blV(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{A.y(A.J(n).l(0)+"::_handleOnIFrameLinkHoverEvent: "+A.e(d),m,m,B.h,m,!1)
t=J.al(d)
s=t.j(d,"url")
x=s==null?"":s
w=t.j(d,"rect")
if(w!=null){t=J.ad(w,"x")
t=t==null?m:J.wd(t)
if(t==null)t=0
r=J.ad(w,"y")
r=r==null?m:J.wd(r)
if(r==null)r=0
q=J.ad(w,"width")
q=q==null?m:J.wd(q)
if(q==null)q=0
p=J.ad(w,"height")
p=p==null?m:J.wd(p)
if(p==null)p=0
v=new A.a8(t,r,t+q,r+p)
t=n.c
if(t!=null){r=n.as
if(r!=null)r.aoF(0,t,x,v)}}}catch(o){u=A.N(o)
A.y(A.J(n).l(0)+"::_handleOnIFrameLinkHoverEvent: Exception = "+A.e(u),m,m,B.w,m,!1)}},
blW(d){var x,w,v,u=null
try{A.y(A.J(this).l(0)+"::_handleOnIFrameLinkOutEvent: "+A.e(d),u,u,B.h,u,!1)
w=this.as
if(w!=null)w.eH()}catch(v){x=A.N(v)
A.y(A.J(this).l(0)+"::_handleOnIFrameLinkOutEvent: Exception = "+A.e(x),u,u,B.w,u,!1)}},
bc(d){var x,w,v=this
v.bp(d)
x=d.f
A.y(A.J(v).l(0)+"::didUpdateWidget():Old-Direction: "+x.l(0)+" | Current-Direction: "+v.a.f.l(0),null,null,B.h,null,!1)
w=v.a
if(w.c!==d.c||w.f!==x)v.axk()
x=v.a
w=x.e
if(w!==d.e)v.e=w
x=x.d
if(x!==d.d)v.f=x},
axk(){var x,w,v,u=this,t="\n          \n          ",s=u.d=A.dJm(10),r=u.a,q=r.c,p=!r.fr,o=p?'          const resizeObserver = new ResizeObserver((entries) => {\n            var height = document.body.scrollHeight;\n            window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n          });\n        ':"",n=r.y!=null,m=n?'                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':"",l=r.z!=null,k=l?'                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':""
l=l?"                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                ":""
n=n?"                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                ":""
p=p?"resizeObserver.observe(document.body);":""
if(r.ch)q=C.ee1(q)
r=y.s
x=A.c([],r)
if(u.a.ch)x.push("    <style>\n      .quote-toggle-button + blockquote {\n        display: block; /* Default display */\n      }\n      .quote-toggle-button.collapsed + blockquote {\n        display: none;\n      }\n      .quote-toggle-button {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        width: 20px;\n        height: 20px;\n        gap: 2px;\n        background-color: #d7e2f5;\n        padding: 0;\n        margin: 8px 0;\n        border-radius: 50%;\n        transition: background-color 0.2s ease-in-out;\n        border: none;\n        cursor: pointer;\n        -webkit-appearance: none;\n        -moz-appearance: none;\n        appearance: none;\n        -webkit-user-select: none; /* Safari */\n        -moz-user-select: none; /* Firefox */\n        -ms-user-select: none; /* IE 10+ */\n        user-select: none; /* Standard syntax */\n        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */\n      }\n      .quote-toggle-button:hover {\n        background-color: #cdcdcd !important;\n      }\n      .dot {\n        width: 3.75px;\n        height: 3.75px;\n        background-color: #55687d;\n        border-radius: 50%;\n      }\n    </style>")
if(u.a.CW)x.push("    html, body {\n      overflow: hidden;\n      overscroll-behavior: none;\n      scrollbar-width: none; /* Firefox */\n      -ms-overflow-style: none; /* IE/Edge */\n    }\n    ::-webkit-scrollbar {\n        display: none;\n      }\n  ")
w=B.c.iE(x)
s=A.c(["      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n          window.removeEventListener('load', handleOnLoad);\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes(\"toIframe:\")) {\n            var data = JSON.parse(e.data);\n            if (data[\"view\"].includes(\""+s+'")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n\n        '+o+"\n        \n        "+m+"\n        \n        \n        \n        "+k+'\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getWidth"}), "*");\n          \n          '+l+t+n+t+p+"\n        }\n      </script>\n    ","    <script type=\"text/javascript\">\n      document.addEventListener('wheel', function(e) {\n        e.ctrlKey && e.preventDefault();\n      }, {\n        passive: false,\n      });\n      window.addEventListener('keydown', disableZoomControl);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', disableZoomControl);\n      });\n      \n      function disableZoomControl(event) {\n        if (event.metaKey || event.ctrlKey) {\n          switch (event.key) {\n            case '=':\n            case '-':\n              event.preventDefault();\n              break;\n          }\n        }\n      }\n    </script>\n  ","    <script type=\"text/javascript\">\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  ",'      <script type="text/javascript">\n        const displayWidth = '+A.e(u.a.d)+";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          // Remove width and height properties from style string\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          // Extract width and height values with units from style string\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          // Normalize style attribute to ensure proper responsive behavior\n          let style = attrs['style'];\n          \n          if (!style) {\n            attrs['style'] = 'max-width:100%;height:auto;display:inline;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          // Ensure proper style string formatting\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          // Add responsive defaults if missing\n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;';\n          }\n    \n          if (!style.includes('height')) {\n            style += 'height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          // Normalize width/height attributes and remove if necessary\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          // Remove attribute if value is null or undefined\n          if (widthStr === null || widthStr === undefined) {\n            delete attrs['width'];\n          } else if (displayWidth !== undefined) {\n            const widthValue = parseFloat(widthStr);\n            if (!isNaN(widthValue)) {\n              if (widthValue > displayWidth) {\n                delete attrs['width'];\n                delete attrs['height'];\n              }\n            }\n          }\n    \n          // Remove height attribute if value is null or undefined\n          if (heightStr === null || heightStr === undefined) {\n            delete attrs['height'];\n          }\n        }\n    \n        function normalizeImageSize(attrs) {\n          // Apply both style and attribute normalization\n          normalizeWidthHeightAttribute(attrs);\n          normalizeStyleAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          // Process all images on the page\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            // Handle style attribute\n            if (attrs.style !== null && attrs.style !== undefined) {\n              img.setAttribute('style', attrs.style);\n            } else {\n              img.removeAttribute('style');\n            }\n    \n            // Handle width attribute\n            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {\n              img.setAttribute('width', attrs.width);\n            } else {\n              img.removeAttribute('width');\n            }\n    \n            // Handle height attribute\n            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {\n              img.setAttribute('height', attrs.height);\n            } else {\n              img.removeAttribute('height');\n            }\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          // Error-safe wrapper for the normalization function\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        // Run normalization when page loads\n        window.onload = safeApplyImageNormalization;\n      </script>\n    "],r)
if(u.a.ch)s.push("    <script>\n      document.addEventListener('DOMContentLoaded', function() {\n        const buttons = document.querySelectorAll('.quote-toggle-button');\n        buttons.forEach(button => {\n          button.onclick = function() {\n            const blockquote = this.nextElementSibling;\n            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {\n              this.classList.toggle('collapsed');\n              if (this.classList.contains('collapsed')) {\n                this.title = 'Show trimmed content';\n              } else {\n                this.title = 'Hide expanded content';\n              }\n            }\n          };\n        });\n      });\n    </script>")
if(u.a.ay!=null){r=A.IO()||A.IP()
p=u.d
s.push(r?'    <script type="text/javascript">\n      let lastY = 0;\n      let lastTime = 0;\n      let velocity = 0;\n    \n      function onTouchStart(e) { \n        lastY = e.touches[0].clientY;\n        lastTime = performance.now();\n        velocity = 0;\n      }\n    \n      function onTouchMove(e) { \n        const now = performance.now();\n        const y = e.touches[0].clientY;\n        const dy = lastY - y;\n        const dt = now - lastTime;\n    \n        if (dt > 0) {\n          velocity = dy / dt; // px per ms\n          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity\n        }\n    \n        lastY = y;\n        lastTime = now;\n    \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+'",\n          type: "toDart: onScrollChanged",\n          deltaY: dy,\n        }), \'*\');\n      }\n    \n      function onTouchEnd(e) { \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+"\",\n          type: \"toDart: onScrollEnd\",\n          velocity: velocity,\n        }), '*');\n      }\n    \n      window.addEventListener('touchstart', onTouchStart, { passive: true });\n      window.addEventListener('touchmove', onTouchMove, { passive: true });\n      window.addEventListener('touchend', onTouchEnd, { passive: true });\n    \n      window.addEventListener('pagehide', () => {\n        window.removeEventListener('touchstart', onTouchStart);\n        window.removeEventListener('touchmove', onTouchMove);\n        window.removeEventListener('touchend', onTouchEnd);\n      });\n    </script>\n\n  ":'    <script type="text/javascript">\n      function onWheel(e) { \n        const deltaY = event.deltaY;\n        window.parent.postMessage(JSON.stringify({\n          "view": "'+p+'",\n          "type": "toDart: onScrollChanged",\n          "deltaY": deltaY\n        }), "*");\n      }\n      \n      window.addEventListener(\'wheel\', onWheel, { passive: true });\n      \n      window.addEventListener(\'pagehide\', (event) => {\n        window.removeEventListener(\'wheel\', onWheel);\n      });\n    </script>\n  ')}if(u.a.Q!=null)s.push("    <script type=\"text/javascript\">\n      window.addEventListener('keydown', handleIframeKeydown);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', handleIframeKeydown);\n      });\n      \n      function handleIframeKeydown(event) {\n        const payload = {\n          view: '"+u.d+"',\n          type: 'toDart: iframeKeydown',\n          key: event.key,\n          code: event.code,\n          shift: event.shiftKey\n        };\n        window.parent.postMessage(JSON.stringify(payload), \"*\");\n      }\n    </script>\n  ")
if(u.a.fx)s.push("    <script type=\"text/javascript\">\n      document.addEventListener('click', function (e) {\n        try {\n          const payload = {\n            view: '"+u.d+"',\n            type: 'toDart: iframeClick',\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        } catch (_) {}\n      });\n    </script>\n  ")
if(!A.IO()&&!A.IP()){r=u.d
s.push('    <script type="text/javascript">\n      document.addEventListener("mouseover", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const rect = target.getBoundingClientRect();\n          \n          const payload = {\n            view: \''+r+'\',\n            type: \'toDart: iframeLinkHover\',\n            url: target.href,\n            rect: {\n              x: rect.x,\n              y: rect.y,\n              width: rect.width,\n              height: rect.height\n            }\n          };\n          window.parent.postMessage(JSON.stringify(payload), "*");\n        }\n      });\n    \n      document.addEventListener("mouseout", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const payload = {\n            view: \''+r+"',\n            type: 'toDart: iframeLinkOut'\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        }\n      });\n    </script>\n  ")}v=B.c.iE(s)
s=u.y
s===$&&A.d()
r=u.a
p=r.db
o=r.f
n=r.r
m=r.w
r=r.x
r=m?"    body {\n      font-weight: 400;\n      font-size: "+r+"px;\n      font-style: normal;\n    }\n    \n    p {\n      margin: 0px;\n    }\n  ":""
o=o===B.aJ?'dir="rtl"':""
n=n!=null?"margin: "+A.e(n)+";":""
u.w='      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      <style>\n            @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");\n      font-weight: 400;\n      font-style: normal;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");\n      font-weight: 500;\n      font-style: medium;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");\n      font-weight: 600;\n      font-style: semi-bold;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");\n      font-weight: 700;\n      font-style: bold;\n    }\n    \n    body {\n      font-family: \'Inter\', sans-serif;\n    }\n  \n        \n        '+r+"\n        \n        .tmail-content {\n          min-height: "+A.e(s)+"px;\n          min-width: "+p+"px;\n          overflow: auto;\n          overflow-wrap: break-word;\n          word-break: break-word;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n        \n        pre {\n          white-space: pre-wrap;\n        }\n        \n        table {\n          white-space: normal !important;\n        }\n              \n        @media only screen and (max-width: 600px) {\n          table {\n            width: 100% !important;\n          }\n          \n          a {\n            width: -webkit-fill-available !important;\n          }\n        }\n        \n        table, td, th {\n          word-break: normal !important;\n        }\n        \n        "+w+"\n      </style>\n      </head>\n      <body "+o+' style = "overflow-x: hidden; '+n+'";>\n      <div class="tmail-content">'+q+"</div>\n      "+v+"\n      </body>\n      </html> \n    "
u.r=A.bD(!0,y.y)},
t(d){var x=this
x.xI(d)
if(x.a.fr)return x.arU()
else return A.eR(new C.d9r(x))},
arU(){var x,w=this,v=null,u=A.J(w).l(0),t=w.e
t===$&&A.d()
A.y(u+"::_buildHtmlElementView: ActualHeight: "+A.e(t),v,v,B.h,v,!1)
t=A.c([],y.p)
u=w.w
if((u==null?v:B.d.ag(u).length!==0)===!0)t.push(A.OR(new C.d9n(w),w.r,y.y))
if(w.x)t.push(D.a6e)
x=new A.cu(B.a5,v,B.a0,B.F,t,v)
w.a.toString
u=w.f
u===$&&A.d()
return new A.b2(u,v,x,v)},
p(){var x,w=this
w.w=null
x=w.z
x===$&&A.d()
x.al(0)
if(!A.IO()&&!A.IP()){x=w.as
if(x!=null)x.eH()
w.as=null}w.aG()},
gu4(){return this.a.cx}}
C.aAz.prototype={
ar(){this.aP()
if(this.a.cx)this.w7()},
j8(){var x=this.ja$
if(x!=null){x.b3()
x.it()
this.ja$=null}this.pY()}}
C.a0V.prototype={
aMD(d,e,f){return this.a.toLowerCase()===e.toLowerCase()&&this.c===f},
BH(d,e){return this.aMD(0,e,!1)},
gA(){return[this.a,this.b,this.c]}}
C.bi7.prototype={}
C.c5W.prototype={}
C.aQ3.prototype={
aoF(d,e,f,g){var x,w,v,u,t,s,r,q,p,o,n=this,m={}
if(n.a!=null){n.eH()
A.agt(new C.c5Z(n,e,f,g),y.P)
return}x=A.q1(e,y.u)
if(x==null)return
w=e.gak()
v=g.hl(w instanceof A.a7?A.dh(w.cs(0,null),B.q):B.q)
u=y.w
t=A.P(e,B.v,u).w.a.a
u=A.P(e,B.v,u).w
s=t<400?t-24:400
r=v.d
q=r+28+4>u.a.b
p=q?v.b-28-4:r+4
o=m.a=v.a
if((o+s>t?m.a=t-s-12:o)<12)m.a=12
m=A.lZ(new C.c6_(m,n,q,p,s,f),!1,!1,!1)
n.a=m
x.nX(0,m)},
eH(){var x=this.a
if(x!=null)x.ee(0)
this.a=null}}
var z=a.updateTypes(["~(x_)","~()"])
C.d9o.prototype={
$0(){var x=this.a
x.e=this.b
x.x=!1},
$S:0}
C.d9p.prototype={
$0(){this.a.x=!1},
$S:0}
C.d9q.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.d9r.prototype={
$2(d,e){var x=this.a,w=x.y
w===$&&A.d()
x.y=Math.min(e.d,w)
return x.arU()},
$S:99}
C.d9n.prototype={
$2(d,e){var x,w,v,u,t=null
if(e.b!=null){x=this.a
w=A.dJi(!0,new A.b6(A.e(x.w)+"-"+A.e(x.a.a),y.O),new C.d9m(x),"iframe")
v=x.a.dy
u=x.e
x=x.f
if(v!=null){u===$&&A.d()
x===$&&A.d()
return A.a9(t,w,B.k,t,new A.at(0,1/0,0,v),t,t,u,t,t,t,t,t,x)}else{u===$&&A.d()
x===$&&A.d()
return new A.b2(x,u,w,t)}}else return B.x},
$S:211}
C.d9m.prototype={
$1(d){var x,w
y.v.a(d)
x=this.a
w=x.f
w===$&&A.d()
d.width=B.i.l(w)
w=x.e
w===$&&A.d()
d.height=B.i.l(w)
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
$S:785}
C.c5Z.prototype={
$0(){var x=this,w=x.b
if(w.e!=null)x.a.aoF(0,w,x.c,x.d)},
$S:8}
C.c6_.prototype={
$1(d){var x=this,w=null,v=x.b,u=A.jh(0,A.cR(B.bT,w,B.M,!1,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,v.grA(),w,w,w,w,w,w,w,w,!1,B.a2),w),t=x.a.a,s=A.c([new A.c5(0,B.T,B.n.au(0.15),B.q,20)],y.V)
v=v.b.e
if(v==null)v=D.b0w
return A.dzS(new C.c5Y(x.c),new A.cu(B.a5,w,B.a0,B.F,A.c([u,A.ki(w,A.cU(A.cg(B.C,!0,B.lO,A.a9(w,A.aj(x.f,w,1,B.A,w,w,v,w,w,w),B.k,w,new A.at(0,x.e,28,1/0),new A.b8(B.n,w,w,B.lO,s,w,w,B.B),w,w,w,w,B.mu,w,w,w),B.k,w,0,w,w,w,w,w,B.ay)),w,t,x.d,w)],y.p),w),B.hR,B.yX,new A.bL(0,1,y.t),y.i)},
$S:388}
C.c5Y.prototype={
$3(d,e,f){var x=this.a?-1:1
return A.nk(A.b6S(f,new A.G(0,x*(1-e)*8)),null,e)},
$S:385};(function aliases(){var x=C.aAz.prototype
x.b3Q=x.ar})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
x(C.avz.prototype,"gbld","ble",0)
w(C.aQ3.prototype,"grA","eH",1)})();(function inheritance(){var x=a.mixinHard,w=a.mixin,v=a.inherit,u=a.inheritMany
v(C.Pn,A.ai)
v(C.aAz,A.af)
v(C.avz,C.aAz)
u(A.wp,[C.d9o,C.d9p,C.d9q,C.c5Z])
u(A.wq,[C.d9r,C.d9n])
u(A.pG,[C.d9m,C.c6_,C.c5Y])
u(A.a3,[C.bi7,C.c5W,C.aQ3])
v(C.a0V,C.bi7)
x(C.aAz,A.rY)
w(C.bi7,A.j)})()
A.FC(b.typeUniverse,JSON.parse('{"Pn":{"ai":[],"k":[],"p":[]},"avz":{"af":["Pn"]},"a0V":{"j":[]}}'))
var y=(function rtii(){var x=A.aq
return{v:x("Hr"),V:x("O<c5>"),s:x("O<h>"),p:x("O<k>"),w:x("oa"),_:x("x_"),P:x("b1"),u:x("Iy"),t:x("bL<ar>"),O:x("b6<h>"),N:x("a7X<iu>"),y:x("B"),i:x("ar")}})();(function constants(){D.aWQ=new A.b2(30,30,B.t5,null)
D.aOB=new A.a1(B.cs,D.aWQ,null)
D.a6e=new A.e0(B.d2,null,null,D.aOB,null)
D.b0w=new A.ao(!0,B.m,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)})();(function lazyInitializers(){var x=a.lazyFinal
x($,"f4w","dZk",()=>A.b5("<[a-zA-Z][^>\\s]*[^>]*>",!0,!1,!1,!1))
x($,"f4v","dZj",()=>A.b5("</[a-zA-Z][^>]{0,128}>",!0,!1,!1,!1))})()};
((a,b)=>{a[b]=a.current
a.eventLog.push({p:"main.dart.js_8",e:"endPart",h:b})})($__dart_deferred_initializers__,"HiRrjFCEMRpO6nRv4P1Ccd4+Us4=");