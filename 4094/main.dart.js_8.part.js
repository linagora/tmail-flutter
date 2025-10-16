((a,b,c)=>{a[b]=a[b]||{}
a[b][c]=a[b][c]||[]
a[b][c].push({p:"main.dart.js_8",e:"beginPart"})})(self,"$__dart_deferred_initializers__","eventLog")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={
bOY(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v){return new C.M1(f,v,k,h,g,t,p,r,d,s,j,i,n,l,m,q,u,e,o)},
M1:function M1(d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v){var _=this
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
ape:function ape(d){var _=this
_.f=_.e=_.d=$
_.w=_.r=null
_.x=!0
_.z=_.y=$
_.Q=!1
_.ef$=d
_.c=_.a=null},
cOM:function cOM(d,e){this.a=d
this.b=e},
cON:function cON(d){this.a=d},
cOO:function cOO(d,e){this.a=d
this.b=e},
cOP:function cOP(d){this.a=d},
cOL:function cOL(d){this.a=d},
cOK:function cOK(d){this.a=d},
atW:function atW(){},
dKD(d){var x,w,v,u,t,s,r,q,p="text/html"
if(!(B.d.t(d,A.br("<[a-zA-Z][^>]*>",!0,!1,!1,!1))&&B.d.t(d,A.br("</[a-zA-Z][^>]*>",!0,!1,!1,!1))))return d
try{new DOMParser().parseFromString(d,p).toString}catch(x){return d}w=new DOMParser().parseFromString('<div class="quote-toggle-container" >'+d+"</div>",p)
v=w.querySelectorAll(".quote-toggle-container > blockquote")
v.toString
u=y.f
t=new A.a34(v,u)
for(s=1;t.gA(0)===0;){if(s>=3)return d
v=w.querySelectorAll(".quote-toggle-container"+B.d.b1(" > div",s)+" > blockquote")
v.toString
t=new A.a34(v,u);++s}r=t.$ti.c.a(B.ur.gW(t.a))
q=new DOMParser().parseFromString('      <button class="quote-toggle-button collapsed" title="Show trimmed content">\n          <span class="dot"></span>\n          <span class="dot"></span>\n          <span class="dot"></span>\n      </button>',p).querySelector(".quote-toggle-button")
v=r.parentNode
if(v!=null&&q!=null)v.insertBefore(q,r).toString
v=w.documentElement
v=v==null?null:J.dDn(v)
return v==null?d:v},
dnD(){if(!B.d.t(window.navigator.userAgent.toLowerCase(),"iphone"))var x=B.d.t(window.navigator.userAgent.toLowerCase(),"android")&&B.d.t(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x},
dnE(){if(!B.d.t(window.navigator.userAgent.toLowerCase(),"ipad"))var x=B.d.t(window.navigator.userAgent.toLowerCase(),"android")&&!B.d.t(window.navigator.userAgent.toLowerCase(),"mobile")
else x=!0
return x}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[12],C)
D=c[22]
C.M1.prototype={
Y(){return new C.ape(null)}}
C.ape.prototype={
aq(){var x,w=this
w.aVX()
x=w.a
w.e=x.e
w.f=x.d
w.y=x.ch
w.aqY()
x=window
x.toString
x=A.iw(x,"message",w.gbaD(),!1,y.B)
w.z!==$&&A.cS()
w.z=x},
baE(d){var x,w,v,u,t,s,r,q,p,o,n,m,l=this,k=null
try{x=B.as.fm(0,new A.qw([],[]).qW(d.data,!0))
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
q=B.c.gbz(r).at
q.toString
p=q+s
q=C.dnD()||C.dnE()
if(q)t.iW(B.j.fv(p,B.c.gbz(r).geI(),B.c.gbz(r).ge3()),B.ad,B.nX)
else if(p<B.c.gbz(r).geI())t.j2(B.c.gbz(r).geI())
else if(p>B.c.gbz(r).ge3())t.j2(B.c.gbz(r).ge3())
else t.j2(p)
return}else{if(l.garD()){t=v
t=(t==null?k:B.d.t(t,"toDart: onScrollEnd"))===!0}else t=!1
if(t){t=l.a.as
t.toString
o=J.am(x,"velocity")
n=J.dg4(o==null?0:o,800)
r=t.f
q=B.c.gbz(r).at
q.toString
t.iW(B.j.fv(q+n,B.c.gbz(r).geI(),B.c.gbz(r).ge3()),B.ff,B.hC)
return}}if(J.t(J.am(x,"message"),"iframeHasBeenLoaded"))l.Q=!0
if(!l.Q)return
t=v
if((t==null?k:B.d.t(t,"toDart: htmlHeight"))===!0)l.b8p(J.am(x,"height"))
else{t=v
t=(t==null?k:B.d.t(t,"toDart: htmlWidth"))===!0
if(t)l.a.toString
if(t)l.b8q(J.am(x,"width"))
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
b8p(d){var x,w,v,u,t,s,r=this
if(d==null){x=r.e
x===$&&A.d()
w=x}else w=d
x=r.c
if(x!=null){v=J.avA(w,r.a.cx)
A.y(A.J(r).l(0)+"::_handleContentHeightEvent: ScrollHeightWithBuffer = "+A.e(v),B.h)
x=r.a.db
u=J.bjm(v)
t=r.y
if(x){t===$&&A.d()
s=u.pq(v,t)}else{t===$&&A.d()
s=u.nc(v,t)}if(s)r.S(new C.cOM(r,v))}if(r.c!=null&&r.x)r.S(new C.cON(r))},
b8q(d){var x,w,v=this
if(d==null){x=v.f
x===$&&A.d()
w=x}else w=d
if(v.c!=null&&J.dg3(w,v.a.CW)&&v.a.z)v.S(new C.cOO(v,w))},
b6(d){var x,w,v=this
v.bo(d)
x=d.f
A.y("_HtmlContentViewerOnWebState::didUpdateWidget():Old-Direction: "+x.l(0)+" | Current-Direction: "+v.a.f.l(0),B.h)
w=v.a
if(w.c!==d.c||w.f!==x)v.aqY()
x=v.a
w=x.e
if(w!==d.e)v.e=w
x=x.d
if(x!==d.d)v.f=x},
b6X(d){var x,w=$.bjP(),v=J.tA(d,y.D)
for(x=0;x<d;++x)v[x]=w.tR(255)
return B.pY.ghA().bI(v)},
aqY(){var x,w,v,u=this,t="\n          \n          ",s=u.d=u.b6X(10),r=u.a,q=r.c,p=!r.db,o=p?'          const resizeObserver = new ResizeObserver((entries) => {\n            var height = document.body.scrollHeight;\n            window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n          });\n        ':"",n=r.x!=null,m=n?'                function handleOnClickEmailLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: OpenLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':"",l=r.y!=null,k=l?'                function onClickHyperLink(e) {\n                   var href = this.href;\n                   window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: onClickHyperLink", "url": "" + href}), "*");\n                   e.preventDefault();\n                }\n              ':""
l=l?"                  var hyperLinks = document.querySelectorAll('a');\n                  for (var i=0; i < hyperLinks.length; i++){\n                      hyperLinks[i].addEventListener('click', onClickHyperLink);\n                  }\n                ":""
n=n?"                  var emailLinks = document.querySelectorAll('a[href^=\"mailto:\"]');\n                  for (var i=0; i < emailLinks.length; i++){\n                      emailLinks[i].addEventListener('click', handleOnClickEmailLink);\n                  }\n                ":""
p=p?"resizeObserver.observe(document.body);":""
if(r.at)q=C.dKD(q)
r=y.x
x=A.c(["    .tmail-tooltip .tooltiptext {\n      visibility: hidden;\n      max-width: 400px;\n      background-color: black;\n      color: #fff;\n      text-align: center;\n      border-radius: 6px;\n      padding: 5px 8px 5px 8px;\n      white-space: nowrap; \n      overflow: hidden;\n      text-overflow: ellipsis;\n      position: absolute;\n      z-index: 1;\n    }\n    .tmail-tooltip:hover .tooltiptext {\n      visibility: visible;\n    }\n  "],r)
if(u.a.at)x.push("    <style>\n      .quote-toggle-button + blockquote {\n        display: block; /* Default display */\n      }\n      .quote-toggle-button.collapsed + blockquote {\n        display: none;\n      }\n      .quote-toggle-button {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        width: 20px;\n        height: 20px;\n        gap: 2px;\n        background-color: #d7e2f5;\n        padding: 0;\n        margin: 8px 0;\n        border-radius: 50%;\n        transition: background-color 0.2s ease-in-out;\n        border: none;\n        cursor: pointer;\n        -webkit-appearance: none;\n        -moz-appearance: none;\n        appearance: none;\n        -webkit-user-select: none; /* Safari */\n        -moz-user-select: none; /* Firefox */\n        -ms-user-select: none; /* IE 10+ */\n        user-select: none; /* Standard syntax */\n        -webkit-user-drag: none; /* Prevent dragging on WebKit browsers (e.g., Chrome, Safari) */\n      }\n      .quote-toggle-button:hover {\n        background-color: #cdcdcd !important;\n      }\n      .dot {\n        width: 3.75px;\n        height: 3.75px;\n        background-color: #55687d;\n        border-radius: 50%;\n      }\n    </style>")
if(u.a.ax)x.push("    html, body {\n      overflow: hidden;\n      overscroll-behavior: none;\n      scrollbar-width: none; /* Firefox */\n      -ms-overflow-style: none; /* IE/Edge */\n    }\n    ::-webkit-scrollbar {\n        display: none;\n      }\n  ")
w=B.c.iB(x)
s=A.c(["      <script type=\"text/javascript\">\n        window.parent.addEventListener('message', handleMessage, false);\n        window.addEventListener('load', handleOnLoad);\n        window.addEventListener('pagehide', (event) => {\n          window.parent.removeEventListener('message', handleMessage, false);\n        });\n      \n        function handleMessage(e) {\n          if (e && e.data && e.data.includes(\"toIframe:\")) {\n            var data = JSON.parse(e.data);\n            if (data[\"view\"].includes(\""+s+'")) {\n              if (data["type"].includes("getHeight")) {\n                var height = document.body.scrollHeight;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlHeight", "height": height}), "*");\n              }\n              if (data["type"].includes("getWidth")) {\n                var width = document.body.scrollWidth;\n                window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toDart: htmlWidth", "width": width}), "*");\n              }\n              if (data["type"].includes("execCommand")) {\n                if (data["argument"] === null) {\n                  document.execCommand(data["command"], false);\n                } else {\n                  document.execCommand(data["command"], false, data["argument"]);\n                }\n              }\n            }\n          }\n        }\n\n        '+o+"\n        \n        "+m+"\n        \n        \n        \n        "+k+'\n        \n        function handleOnLoad() {\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "message": "iframeHasBeenLoaded"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getHeight"}), "*");\n          window.parent.postMessage(JSON.stringify({"view": "'+s+'", "type": "toIframe: getWidth"}), "*");\n          \n          '+l+t+n+t+p+"\n        }\n      </script>\n    ","    <script type=\"text/javascript\">\n      document.addEventListener('wheel', function(e) {\n        e.ctrlKey && e.preventDefault();\n      }, {\n        passive: false,\n      });\n      window.addEventListener('keydown', function(e) {\n        if (event.metaKey || event.ctrlKey) {\n          switch (event.key) {\n            case '=':\n            case '-':\n              event.preventDefault();\n              break;\n          }\n        }\n      });\n    </script>\n  ","    <script>\n      const lazyImages = document.querySelectorAll('[lazy]');\n      const lazyImageObserver = new IntersectionObserver((entries, observer) => {\n        entries.forEach((entry) => {\n          if (entry.isIntersecting) {\n            const lazyImage = entry.target;\n            const src = lazyImage.dataset.src;\n            lazyImage.tagName.toLowerCase() === 'img'\n              ? lazyImage.src = src\n              : lazyImage.style.backgroundImage = \"url('\" + src + \"')\";\n            lazyImage.removeAttribute('lazy');\n            observer.unobserve(lazyImage);\n          }\n        });\n      });\n      \n      lazyImages.forEach((lazyImage) => {\n        lazyImageObserver.observe(lazyImage);\n      });\n    </script>\n  ",'      <script type="text/javascript">\n        const displayWidth = '+A.e(u.a.d)+";\n    \n        const sizeUnits = ['px', 'in', 'cm', 'mm', 'pt', 'pc'];\n    \n        function convertToPx(value, unit) {\n          switch (unit.toLowerCase()) {\n            case 'px': return value;\n            case 'in': return value * 96;\n            case 'cm': return value * 37.8;\n            case 'mm': return value * 3.78;\n            case 'pt': return value * (96 / 72);\n            case 'pc': return value * (96 / 6);\n            default: return value;\n          }\n        }\n    \n        function removeWidthHeightFromStyle(style) {\n          // Remove width and height properties from style string\n          style = style.replace(/width\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.replace(/height\\s*:\\s*[\\d.]+[a-zA-Z%]+\\s*;?/gi, '');\n          style = style.trim();\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n          return style;\n        }\n    \n        function extractWidthHeightFromStyle(style) {\n          // Extract width and height values with units from style string\n          const result = {};\n          const widthMatch = style.match(/width\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n          const heightMatch = style.match(/height\\s*:\\s*([\\d.]+)([a-zA-Z%]+)\\s*;?/);\n    \n          if (widthMatch) {\n            const value = parseFloat(widthMatch[1]);\n            const unit = widthMatch[2];\n            if (!isNaN(value) && unit) {\n              result['width'] = { value, unit };\n            }\n          }\n    \n          if (heightMatch) {\n            const value = parseFloat(heightMatch[1]);\n            const unit = heightMatch[2];\n            if (!isNaN(value) && unit) {\n              result['height'] = { value, unit };\n            }\n          }\n    \n          return result;\n        }\n    \n        function normalizeStyleAttribute(attrs) {\n          // Normalize style attribute to ensure proper responsive behavior\n          let style = attrs['style'];\n          \n          if (!style) {\n            attrs['style'] = 'max-width:100%;height:auto;display:inline;';\n            return;\n          }\n    \n          style = style.trim();\n          const dimensions = extractWidthHeightFromStyle(style);\n          const hasWidth = dimensions.hasOwnProperty('width');\n    \n          if (hasWidth) {\n            const widthData = dimensions['width'];\n            const widthPx = convertToPx(widthData.value, widthData.unit);\n    \n            if (displayWidth !== undefined &&\n                widthPx > displayWidth &&\n                sizeUnits.includes(widthData.unit)) {\n              style = removeWidthHeightFromStyle(style).trim();\n            }\n          }\n    \n          // Ensure proper style string formatting\n          if (style.length && !style.endsWith(';')) {\n            style += ';';\n          }\n    \n          // Add responsive defaults if missing\n          if (!style.includes('max-width')) {\n            style += 'max-width:100%;';\n          }\n    \n          if (!style.includes('height')) {\n            style += 'height:auto;';\n          }\n    \n          if (!style.includes('display')) {\n            style += 'display:inline;';\n          }\n    \n          attrs['style'] = style;\n        }\n    \n        function normalizeWidthHeightAttribute(attrs) {\n          // Normalize width/height attributes and remove if necessary\n          const widthStr = attrs['width'];\n          const heightStr = attrs['height'];\n    \n          // Remove attribute if value is null or undefined\n          if (widthStr === null || widthStr === undefined) {\n            delete attrs['width'];\n          } else if (displayWidth !== undefined) {\n            const widthValue = parseFloat(widthStr);\n            if (!isNaN(widthValue)) {\n              if (widthValue > displayWidth) {\n                delete attrs['width'];\n                delete attrs['height'];\n              }\n            }\n          }\n    \n          // Remove height attribute if value is null or undefined\n          if (heightStr === null || heightStr === undefined) {\n            delete attrs['height'];\n          }\n        }\n    \n        function normalizeImageSize(attrs) {\n          // Apply both style and attribute normalization\n          normalizeWidthHeightAttribute(attrs);\n          normalizeStyleAttribute(attrs);\n        }\n    \n        function applyImageNormalization() {\n          // Process all images on the page\n          document.querySelectorAll('img').forEach(img => {\n            const attrs = {\n              style: img.getAttribute('style'),\n              width: img.getAttribute('width'),\n              height: img.getAttribute('height')\n            };\n    \n            normalizeImageSize(attrs);\n    \n            // Handle style attribute\n            if (attrs.style !== null && attrs.style !== undefined) {\n              img.setAttribute('style', attrs.style);\n            } else {\n              img.removeAttribute('style');\n            }\n    \n            // Handle width attribute\n            if ('width' in attrs && attrs.width !== null && attrs.width !== undefined) {\n              img.setAttribute('width', attrs.width);\n            } else {\n              img.removeAttribute('width');\n            }\n    \n            // Handle height attribute\n            if ('height' in attrs && attrs.height !== null && attrs.height !== undefined) {\n              img.setAttribute('height', attrs.height);\n            } else {\n              img.removeAttribute('height');\n            }\n          });\n        }\n        \n        function safeApplyImageNormalization() {\n          // Error-safe wrapper for the normalization function\n          try {\n            applyImageNormalization();\n          } catch (e) {\n            console.error('Image normalization failed:', e);\n          }\n        }\n        \n        // Run normalization when page loads\n        window.onload = safeApplyImageNormalization;\n      </script>\n    "],r)
if(u.a.at)s.push("    <script>\n      document.addEventListener('DOMContentLoaded', function() {\n        const buttons = document.querySelectorAll('.quote-toggle-button');\n        buttons.forEach(button => {\n          button.onclick = function() {\n            const blockquote = this.nextElementSibling;\n            if (blockquote && blockquote.tagName === 'BLOCKQUOTE') {\n              this.classList.toggle('collapsed');\n              if (this.classList.contains('collapsed')) {\n                this.title = 'Show trimmed content';\n              } else {\n                this.title = 'Hide expanded content';\n              }\n            }\n          };\n        });\n      });\n    </script>")
if(u.a.as!=null){r=C.dnD()||C.dnE()
p=u.d
s.push(r?'    <script type="text/javascript">\n      let lastY = 0;\n      let lastTime = 0;\n      let velocity = 0;\n    \n      function onTouchStart(e) { \n        lastY = e.touches[0].clientY;\n        lastTime = performance.now();\n        velocity = 0;\n      }\n    \n      function onTouchMove(e) { \n        const now = performance.now();\n        const y = e.touches[0].clientY;\n        const dy = lastY - y;\n        const dt = now - lastTime;\n    \n        if (dt > 0) {\n          velocity = dy / dt; // px per ms\n          velocity = Math.max(Math.min(velocity, 2), -2); // clamp velocity\n        }\n    \n        lastY = y;\n        lastTime = now;\n    \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+'",\n          type: "toDart: onScrollChanged",\n          deltaY: dy,\n        }), \'*\');\n      }\n    \n      function onTouchEnd(e) { \n        window.parent.postMessage(JSON.stringify({\n          view: "'+p+"\",\n          type: \"toDart: onScrollEnd\",\n          velocity: velocity,\n        }), '*');\n      }\n    \n      window.addEventListener('touchstart', onTouchStart, { passive: true });\n      window.addEventListener('touchmove', onTouchMove, { passive: true });\n      window.addEventListener('touchend', onTouchEnd, { passive: true });\n    \n      window.addEventListener('pagehide', () => {\n        window.removeEventListener('touchstart', onTouchStart);\n        window.removeEventListener('touchmove', onTouchMove);\n        window.removeEventListener('touchend', onTouchEnd);\n      });\n    </script>\n\n  ":'    <script type="text/javascript">\n      function onWheel(e) { \n        const deltaY = event.deltaY;\n        window.parent.postMessage(JSON.stringify({\n          "view": "'+p+'",\n          "type": "toDart: onScrollChanged",\n          "deltaY": deltaY\n        }), "*");\n      }\n      \n      window.addEventListener(\'wheel\', onWheel, { passive: true });\n      \n      window.addEventListener(\'pagehide\', (event) => {\n        window.removeEventListener(\'wheel\', onWheel);\n      });\n    </script>\n  ')}v=B.c.iB(s)
s=u.y
s===$&&A.d()
r=u.a
p=r.CW
o=r.f
n=r.r
r=r.w?"    body {\n      font-weight: 400;\n      font-size: 14px;\n      font-style: normal;\n    }\n    \n    p {\n      margin: 0px;\n    }\n  ":""
o=o===B.aA?'dir="rtl"':""
n=n!=null?"margin: "+A.e(n)+";":""
u.w='      <!DOCTYPE html>\n      <html>\n      <head>\n      <meta name="viewport" content="width=device-width, initial-scale=1.0">\n      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">\n      <style>\n            @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Regular.ttf") format("truetype");\n      font-weight: 400;\n      font-style: normal;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Medium.ttf") format("truetype");\n      font-weight: 500;\n      font-style: medium;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-SemiBold.ttf") format("truetype");\n      font-weight: 600;\n      font-style: semi-bold;\n    }\n    \n    @font-face {\n      font-family: \'Inter\';\n      src: url("/assets/fonts/Inter/Inter-Bold.ttf") format("truetype");\n      font-weight: 700;\n      font-style: bold;\n    }\n    \n    body {\n      font-family: \'Inter\', sans-serif;\n    }\n  \n        \n        '+r+"\n        \n        .tmail-content {\n          min-height: "+A.e(s)+"px;\n          min-width: "+p+"px;\n          overflow: auto;\n          overflow-wrap: break-word;\n          word-break: break-word;\n        }\n                  .tmail-content::-webkit-scrollbar {\n            display: none;\n          }\n          .tmail-content {\n            -ms-overflow-style: none;  /* IE and Edge */\n            scrollbar-width: none;  /* Firefox */\n          }\n        \n        \n        pre {\n          white-space: pre-wrap;\n        }\n        \n        table {\n          white-space: normal !important;\n        }\n              \n        @media only screen and (max-width: 600px) {\n          table {\n            width: 100% !important;\n          }\n          \n          a {\n            width: -webkit-fill-available !important;\n          }\n        }\n        \n        "+w+"\n      </style>\n      </head>\n      <body "+o+' style = "overflow-x: hidden; '+n+'";>\n      <div class="tmail-content">'+q+"</div>\n      "+v+"\n      </body>\n      </html> \n    "
u.r=A.bK(!0,y.e)},
u(d){var x=this
x.vQ(d)
if(x.a.db)return x.alT()
else return A.fb(new C.cOP(x))},
alT(){var x,w=this,v=null,u=A.J(w).l(0),t=w.e
t===$&&A.d()
A.y(u+"::_buildHtmlElementView: ActualHeight: "+A.e(t),B.h)
t=A.c([],y.u)
u=w.w
if((u==null?v:B.d.aY(u).length!==0)===!0)t.push(A.VR(new C.cOL(w),w.r,y.e))
if(w.x)t.push(D.a2L)
x=new A.cB(B.ah,v,B.a2,B.G,t,v)
w.a.toString
u=w.f
u===$&&A.d()
return new A.b_(u,v,x,v)},
p(){this.w=null
var x=this.z
x===$&&A.d()
x.an(0)
this.aA()},
grz(){return this.a.ay}}
C.atW.prototype={
aq(){this.aI()
if(this.a.ay)this.ux()},
iz(){var x=this.ef$
if(x!=null){x.aP()
x.i2()
this.ef$=null}this.oK()}}
var z=a.updateTypes(["~(q3)"])
C.cOM.prototype={
$0(){var x=this.a
x.e=this.b
x.x=!1},
$S:0}
C.cON.prototype={
$0(){this.a.x=!1},
$S:0}
C.cOO.prototype={
$0(){return this.a.f=this.b},
$S:0}
C.cOP.prototype={
$2(d,e){var x=this.a,w=x.y
w===$&&A.d()
x.y=Math.min(e.d,w)
return x.alT()},
$S:217}
C.cOL.prototype={
$2(d,e){var x,w,v,u,t=null
if(e.b!=null){x=this.a
w=A.dk7(!0,new A.b5(A.e(x.w)+"-"+A.e(x.a.a),y.q),new C.cOK(x),"iframe")
v=x.a.cy
u=x.e
x=x.f
if(v!=null){u===$&&A.d()
x===$&&A.d()
return A.a9(t,w,B.k,t,new A.au(0,1/0,0,v),t,t,u,t,t,t,t,t,x)}else{u===$&&A.d()
x===$&&A.d()
return new A.b_(x,u,w,t)}}else return B.x},
$S:218}
C.cOK.prototype={
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
$S:455};(function aliases(){var x=C.atW.prototype
x.aVX=x.aq})();(function installTearOffs(){var x=a._instance_1u
x(C.ape.prototype,"gbaD","baE",0)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.M1,A.af)
w(C.atW,A.ad)
w(C.ape,C.atW)
v(A.uW,[C.cOM,C.cON,C.cOO])
v(A.uX,[C.cOP,C.cOL])
w(C.cOK,A.ov)
x(C.atW,A.qL)})()
A.Do(b.typeUniverse,JSON.parse('{"M1":{"af":[],"i":[]},"ape":{"ad":["M1"]}}'))
var y={C:A.aq("y_"),x:A.aq("N<f>"),u:A.aq("N<i>"),B:A.aq("q3"),q:A.aq("b5<f>"),f:A.aq("a34<l6>"),e:A.aq("C"),D:A.aq("E")};(function constants(){D.aRa=new A.b_(30,30,B.r1,null)
D.aJh=new A.W(B.cq,D.aRa,null)
D.a2L=new A.dB(B.d3,null,null,D.aJh,null)})()};
((a,b)=>{a[b]=a.current
a.eventLog.push({p:"main.dart.js_8",e:"endPart",h:b})})($__dart_deferred_initializers__,"EJ23JFVdQHQzhxDeW7OEjBEN4pE=");