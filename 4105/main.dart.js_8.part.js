((a,b,c)=>{a[b]=a[b]||{}
a[b][c]=a[b][c]||[]
a[b][c].push({p:"main.dart.js_8",e:"beginPart"})})(self,"$__dart_deferred_initializers__","eventLog")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={
bOP(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v){return new C.LY(f,v,k,h,g,t,p,r,d,s,j,i,n,l,m,q,u,e,o)},
LY:function LY(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.r=h
_.w=i
_.x=j
_.y=k
_.z=l
_.as=m
_.at=n
_.ax=o
_.ay=p
_.ch=q
_.CW=r
_.cx=s
_.cy=t
_.db=u
_.a=v},
ap9:function ap9(d){var _=this
_.f=_.e=_.d=$
_.w=_.r=null
_.x=!0
_.z=_.y=$
_.Q=!1
_.ef$=d
_.c=_.a=null},
cOu:function cOu(d,e){this.a=d
this.b=e},
cOv:function cOv(d){this.a=d},
cOw:function cOw(d,e){this.a=d
this.b=e},
cOx:function cOx(d){this.a=d},
cOt:function cOt(d){this.a=d},
cOs:function cOs(d){this.a=d},
atR:function atR(){},
dKi(d){var x,w,v,u,t,s,r,q,p="text/html"
if(!(B.d.t(d,A.br("<[a-zA-Z][^>]*>",!0,!1,!1,!1))&&B.d.t(d,A.br("</[a-zA-Z][^>]*>",!0,!1,!1,!1))))return d
try{new DOMParser().parseFromString(d,p).toString}catch(x){return d}w=new DOMParser().parseFromString('<div class="quote-toggle-container" >'+d+"</div>",p)
v=w.querySelectorAll(".quote-toggle-container > blockquote")
v.toString
u=y.f
t=new A.a3_(v,u)
for(s=1;t.gA(0)===0;){if(s>=3)return d
v=w.querySelectorAll(".quote-toggle-container"+B.d.b1(" > div",s)+" > blockquote")
v.toString
t=new A.a3_(v,u);++s}r=t.$ti.c.a(B.un.gW(t.a))
q=new DOMParser().parseFromString('      <button class="quote-toggle-button collapsed" title="Show trimmed content">\n          <span class="dot"></span>\n          <span class="dot"></span>\n          <span class="dot"></span>\n      </button>',p).querySelector(".quote-toggle-button")
v=r.parentNode
if(v!=null&&q!=null)v.insertBefore(q,r).toString
v=w.documentElement
v=v==null?null:J.dD1(v)
return v==null?d:v},
dnl(){if(!B.d.t(window.navigator.userAgent.toLowerCase(),"iphone"))var x=B.d.t(window.navigator.userAgent.toLowerCase(),"android")&&B.d.t(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x},
dnm(){if(!B.d.t(window.navigator.userAgent.toLowerCase(),"ipad"))var x=B.d.t(window.navigator.userAgent.toLowerCase(),"android")&&!B.d.t(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[12],C)
D=c[22]
C.LY.prototype={
Y(){return new C.ap9(null)}}
C.ap9.prototype={
ar(){var x,w=this
w.aVU()
x=w.a
w.e=x.e
w.f=x.d
w.y=x.ch
w.aqY()
x=window
x.toString
x=A.iv(x,"message",w.gbaw(),!1,y.B)
w.z!==$&&A.cS()
w.z=x},
bax(d){var x,w,v,u,t,s,r,q,p,o,n,m,l=this,k=null
try{x=B.as.fh(0,new A.qu([],[]).qW(d.data,!0))
w=J.am(x,"view")
t=l.d
t===$&&A.d()
if(!J.t(w,t))return
v=J.am(x,"type")
if(l.garD()){t=v
t=(t==null?k:B.d.t(t,"toDart: onScrollChanged"))===!0}else t=!1
if(t){t=l.a.as
t.toString
s=J.am(x,"deltaY")
if(s==null)s=0
r=t.f
q=B.c.gbx(r).at
q.toString
p=q+s
q=C.dnl()||C.dnm()
if(q)t.iX(B.j.fp(p,B.c.gbx(r).geI(),B.c.gbx(r).ge3()),B.ad,B.nX)
else if(p<B.c.gbx(r).geI())t.j2(B.c.gbx(r).geI())
else if(p>B.c.gbx(r).ge3())t.j2(B.c.gbx(r).ge3())
else t.j2(p)
return}else{if(l.garD()){t=v
t=(t==null?k:B.d.t(t,"toDart: onScrollEnd"))===!0}else t=!1
if(t){t=l.a.as
t.toString
o=J.am(x,"velocity")
n=J.dfP(o==null?0:o,800)
r=t.f
q=B.c.gbx(r).at
q.toString
t.iX(B.j.fp(q+n,B.c.gbx(r).geI(),B.c.gbx(r).ge3()),B.fg,B.hB)
return}}if(J.t(J.am(x,"message"),"iframeHasBeenLoaded"))l.Q=!0
if(!l.Q)return
t=v
if((t==null?k:B.d.t(t,"toDart: htmlHeight"))===!0)l.b8i(J.am(x,"height"))
else{t=v
t=(t==null?k:B.d.t(t,"toDart: htmlWidth"))===!0
if(t)l.a.toString
if(t)l.b8j(J.am(x,"width"))
else{t=v
if((t==null?k:B.d.t(t,"toDart: OpenLink"))===!0){t=J.am(x,"url")
if(t!=null&&l.c!=null&&typeof t=="string"&&B.d.bl(t,"mailto:")){r=l.a.x
if(r!=null)r.$1(A.jh(t))}}else{t=v
if((t==null?k:B.d.t(t,"toDart: onClickHyperLink"))===!0){t=J.am(x,"url")
if(t!=null&&l.c!=null&&typeof t=="string"){r=l.a.y
if(r!=null)r.$1(A.jh(t))}}}}}}catch(m){u=A.O(m)
A.y("_HtmlContentViewerOnWebState::_handleMessageEvent:Exception = "+A.e(u),B.w)}},
garD(){var x=this.a.as
if(x!=null)x=x.f.length!==0===!0
else x=!1
return x},
b8i(d){var x,w,v,u,t,s,r=this
if(d==null){x=r.e
x===$&&A.d()
w=x}else w=d
x=r.c
if(x!=null){v=J.avv(w,r.a.cx)
A.y(A.J(r).l(0)+"::_handleContentHeightEvent: ScrollHeightWithBuffer = "+A.e(v),B.h)
x=r.a.db
u=J.bje(v)
t=r.y
if(x){t===$&&A.d()
s=u.pp(v,t)}else{t===$&&A.d()
s=u.nc(v,t)}if(s)r.S(new C.cOu(r,v))}if(r.c!=null&&r.x)r.S(new C.cOv(r))},
b8j(d){var x,w,v=this
if(d==null){x=v.f
x===$&&A.d()
w=x}else w=d
if(v.c!=null&&J.dfO(w,v.a.CW)&&v.a.z)v.S(new C.cOw(v,w))},
b6(d){var x,w,v=this
v.bn(d)
x=d.f
A.y("_HtmlContentViewerOnWebState::didUpdateWidget():Old-Direction: "+x.l(0)+" | Current-Direction: "+v.a.f.l(0),B.h)
w=v.a
if(w.c!==d.c||w.f!==x)v.aqY()
x=v.a
w=x.e
if(w!==d.e)v.e=w
x=x.d
if(x!==d.d)v.f=x},
b6Q(d){var x,w=$.bjG(),v=J.tz(d,y.D)
for(x=0;x<d;++x)v[x]=w.tR(255)
return B.pV.ghA().bH(v)},
aqY(){var x,w,v,u=this,t="\n          \n          ",s=u.d=u.b6Q(10),r=u.a,q=r.c,p=!r.db,o=p?'          const resizeObserver = new ResizeObserver((entries) => {\n            var height = document.body.scrollHeight;\n            window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n          });\n        ':"",n=r.x!=null,m=n?'                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':"",l=r.y!=null,k=l?'                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':""
l=l?"                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                ":""
n=n?"                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                ":""
p=p?"resizeObserver.observe(document.body);":""
if(r.at)q=C.dKi(q)
r=y.x
x=A.c(["    .tmail-tooltip .tooltiptext {\n      visibility: hidden;\n      max-width: 400px;\n      background-color: black;\n      color: #fff;\n      text-align: center;\n      border-radius: 6px;\n      padding: 5px 8px 5px 8px;\n      white-space: nowrap; \n      overflow: hidden;\n      text-overflow: ellipsis;\n      position: absolute;\n      z-index: 1;\n    }\n    .tmail-tooltip:hover .tooltiptext {\n      visibility: visible;\n    }\n  "],r)
if(u.a.at)x.push("    <style>\n      .quote-toggle-button + blockquote {\n        display: block; /* Default display */\n      }\n      .quote-toggle-button.collapsed + blockquote {\n        display: none;\n      }\n      .quote-toggle-button {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        width: 20px;\n        height: 20px;\n        gap: 2px;\n        background-color: #d7e2f5;\n        padding: 0;\n        margin: 8px 0;\n        border-radius: 50%;\n        transition: background-color 0.2s ease-in-out;\n        border: none;\n        cursor: pointer;\n        -webkit-appearance: none;\n        -moz-appearance: none;\n        appearance: none;\n        -webkit-user-select: none; /* Safari */\n        -moz-user-select: none; /* Firefox */\n        -ms-user-select: none; /* IE 10+ */\n        user-select: none; /* Standard syntax */\n        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */\n      }\n      .quote-toggle-button:hover {\n        background-color: #cdcdcd !important;\n      }\n      .dot {\n        width: 3.75px;\n        height: 3.75px;\n        background-color: #55687d;\n        border-radius: 50%;\n      }\n    </style>")
if(u.a.ax)x.push("    html, body {\n      overflow: hidden;\n      overscroll-behavior: none;\n      scrollbar-width: none; /* Firefox */\n      -ms-overflow-style: none; /* IE/Edge */\n    }\n    ::-webkit-scrollbar {\n        display: none;\n      }\n  ")
w=B.c.iA(x)
s=A.c(["      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes(\"toIframe:\")) {\n            var data = JSON.parse(e.data);\n            if (data[\"view\"].includes(\""+s+'")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n\n        '+o+"\n        \n        "+m+"\n        \n        \n        \n        "+k+'\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getWidth"}), "*");\n          \n          '+l+t+n+t+p+"\n        }\n      </script>\n    ","    <script type=\"text/javascript\">\n      document.addEventListener('wheel', function(e) {\n        e.ctrlKey && e.preventDefault();\n      }, {\n        passive: false,\n      });\n      window.addEventListener('keydown', function(e) {\n        if (event.metaKey || event.ctrlKey) {\n          switch (event.key) {\n            case '=':\n            case '-':\n              event.preventDefault();\n              break;\n          }\n        }\n      });\n    </script>\n  ","    <script>\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  ",'      <script type="text/javascript">\n        const displayWidth = '+A.e(u.a.d)+";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          // Remove width and height properties from style string\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          // Extract width and height values with units from style string\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          // Normalize style attribute to ensure proper responsive behavior\n          let style = attrs['style'];\n          \n          if (!style) {\n            attrs['style'] = 'max-width:100%;height:auto;display:inline;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          // Ensure proper style string formatting\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          // Add responsive defaults if missing\n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;';\n          }\n    \n          if (!style.includes('height')) {\n            style += 'height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          // Normalize width/height attributes and remove if necessary\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          // Remove attribute if value is null or undefined\n          if (widthStr === null || widthStr === undefined) {\n            delete attrs['width'];\n          } else if (displayWidth !== undefined) {\n            const widthValue = parseFloat(widthStr);\n            if (!isNaN(widthValue)) {\n              if (widthValue > displayWidth) {\n                delete attrs['width'];\n                delete attrs['height'];\n              }\n            }\n          }\n    \n          // Remove height attribute if value is null or undefined\n          if (heightStr === null || heightStr === undefined) {\n            delete attrs['height'];\n          }\n        }\n    \n        function normalizeImageSize(attrs) {\n          // Apply both style and attribute normalization\n          normalizeWidthHeightAttribute(attrs);\n          normalizeStyleAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          // Process all images on the page\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            // Handle style attribute\n            if (attrs.style !== null && attrs.style !== undefined) {\n              img.setAttribute('style', attrs.style);\n            } else {\n              img.removeAttribute('style');\n            }\n    \n            // Handle width attribute\n            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {\n              img.setAttribute('width', attrs.width);\n            } else {\n              img.removeAttribute('width');\n            }\n    \n            // Handle height attribute\n            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {\n              img.setAttribute('height', attrs.height);\n            } else {\n              img.removeAttribute('height');\n            }\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          // Error-safe wrapper for the normalization function\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        // Run normalization when page loads\n        window.onload = safeApplyImageNormalization;\n      </script>\n    "],r)
if(u.a.at)s.push("    <script>\n      document.addEventListener('DOMContentLoaded', function() {\n        const buttons = document.querySelectorAll('.quote-toggle-button');\n        buttons.forEach(button => {\n          button.onclick = function() {\n            const blockquote = this.nextElementSibling;\n            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {\n              this.classList.toggle('collapsed');\n              if (this.classList.contains('collapsed')) {\n                this.title = 'Show trimmed content';\n              } else {\n                this.title = 'Hide expanded content';\n              }\n            }\n          };\n        });\n      });\n    </script>")
if(u.a.as!=null){r=C.dnl()||C.dnm()
p=u.d
s.push(r?'    <script type="text/javascript">\n      let lastY = 0;\n      let lastTime = 0;\n      let velocity = 0;\n    \n      function onTouchStart(e) { \n        lastY = e.touches[0].clientY;\n        lastTime = performance.now();\n        velocity = 0;\n      }\n    \n      function onTouchMove(e) { \n        const now = performance.now();\n        const y = e.touches[0].clientY;\n        const dy = lastY - y;\n        const dt = now - lastTime;\n    \n        if (dt > 0) {\n          velocity = dy / dt; // px per ms\n          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity\n        }\n    \n        lastY = y;\n        lastTime = now;\n    \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+'",\n          type: "toDart: onScrollChanged",\n          deltaY: dy,\n        }), \'*\');\n      }\n    \n      function onTouchEnd(e) { \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+"\",\n          type: \"toDart: onScrollEnd\",\n          velocity: velocity,\n        }), '*');\n      }\n    \n      window.addEventListener('touchstart', onTouchStart, { passive: true });\n      window.addEventListener('touchmove', onTouchMove, { passive: true });\n      window.addEventListener('touchend', onTouchEnd, { passive: true });\n    \n      window.addEventListener('pagehide', () => {\n        window.removeEventListener('touchstart', onTouchStart);\n        window.removeEventListener('touchmove', onTouchMove);\n        window.removeEventListener('touchend', onTouchEnd);\n      });\n    </script>\n\n  ":'    <script type="text/javascript">\n      function onWheel(e) { \n        const deltaY = event.deltaY;\n        window.parent.postMessage(JSON.stringify({\n          "view": "'+p+'",\n          "type": "toDart: onScrollChanged",\n          "deltaY": deltaY\n        }), "*");\n      }\n      \n      window.addEventListener(\'wheel\', onWheel, { passive: true });\n      \n      window.addEventListener(\'pagehide\', (event) => {\n        window.removeEventListener(\'wheel\', onWheel);\n      });\n    </script>\n  ')}v=B.c.iA(s)
s=u.y
s===$&&A.d()
r=u.a
p=r.CW
o=r.f
n=r.r
r=r.w?"    div, p, span, th, td, tr, ul, ol, li, a, button {\n      font-weight: 400;\n      font-size: 16px;\n      line-height: 24px;\n      letter-spacing: -0.01em; /* -1% */\n    }\n    \n    p {\n      margin: 0px;\n    }\n  ":""
o=o===B.aA?'dir="rtl"':""
n=n!=null?"margin: "+A.e(n)+";":""
u.w='      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      <style>\n            @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");\n      font-weight: 400;\n      font-style: normal;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");\n      font-weight: 500;\n      font-style: medium;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");\n      font-weight: 600;\n      font-style: semi-bold;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");\n      font-weight: 700;\n      font-style: bold;\n    }\n    \n    body {\n      font-family: \'Inter\', sans-serif;\n    }\n  \n        \n        '+r+"\n        \n        .tmail-content {\n          min-height: "+A.e(s)+"px;\n          min-width: "+p+"px;\n          overflow: auto;\n          overflow-wrap: break-word;\n          word-break: break-word;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n        \n        pre {\n          white-space: pre-wrap;\n        }\n        \n        table {\n          white-space: normal !important;\n        }\n              \n        @media only screen and (max-width: 600px) {\n          table {\n            width: 100% !important;\n          }\n          \n          a {\n            width: -webkit-fill-available !important;\n          }\n        }\n        \n        "+w+"\n      </style>\n      </head>\n      <body "+o+' style = "overflow-x: hidden; '+n+'";>\n      <div class="tmail-content">'+q+"</div>\n      "+v+"\n      </body>\n      </html> \n    "
u.r=A.bK(!0,y.e)},
u(d){var x=this
x.vQ(d)
if(x.a.db)return x.alT()
else return A.fb(new C.cOx(x))},
alT(){var x,w=this,v=null,u=A.J(w).l(0),t=w.e
t===$&&A.d()
A.y(u+"::_buildHtmlElementView: ActualHeight: "+A.e(t),B.h)
t=A.c([],y.u)
u=w.w
if((u==null?v:B.d.aY(u).length!==0)===!0)t.push(A.VN(new C.cOt(w),w.r,y.e))
if(w.x)t.push(D.a2F)
x=new A.cB(B.ag,v,B.a2,B.G,t,v)
w.a.toString
u=w.f
u===$&&A.d()
return new A.b1(u,v,x,v)},
p(){this.w=null
var x=this.z
x===$&&A.d()
x.ao(0)
this.aA()},
grz(){return this.a.ay}}
C.atR.prototype={
ar(){this.aI()
if(this.a.ay)this.ux()},
iy(){var x=this.ef$
if(x!=null){x.aP()
x.i1()
this.ef$=null}this.oK()}}
var z=a.updateTypes(["~(q2)"])
C.cOu.prototype={
$0(){var x=this.a
x.e=this.b
x.x=!1},
$S:0}
C.cOv.prototype={
$0(){this.a.x=!1},
$S:0}
C.cOw.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.cOx.prototype={
$2(d,e){var x=this.a,w=x.y
w===$&&A.d()
x.y=Math.min(e.d,w)
return x.alT()},
$S:217}
C.cOt.prototype={
$2(d,e){var x,w,v,u,t=null
if(e.b!=null){x=this.a
w=A.djS(!0,new A.b6(A.e(x.w)+"-"+A.e(x.a.a),y.q),new C.cOs(x),"iframe")
v=x.a.cy
u=x.e
x=x.f
if(v!=null){u===$&&A.d()
x===$&&A.d()
return A.a9(t,w,B.k,t,new A.au(0,1/0,0,v),t,t,u,t,t,t,t,t,x)}else{u===$&&A.d()
x===$&&A.d()
return new A.b1(x,u,w,t)}}else return B.y},
$S:219}
C.cOs.prototype={
$1(d){var x,w
y.C.a(d)
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
$S:455};(function aliases(){var x=C.atR.prototype
x.aVU=x.ar})();(function installTearOffs(){var x=a._instance_1u
x(C.ap9.prototype,"gbaw","bax",0)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.LY,A.ae)
w(C.atR,A.ad)
w(C.ap9,C.atR)
v(A.uW,[C.cOu,C.cOv,C.cOw])
v(A.uX,[C.cOx,C.cOt])
w(C.cOs,A.ov)
x(C.atR,A.qJ)})()
A.Dl(b.typeUniverse,JSON.parse('{"LY":{"ae":[],"i":[]},"ap9":{"ad":["LY"]}}'))
var y={C:A.ap("xY"),x:A.ap("N<f>"),u:A.ap("N<i>"),B:A.ap("q2"),q:A.ap("b6<f>"),f:A.ap("a3_<l4>"),e:A.ap("B"),D:A.ap("E")};(function constants(){D.aQS=new A.b1(30,30,B.qZ,null)
D.aJ_=new A.W(B.cp,D.aQS,null)
D.a2F=new A.dA(B.d2,null,null,D.aJ_,null)})()};
((a,b)=>{a[b]=a.current
a.eventLog.push({p:"main.dart.js_8",e:"endPart",h:b})})($__dart_deferred_initializers__,"SAzUkmwMej/2fLBCloEuzIa/3VI=");