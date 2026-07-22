import 'dart:convert';

/// JavaScript snippets injected into the composer's HTML editor to support
/// Workplace Drive attachment cards (`.tmail-file-link-card` elements).
class WorkplaceScripts {
  /// Installs a delete affordance for `.tmail-file-link-card` elements, appended
  /// to `document.body` — never a descendant of `.note-editable` — so it's
  /// excluded from the composer's HTML content by construction.
  ///
  /// Hover-capable devices get a single reusable button that follows the
  /// hovered card. Touch devices keep a button persistently visible over
  /// every card. Position is re-synced on scroll/resize/card-mutation via a
  /// single debounced `requestAnimationFrame`, not a perpetual per-frame
  /// loop, to avoid forcing a layout reflow every frame while idle.
  static ({String name, String script}) registerDriveCardDeleteOverlay(
    String removeLabel, {
    bool isWebPlatform = false,
  }) => (
    script:
        '''
      (function() {
        try {
          if (window.__tmailDriveCardDeleteOverlayInstalled) return;
          window.__tmailDriveCardDeleteOverlayInstalled = true;

          const isWebPlatform = $isWebPlatform;
          const removeLabel = ${jsonEncode(removeLabel)};
          const cardSelector = '.tmail-file-link-card';
          const isTouch = window.matchMedia &&
            window.matchMedia('(hover: none), (pointer: coarse)').matches;
          const cleanupFns = [];

          function trackListener(target, type, handler, options) {
            target.addEventListener(type, handler, options);
            cleanupFns.push(function() {
              target.removeEventListener(type, handler, options);
            });
          }

          window.__tmailDriveCardDeleteOverlayCleanup = function() {
            cleanupFns.forEach(function(fn) {
              try { fn(); } catch (e) {}
            });
            window.__tmailDriveCardDeleteOverlayInstalled = false;
            window.__tmailDriveCardDeleteOverlayCleanup = null;
          };

          function syncEditorContent() {
            try {
              const editable = document.querySelector('.note-editable');
              if (editable) {
                editable.dispatchEvent(new Event('input', { bubbles: true, cancelable: true }));
              }
            } catch (e) {}
          }

          function notifyCardDeleted() {
            if (isWebPlatform) {
              // A synthetic `input` event would route through Summernote's
              // `toDart: onChangeContent` message, which html_editor_enhanced
              // reacts to with `Scrollable.ensureVisible()` on the whole
              // editor — that's the scroll-to-top bug. Sync content directly
              // via this app-owned message instead. Mobile's WebView has no
              // such side effect, so it keeps the normal pipeline below.
              try {
                window.parent.postMessage(
                  JSON.stringify({ type: 'toDart: driveCardDeleted' }),
                  '*'
                );
              } catch (e) {}
            } else {
              syncEditorContent();
            }
          }

          function refocusEditable() {
            // Restores focus so the existing onFocus->hideMenu chain still
            // dismisses any open popup menu, same as clicking editor text.
            // `preventScroll: true` avoids the browser's default "scroll the
            // iframe into view in the outer page" behavior on focus.
            try {
              const editable = document.querySelector('.note-editable');
              if (editable && document.activeElement !== editable) {
                editable.focus({ preventScroll: true });
              }
            } catch (e) {}
          }

          function blockFocusScrollOnMousedown(event) {
            // Overlay buttons are `tabindex="0"` divs, so mousedown natively
            // focuses them before `click` runs, triggering the same iframe
            // scroll-into-view jump — and can even shift the layout enough
            // to make the click miss the button. Suppress it; refocusEditable
            // handles focus explicitly afterward with preventScroll.
            try {
              event.preventDefault();
            } catch (e) {}
          }

          function removeCardOnActivate(event, card, onOverlayCleanup) {
            try {
              event.preventDefault();
              event.stopPropagation();
              if (card) card.remove();
              onOverlayCleanup();
              notifyCardDeleted();
              refocusEditable();
            } catch (e) {}
          }

          function makeOverlay() {
            try {
              const overlay = document.createElement('div');
              overlay.setAttribute('role', 'button');
              overlay.setAttribute('tabindex', '0');
              overlay.setAttribute('aria-label', removeLabel);
              overlay.title = removeLabel;
              overlay.textContent = '✕';
              overlay.style.cssText = 'position:fixed;display:none;align-items:center;' +
                'justify-content:center;width:36px;height:36px;color:rgba(0,0,0,0.55);' +
                'font-size:24px;cursor:pointer;z-index:2147483647;';
              document.body.appendChild(overlay);
              return overlay;
            } catch (e) {
              return null;
            }
          }

          function positionOverlay(card, overlay) {
            try {
              const rect = card.getBoundingClientRect();
              if (rect.width === 0 && rect.height === 0) {
                overlay.style.display = 'none';
                return;
              }
              overlay.style.top = (rect.top + 6) + 'px';
              overlay.style.left = (rect.right - 42) + 'px';
              overlay.style.display = 'flex';
            } catch (e) {}
          }

          if (isTouch) {
            const overlaysByCard = new Map();

            function bindDelete(card, overlay) {
              try {
                function onActivate(event) {
                  removeCardOnActivate(event, card, function() {
                    overlay.remove();
                    overlaysByCard.delete(card);
                  });
                }
                overlay.addEventListener('mousedown', blockFocusScrollOnMousedown);
                overlay.addEventListener('click', onActivate);
                overlay.addEventListener('keydown', function(event) {
                  if (event.key === 'Enter' || event.key === ' ') onActivate(event);
                });
              } catch (e) {}
            }

            let rafId = null;
            function scheduleReposition() {
              if (rafId !== null) return;
              rafId = requestAnimationFrame(function() {
                rafId = null;
                overlaysByCard.forEach(function(overlay, card) {
                  positionOverlay(card, overlay);
                });
              });
            }
            cleanupFns.push(function() {
              if (rafId !== null) cancelAnimationFrame(rafId);
            });

            function syncTouchOverlays() {
              try {
                const seen = new Set();
                document.querySelectorAll(cardSelector).forEach(function(card) {
                  seen.add(card);
                  if (!overlaysByCard.has(card)) {
                    const overlay = makeOverlay();
                    if (!overlay) return;
                    bindDelete(card, overlay);
                    overlaysByCard.set(card, overlay);
                  }
                });
                overlaysByCard.forEach(function(overlay, card) {
                  if (!seen.has(card)) {
                    overlay.remove();
                    overlaysByCard.delete(card);
                  }
                });
                scheduleReposition();
              } catch (e) {}
            }

            syncTouchOverlays();

            try {
              const editableRoot = document.querySelector('.note-editable') || document.body;
              const observer = new MutationObserver(syncTouchOverlays);
              observer.observe(editableRoot, {
                childList: true,
                subtree: true,
              });
              cleanupFns.push(function() { observer.disconnect(); });
            } catch (e) {}

            cleanupFns.push(function() {
              overlaysByCard.forEach(function(overlay) { overlay.remove(); });
              overlaysByCard.clear();
            });

            trackListener(window, 'scroll', scheduleReposition, true);
            trackListener(window, 'resize', scheduleReposition, false);
          } else {
            let activeCard = null;
            const overlay = makeOverlay();

            let rafId = null;
            function scheduleReposition() {
              if (rafId !== null) return;
              rafId = requestAnimationFrame(function() {
                rafId = null;
                if (overlay && activeCard && document.body.contains(activeCard)) {
                  positionOverlay(activeCard, overlay);
                } else {
                  activeCard = null;
                  if (overlay) overlay.style.display = 'none';
                }
              });
            }
            cleanupFns.push(function() {
              if (rafId !== null) cancelAnimationFrame(rafId);
            });
            if (overlay) {
              cleanupFns.push(function() { overlay.remove(); });
            }

            function onActivate(event) {
              removeCardOnActivate(event, activeCard, function() {
                activeCard = null;
                if (overlay) overlay.style.display = 'none';
              });
            }
            if (overlay) {
              overlay.addEventListener('mousedown', blockFocusScrollOnMousedown);
              overlay.addEventListener('click', onActivate);
              overlay.addEventListener('keydown', function(event) {
                if (event.key === 'Enter' || event.key === ' ') onActivate(event);
              });
            }

            trackListener(document, 'mouseover', function(event) {
              try {
                const card = event.target.closest && event.target.closest(cardSelector);
                if (card) {
                  activeCard = card;
                  scheduleReposition();
                }
              } catch (e) {}
            }, false);
            trackListener(document, 'mouseout', function(event) {
              try {
                if (!activeCard) return;
                const related = event.relatedTarget;
                const movingToActiveCard = related && activeCard.contains(related);
                const movingToOverlay = related && overlay && overlay.contains(related);
                if (!movingToActiveCard && !movingToOverlay) {
                  activeCard = null;
                  if (overlay) overlay.style.display = 'none';
                }
              } catch (e) {}
            }, false);

            trackListener(window, 'scroll', scheduleReposition, true);
            trackListener(window, 'resize', scheduleReposition, false);
          }
        } catch (e) {}
      })();''',
    name: 'registerDriveCardDeleteOverlay',
  );

  /// Tears down everything installed by [registerDriveCardDeleteOverlay]:
  /// cancels the pending animation frame, disconnects the `MutationObserver`,
  /// removes the scroll/resize/mouse listeners, and removes overlay DOM
  /// nodes. Mirrors the `registerDropListener`/`unregisterDropListener`
  /// pairing already used elsewhere for injected editor scripts.
  static const unregisterDriveCardDeleteOverlay = (
    script: '''
      if (window.__tmailDriveCardDeleteOverlayCleanup) {
        window.__tmailDriveCardDeleteOverlayCleanup();
      }''',
    name: 'unregisterDriveCardDeleteOverlay',
  );
}
