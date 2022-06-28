# 7. Fix show Dropdown can't not over overlayUI (#685)

Date: 2022-06-29

## Status

- Issue: DropDownButton menu shows behind Overlay

## Context

- Root cause: Add package flutter_portal to fix this issue

## Decision

- When add Dropdown button to overlayUI, it can't lying above overlayUI.

## Consequences

- The app Navigator has a list of routes (_history) and each route has its list of OverlayEntry's.
When you push a new route using Navigator.push() you are inserting the route overlays above the overlays of the last route.
So, when you add an independent Overlay with just Overlay.of(context).insert(myOverlay);
it will always be above any route/overlay managed by the app Navigator (if what you receive from the of() method is the Navigator Overlay).
