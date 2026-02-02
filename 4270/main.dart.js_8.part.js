((a,b,c)=>{a[b]=a[b]||{}
a[b][c]=a[b][c]||[]
a[b][c].push({p:"main.dart.js_8",e:"beginPart"})})(self,"$__dart_deferred_initializers__","eventLog")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={
c0b(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){return new C.Os(f,a2,l,h,g,x,k,r,t,v,u,d,w,j,i,p,m,n,s,a1,e,a0,o,q)},
Os:function Os(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,a0,a1,a2){var _=this
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
auh:function auh(d){var _=this
_.f=_.e=_.d=$
_.w=_.r=null
_.x=!0
_.z=_.y=$
_.Q=!1
_.as=null
_.iP$=d
_.c=_.a=null},
d5K:function d5K(d,e){this.a=d
this.b=e},
d5L:function d5L(d){this.a=d},
d5M:function d5M(d,e){this.a=d
this.b=e},
d5N:function d5N(d){this.a=d},
d5J:function d5J(d){this.a=d},
d5I:function d5I(d){this.a=d},
azd:function azd(){},
a03:function a03(d,e,f){this.a=d
this.b=e
this.c=f},
bfK:function bfK(){},
c30(d){return new C.c3_(d)},
c3_:function c3_(d){this.e=d},
aOi:function aOi(d){this.a=null
this.b=d},
c32:function c32(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
c33:function c33(d,e,f,g,h,i){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i},
c31:function c31(d){this.a=d},
e89(d){var x,w,v,u,t,s,r,q,p="text/html"
if(!(B.d.q(d,$.dUf())&&B.d.q(d,$.dUe())))return d
try{new DOMParser().parseFromString(d,p).toString}catch(x){return d}w=new DOMParser().parseFromString('<div class="quote-toggle-container" >'+d+"</div>",p)
v=w.querySelectorAll(".quote-toggle-container > blockquote")
v.toString
u=y.N
t=new A.a70(v,u)
for(s=1;t.gA(0)===0;){if(s>=3)return d
v=w.querySelectorAll(".quote-toggle-container"+B.d.b8(" > div",s)+" > blockquote")
v.toString
t=new A.a70(v,u);++s}r=t.$ti.c.a(B.vm.gZ(t.a))
q=new DOMParser().parseFromString('      <button class="quote-toggle-button collapsed" title="Show trimmed content">\n          <span class="dot"></span>\n          <span class="dot"></span>\n          <span class="dot"></span>\n      </button>',p).querySelector(".quote-toggle-button")
v=r.parentNode
if(v!=null&&q!=null)v.insertBefore(q,r).toString
v=w.documentElement
v=v==null?null:J.e_C(v)
return v==null?d:v}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[12],C)
D=c[22]
C.Os.prototype={
X(){return new C.auh(null)}}
C.auh.prototype={
ar(){var x,w=this
w.b19()
x=w.a
w.e=x.e
w.f=x.d
w.y=x.cy
if(!A.QC()&&!A.QD()){x=w.a.fy
w.as=new C.aOi(x)}w.avg()
x=window
x.toString
x=A.jc(x,"message",w.gbi_(),!1,y._)
w.z!==$&&A.cJ()
w.z=x},
bi0(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{x=B.aE.h3(0,new A.TB([],[]).Pd(d.data,!0))
w=J.ad(x,"view")
t=n.d
t===$&&A.d()
if(!J.u(w,t))return
v=J.ad(x,"type")
if(n.gavY()){t=v
t=(t==null?m:B.d.q(t,"toDart: onScrollChanged"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
n.bhu(x,t)
return}else{if(n.gavY()){t=v
t=(t==null?m:B.d.q(t,"toDart: onScrollEnd"))===!0}else t=!1
if(t){t=n.a.ay
t.toString
s=J.ad(x,"velocity")
r=J.dAw(s==null?0:s,800)
q=t.f
p=B.c.gbs(q).at
p.toString
t.iW(B.j.eZ(p+r,B.c.gbs(q).geX(),B.c.gbs(q).gek()),B.fw,B.hQ)
return}else{t=v
q=n.a
if(q.Q!=null)t=(t==null?m:B.d.q(t,"toDart: iframeKeydown"))===!0
else t=!1
if(t){n.biH(x)
return}else{t=v
if(q.fx)t=(t==null?m:B.d.q(t,"toDart: iframeClick"))===!0
else t=!1
if(t){n.biG(x)
return}else{t=v
if((t==null?m:B.d.q(t,"toDart: iframeLinkHover"))===!0){n.biI(x)
return}else{t=v
if((t==null?m:B.d.q(t,"toDart: iframeLinkOut"))===!0){n.biJ(x)
return}}}}}}if(J.u(J.ad(x,"message"),"iframeHasBeenLoaded"))n.Q=!0
if(!n.Q)return
t=v
if((t==null?m:B.d.q(t,"toDart: htmlHeight"))===!0)n.bfG(J.ad(x,"height"))
else{t=v
t=(t==null?m:B.d.q(t,"toDart: htmlWidth"))===!0
if(t)n.a.toString
if(t)n.bfH(J.ad(x,"width"))
else{t=v
if((t==null?m:B.d.q(t,"toDart: OpenLink"))===!0){t=J.ad(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"&&B.d.aK(t,"mailto:")){q=n.a.y
if(q!=null)q.$1(A.jb(t))}}else{t=v
if((t==null?m:B.d.q(t,"toDart: onClickHyperLink"))===!0){t=J.ad(x,"url")
if(t!=null&&n.c!=null&&typeof t=="string"){q=n.a.z
if(q!=null)q.$1(A.jb(t))}}}}}}catch(o){u=A.N(o)
A.y(A.I(n).l(0)+"::_handleMessageEvent:Exception = "+A.e(u),m,m,B.w,m,!1)}},
gavY(){var x=this.a.ay
if(x!=null)x=x.f.length!==0===!0
else x=!1
return x},
bhu(d,e){var x,w,v,u,t,s,r,q
try{t=J.ad(d,"deltaY")
x=t==null?0:t
s=e.f
r=B.c.gbs(s).at
r.toString
w=r+x
r=A.QC()||A.QD()
if(r){v=J.a9o(w,B.c.gbs(s).geX(),B.c.gbs(s).gek())
e.iW(v,B.af,B.oJ)}else if(w<B.c.gbs(s).geX())e.iq(B.c.gbs(s).geX())
else if(w>B.c.gbs(s).gek())e.iq(B.c.gbs(s).gek())
else e.iq(w)}catch(q){u=A.N(q)
A.y(A.I(this).l(0)+"::_handleIframeOnScrollChangedListener:Exception = "+A.e(u),null,null,B.w,null,!1)}},
bfG(d){var x,w,v,u,t,s,r=this
if(d==null){x=r.e
x===$&&A.d()
w=x}else w=d
x=r.c
if(x!=null){v=J.aAX(w,r.a.dx)
A.y(A.I(r).l(0)+"::_handleContentHeightEvent: ScrollHeightWithBuffer = "+A.e(v),null,null,B.f,null,!1)
x=r.a.fr
u=J.a8Y(v)
t=r.y
if(x){t===$&&A.d()
s=u.qc(v,t)}else{t===$&&A.d()
s=u.nJ(v,t)}if(s)r.U(new C.d5K(r,v))}if(r.c!=null&&r.x)r.U(new C.d5L(r))},
bfH(d){var x,w,v=this
if(d==null){x=v.f
x===$&&A.d()
w=x}else w=d
if(v.c!=null&&J.dAv(w,v.a.db)&&v.a.at)v.U(new C.d5M(v,w))},
biH(d){var x,w,v,u,t=null
try{v=J.an(d)
x=new C.a03(A.aM(v.j(d,"key")),A.aM(v.j(d,"code")),J.u(v.j(d,"shift"),!0))
A.y(A.I(this).l(0)+"::_handleOnIFrameKeyboardEvent:\ud83d\udce5 Shortcut pressed: "+A.e(x),t,t,B.f,t,!1)
v=this.a.Q
if(v!=null)v.$1(x)}catch(u){w=A.N(u)
A.y(A.I(this).l(0)+"::_handleOnIFrameKeyboardEvent: Exception = "+A.e(w),t,t,B.w,t,!1)}},
biG(d){var x,w,v,u=null
try{A.y(A.I(this).l(0)+"::_handleOnIFrameClickEvent: "+A.e(d),u,u,B.f,u,!1)
w=this.a.as
if(w!=null)w.$0()}catch(v){x=A.N(v)
A.y(A.I(this).l(0)+"::_handleOnIFrameClickEvent: Exception = "+A.e(x),u,u,B.w,u,!1)}},
biI(d){var x,w,v,u,t,s,r,q,p,o,n=this,m=null
try{A.y(A.I(n).l(0)+"::_handleOnIFrameLinkHoverEvent: "+A.e(d),m,m,B.f,m,!1)
t=J.an(d)
s=t.j(d,"url")
x=s==null?"":s
w=t.j(d,"rect")
if(w!=null){t=J.ad(w,"x")
t=t==null?m:J.vI(t)
if(t==null)t=0
r=J.ad(w,"y")
r=r==null?m:J.vI(r)
if(r==null)r=0
q=J.ad(w,"width")
q=q==null?m:J.vI(q)
if(q==null)q=0
p=J.ad(w,"height")
p=p==null?m:J.vI(p)
if(p==null)p=0
v=new A.aa(t,r,t+q,r+p)
t=n.c
if(t!=null){r=n.as
if(r!=null)r.amU(0,t,x,v)}}}catch(o){u=A.N(o)
A.y(A.I(n).l(0)+"::_handleOnIFrameLinkHoverEvent: Exception = "+A.e(u),m,m,B.w,m,!1)}},
biJ(d){var x,w,v,u=null
try{A.y(A.I(this).l(0)+"::_handleOnIFrameLinkOutEvent: "+A.e(d),u,u,B.f,u,!1)
w=this.as
if(w!=null)w.eB()}catch(v){x=A.N(v)
A.y(A.I(this).l(0)+"::_handleOnIFrameLinkOutEvent: Exception = "+A.e(x),u,u,B.w,u,!1)}},
bc(d){var x,w,v=this
v.bp(d)
x=d.f
A.y(A.I(v).l(0)+"::didUpdateWidget():Old-Direction: "+x.l(0)+" | Current-Direction: "+v.a.f.l(0),null,null,B.f,null,!1)
w=v.a
if(w.c!==d.c||w.f!==x)v.avg()
x=v.a
w=x.e
if(w!==d.e)v.e=w
x=x.d
if(x!==d.d)v.f=x},
avg(){var x,w,v,u=this,t="\n          \n          ",s=u.d=A.dEZ(10),r=u.a,q=r.c,p=!r.fr,o=p?'          const resizeObserver = new ResizeObserver((entries) => {\n            var height = document.body.scrollHeight;\n            window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n          });\n        ':"",n=r.y!=null,m=n?'                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':"",l=r.z!=null,k=l?'                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':""
l=l?"                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                ":""
n=n?"                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                ":""
p=p?"resizeObserver.observe(document.body);":""
if(r.ch)q=C.e89(q)
r=y.s
x=A.c([],r)
if(u.a.ch)x.push("    <style>\n      .quote-toggle-button + blockquote {\n        display: block; /* Default display */\n      }\n      .quote-toggle-button.collapsed + blockquote {\n        display: none;\n      }\n      .quote-toggle-button {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        width: 20px;\n        height: 20px;\n        gap: 2px;\n        background-color: #d7e2f5;\n        padding: 0;\n        margin: 8px 0;\n        border-radius: 50%;\n        transition: background-color 0.2s ease-in-out;\n        border: none;\n        cursor: pointer;\n        -webkit-appearance: none;\n        -moz-appearance: none;\n        appearance: none;\n        -webkit-user-select: none; /* Safari */\n        -moz-user-select: none; /* Firefox */\n        -ms-user-select: none; /* IE 10+ */\n        user-select: none; /* Standard syntax */\n        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */\n      }\n      .quote-toggle-button:hover {\n        background-color: #cdcdcd !important;\n      }\n      .dot {\n        width: 3.75px;\n        height: 3.75px;\n        background-color: #55687d;\n        border-radius: 50%;\n      }\n    </style>")
if(u.a.CW)x.push("    html, body {\n      overflow: hidden;\n      overscroll-behavior: none;\n      scrollbar-width: none; /* Firefox */\n      -ms-overflow-style: none; /* IE/Edge */\n    }\n    ::-webkit-scrollbar {\n        display: none;\n      }\n  ")
w=B.c.ip(x)
s=A.c(["      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n          window.removeEventListener('load', handleOnLoad);\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes(\"toIframe:\")) {\n            var data = JSON.parse(e.data);\n            if (data[\"view\"].includes(\""+s+'")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n\n        '+o+"\n        \n        "+m+"\n        \n        \n        \n        "+k+'\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getWidth"}), "*");\n          \n          '+l+t+n+t+p+"\n        }\n      </script>\n    ","    <script type=\"text/javascript\">\n      document.addEventListener('wheel', function(e) {\n        e.ctrlKey && e.preventDefault();\n      }, {\n        passive: false,\n      });\n      window.addEventListener('keydown', disableZoomControl);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', disableZoomControl);\n      });\n      \n      function disableZoomControl(event) {\n        if (event.metaKey || event.ctrlKey) {\n          switch (event.key) {\n            case '=':\n            case '-':\n              event.preventDefault();\n              break;\n          }\n        }\n      }\n    </script>\n  ","    <script type=\"text/javascript\">\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  ",'      <script type="text/javascript">\n        const displayWidth = '+A.e(u.a.d)+";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          // Remove width and height properties from style string\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          // Extract width and height values with units from style string\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          // Normalize style attribute to ensure proper responsive behavior\n          let style = attrs['style'];\n          \n          if (!style) {\n            attrs['style'] = 'max-width:100%;height:auto;display:inline;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          // Ensure proper style string formatting\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          // Add responsive defaults if missing\n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;';\n          }\n    \n          if (!style.includes('height')) {\n            style += 'height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          // Normalize width/height attributes and remove if necessary\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          // Remove attribute if value is null or undefined\n          if (widthStr === null || widthStr === undefined) {\n            delete attrs['width'];\n          } else if (displayWidth !== undefined) {\n            const widthValue = parseFloat(widthStr);\n            if (!isNaN(widthValue)) {\n              if (widthValue > displayWidth) {\n                delete attrs['width'];\n                delete attrs['height'];\n              }\n            }\n          }\n    \n          // Remove height attribute if value is null or undefined\n          if (heightStr === null || heightStr === undefined) {\n            delete attrs['height'];\n          }\n        }\n    \n        function normalizeImageSize(attrs) {\n          // Apply both style and attribute normalization\n          normalizeWidthHeightAttribute(attrs);\n          normalizeStyleAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          // Process all images on the page\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            // Handle style attribute\n            if (attrs.style !== null && attrs.style !== undefined) {\n              img.setAttribute('style', attrs.style);\n            } else {\n              img.removeAttribute('style');\n            }\n    \n            // Handle width attribute\n            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {\n              img.setAttribute('width', attrs.width);\n            } else {\n              img.removeAttribute('width');\n            }\n    \n            // Handle height attribute\n            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {\n              img.setAttribute('height', attrs.height);\n            } else {\n              img.removeAttribute('height');\n            }\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          // Error-safe wrapper for the normalization function\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        // Run normalization when page loads\n        window.onload = safeApplyImageNormalization;\n      </script>\n    "],r)
if(u.a.ch)s.push("    <script>\n      document.addEventListener('DOMContentLoaded', function() {\n        const buttons = document.querySelectorAll('.quote-toggle-button');\n        buttons.forEach(button => {\n          button.onclick = function() {\n            const blockquote = this.nextElementSibling;\n            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {\n              this.classList.toggle('collapsed');\n              if (this.classList.contains('collapsed')) {\n                this.title = 'Show trimmed content';\n              } else {\n                this.title = 'Hide expanded content';\n              }\n            }\n          };\n        });\n      });\n    </script>")
if(u.a.ay!=null){r=A.QC()||A.QD()
p=u.d
s.push(r?'    <script type="text/javascript">\n      let lastY = 0;\n      let lastTime = 0;\n      let velocity = 0;\n    \n      function onTouchStart(e) { \n        lastY = e.touches[0].clientY;\n        lastTime = performance.now();\n        velocity = 0;\n      }\n    \n      function onTouchMove(e) { \n        const now = performance.now();\n        const y = e.touches[0].clientY;\n        const dy = lastY - y;\n        const dt = now - lastTime;\n    \n        if (dt > 0) {\n          velocity = dy / dt; // px per ms\n          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity\n        }\n    \n        lastY = y;\n        lastTime = now;\n    \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+'",\n          type: "toDart: onScrollChanged",\n          deltaY: dy,\n        }), \'*\');\n      }\n    \n      function onTouchEnd(e) { \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+"\",\n          type: \"toDart: onScrollEnd\",\n          velocity: velocity,\n        }), '*');\n      }\n    \n      window.addEventListener('touchstart', onTouchStart, { passive: true });\n      window.addEventListener('touchmove', onTouchMove, { passive: true });\n      window.addEventListener('touchend', onTouchEnd, { passive: true });\n    \n      window.addEventListener('pagehide', () => {\n        window.removeEventListener('touchstart', onTouchStart);\n        window.removeEventListener('touchmove', onTouchMove);\n        window.removeEventListener('touchend', onTouchEnd);\n      });\n    </script>\n\n  ":'    <script type="text/javascript">\n      function onWheel(e) { \n        const deltaY = event.deltaY;\n        window.parent.postMessage(JSON.stringify({\n          "view": "'+p+'",\n          "type": "toDart: onScrollChanged",\n          "deltaY": deltaY\n        }), "*");\n      }\n      \n      window.addEventListener(\'wheel\', onWheel, { passive: true });\n      \n      window.addEventListener(\'pagehide\', (event) => {\n        window.removeEventListener(\'wheel\', onWheel);\n      });\n    </script>\n  ')}if(u.a.Q!=null)s.push("    <script type=\"text/javascript\">\n      window.addEventListener('keydown', handleIframeKeydown);\n      \n      window.addEventListener('pagehide', (event) => {\n        window.removeEventListener('keydown', handleIframeKeydown);\n      });\n      \n      function handleIframeKeydown(event) {\n        const payload = {\n          view: '"+u.d+"',\n          type: 'toDart: iframeKeydown',\n          key: event.key,\n          code: event.code,\n          shift: event.shiftKey\n        };\n        window.parent.postMessage(JSON.stringify(payload), \"*\");\n      }\n    </script>\n  ")
if(u.a.fx)s.push("    <script type=\"text/javascript\">\n      document.addEventListener('click', function (e) {\n        try {\n          const payload = {\n            view: '"+u.d+"',\n            type: 'toDart: iframeClick',\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        } catch (_) {}\n      });\n    </script>\n  ")
if(!A.QC()&&!A.QD()){r=u.d
s.push('    <script type="text/javascript">\n      document.addEventListener("mouseover", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const rect = target.getBoundingClientRect();\n          \n          const payload = {\n            view: \''+r+'\',\n            type: \'toDart: iframeLinkHover\',\n            url: target.href,\n            rect: {\n              x: rect.x,\n              y: rect.y,\n              width: rect.width,\n              height: rect.height\n            }\n          };\n          window.parent.postMessage(JSON.stringify(payload), "*");\n        }\n      });\n    \n      document.addEventListener("mouseout", function (e) {\n        const target = e.target;\n        if (target.tagName.toLowerCase() === "a") {\n          const payload = {\n            view: \''+r+"',\n            type: 'toDart: iframeLinkOut'\n          };\n          window.parent.postMessage(JSON.stringify(payload), \"*\");\n        }\n      });\n    </script>\n  ")}v=B.c.ip(s)
s=u.y
s===$&&A.d()
r=u.a
p=r.db
o=r.f
n=r.r
m=r.w
r=r.x
r=m?"    body {\n      font-weight: 400;\n      font-size: "+r+"px;\n      font-style: normal;\n    }\n    \n    p {\n      margin: 0px;\n    }\n  ":""
o=o===B.aH?'dir="rtl"':""
n=n!=null?"margin: "+A.e(n)+";":""
u.w='      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      <style>\n            @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");\n      font-weight: 400;\n      font-style: normal;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");\n      font-weight: 500;\n      font-style: medium;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");\n      font-weight: 600;\n      font-style: semi-bold;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");\n      font-weight: 700;\n      font-style: bold;\n    }\n    \n    body {\n      font-family: \'Inter\', sans-serif;\n    }\n  \n        \n        '+r+"\n        \n        .tmail-content {\n          min-height: "+A.e(s)+"px;\n          min-width: "+p+"px;\n          overflow: auto;\n          overflow-wrap: break-word;\n          word-break: break-word;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n        \n        pre {\n          white-space: pre-wrap;\n        }\n        \n        table {\n          white-space: normal !important;\n        }\n              \n        @media only screen and (max-width: 600px) {\n          table {\n            width: 100% !important;\n          }\n          \n          a {\n            width: -webkit-fill-available !important;\n          }\n        }\n        \n        table, td, th {\n          word-break: normal !important;\n        }\n        \n        "+w+"\n      </style>\n      </head>\n      <body "+o+' style = "overflow-x: hidden; '+n+'";>\n      <div class="tmail-content">'+q+"</div>\n      "+v+"\n      </body>\n      </html> \n    "
u.r=A.bG(!0,y.y)},
t(d){var x=this
x.wQ(d)
if(x.a.fr)return x.apZ()
else return A.eN(new C.d5N(x))},
apZ(){var x,w=this,v=null,u=A.I(w).l(0),t=w.e
t===$&&A.d()
A.y(u+"::_buildHtmlElementView: ActualHeight: "+A.e(t),v,v,B.f,v,!1)
t=A.c([],y.p)
u=w.w
if((u==null?v:B.d.ah(u).length!==0)===!0)t.push(A.Z8(new C.d5J(w),w.r,y.y))
if(w.x)t.push(D.a4U)
x=new A.cs(B.a5,v,B.a0,B.F,t,v)
w.a.toString
u=w.f
u===$&&A.d()
return new A.b1(u,v,x,v)},
p(){var x,w=this
w.w=null
x=w.z
x===$&&A.d()
x.al(0)
if(!A.QC()&&!A.QD()){x=w.as
if(x!=null)x.eB()
w.as=null}w.aG()},
gtk(){return this.a.cx}}
C.azd.prototype={
ar(){this.aN()
if(this.a.cx)this.vr()},
iN(){var x=this.iP$
if(x!=null){x.b0()
x.ic()
this.iP$=null}this.pp()}}
C.a03.prototype={
aKf(d,e,f){return this.a.toLowerCase()===e.toLowerCase()&&this.c===f},
AM(d,e){return this.aKf(0,e,!1)},
gu(){return[this.a,this.b,this.c]}}
C.bfK.prototype={}
C.c3_.prototype={}
C.aOi.prototype={
amU(d,e,f,g){var x,w,v,u,t,s,r,q,p,o,n=this,m={}
if(n.a!=null){n.eB()
A.afs(new C.c32(n,e,f,g),y.P)
return}x=A.pD(e,y.u)
if(x==null)return
w=e.gak()
v=g.hA(w instanceof A.a7?A.dg(w.cr(0,null),B.r):B.r)
u=y.w
t=A.O(e,B.v,u).w.a.a
u=A.O(e,B.v,u).w
s=t<400?t-24:400
r=v.d
q=r+28+4>u.a.b
p=q?v.b-28-4:r+4
o=m.a=v.a
if((o+s>t?m.a=t-s-12:o)<12)m.a=12
m=A.lI(new C.c33(m,n,q,p,s,f),!1,!1,!1)
n.a=m
x.nt(0,m)},
eB(){var x=this.a
if(x!=null)x.e9(0)
this.a=null}}
var z=a.updateTypes(["~(ws)","~()"])
C.d5K.prototype={
$0(){var x=this.a
x.e=this.b
x.x=!1},
$S:0}
C.d5L.prototype={
$0(){this.a.x=!1},
$S:0}
C.d5M.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.d5N.prototype={
$2(d,e){var x=this.a,w=x.y
w===$&&A.d()
x.y=Math.min(e.d,w)
return x.apZ()},
$S:96}
C.d5J.prototype={
$2(d,e){var x,w,v,u,t=null
if(e.b!=null){x=this.a
w=A.dEV(!0,new A.b6(A.e(x.w)+"-"+A.e(x.a.a),y.O),new C.d5I(x),"iframe")
v=x.a.dy
u=x.e
x=x.f
if(v!=null){u===$&&A.d()
x===$&&A.d()
return A.a8(t,w,B.k,t,new A.as(0,1/0,0,v),t,t,u,t,t,t,t,t,x)}else{u===$&&A.d()
x===$&&A.d()
return new A.b1(x,u,w,t)}}else return B.x},
$S:207}
C.d5I.prototype={
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
$S:680}
C.c32.prototype={
$0(){var x=this,w=x.b
if(w.e!=null)x.a.amU(0,w,x.c,x.d)},
$S:8}
C.c33.prototype={
$1(d){var x=this,w=null,v=x.b,u=A.j4(0,A.cP(B.bO,w,B.M,!1,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,v.gqQ(),w,w,w,w,w,w,w,w,!1,B.a3),w),t=x.a.a,s=A.c([new A.c1(0,B.V,B.n.aA(0.15),B.r,20)],y.V)
v=v.b.e
if(v==null)v=D.aZL
return A.dvN(new C.c31(x.c),new A.cs(B.a5,w,B.a0,B.F,A.c([u,A.k5(w,A.cR(A.cf(B.C,!0,B.lH,A.a8(w,A.ah(x.f,w,1,B.A,w,w,v,w,w,w),B.k,w,new A.as(0,x.e,28,1/0),new A.b8(B.n,w,w,B.lH,s,w,w,B.B),w,w,w,w,B.mn,w,w,w),B.k,w,0,w,w,w,w,w,B.aw)),w,t,x.d,w)],y.p),w),B.hM,B.yB,new A.bJ(0,1,y.t),y.i)},
$S:395}
C.c31.prototype={
$3(d,e,f){var x=this.a?-1:1
return A.mX(A.b4x(f,new A.K(0,x*(1-e)*8)),null,e)},
$S:398};(function aliases(){var x=C.azd.prototype
x.b19=x.ar})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
x(C.auh.prototype,"gbi_","bi0",0)
w(C.aOi.prototype,"gqQ","eB",1)})();(function inheritance(){var x=a.mixinHard,w=a.mixin,v=a.inherit,u=a.inheritMany
v(C.Os,A.ai)
v(C.azd,A.af)
v(C.auh,C.azd)
u(A.vS,[C.d5K,C.d5L,C.d5M,C.c32])
u(A.vT,[C.d5N,C.d5J])
u(A.ph,[C.d5I,C.c33,C.c31])
u(A.a3,[C.bfK,C.c3_,C.aOi])
v(C.a03,C.bfK)
x(C.azd,A.rv)
w(C.bfK,A.p)})()
A.ES(b.typeUniverse,JSON.parse('{"Os":{"ai":[],"j":[],"o":[]},"auh":{"af":["Os"]},"a03":{"p":[]}}'))
var y=(function rtii(){var x=A.at
return{v:x("GD"),V:x("P<c1>"),s:x("P<h>"),p:x("P<j>"),w:x("nN"),_:x("ws"),P:x("b2"),u:x("HL"),t:x("bJ<ar>"),O:x("b6<h>"),N:x("a70<ii>"),y:x("B"),i:x("ar")}})();(function constants(){D.aV3=new A.b1(30,30,B.rO,null)
D.aMR=new A.a_(B.co,D.aV3,null)
D.a4U=new A.dW(B.cX,null,null,D.aMR,null)
D.aZL=new A.am(!0,B.m,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)})();(function lazyInitializers(){var x=a.lazyFinal
x($,"eYa","dUf",()=>A.b5("<[a-zA-Z][^>\\s]*[^>]*>",!0,!1,!1,!1))
x($,"eY9","dUe",()=>A.b5("</[a-zA-Z][^>]{0,128}>",!0,!1,!1,!1))})()};
((a,b)=>{a[b]=a.current
a.eventLog.push({p:"main.dart.js_8",e:"endPart",h:b})})($__dart_deferred_initializers__,"2NTIW9zP9TVYBeJRTYmog+1bfAU=");