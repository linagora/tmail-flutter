# 43. Fix memory leak with Controller's `dispose()`

Date: 2024-04-05

## Status

- Issues: 
  - [Memory footprint #2533](https://github.com/linagora/tmail-flutter/issues/2533)

## Context

- Majority, if not all, of TMail's `Controller` are created by extending `BaseController`. Everytime a new state arrives, `viewState`, of `BaseController` is assigned with new value. This value is never disposed so its reference lives on even if the `Controller` itself dies that causes memory leak.

## Decision

- A new state with name `UIClosedState` was created for clarification. It extends `BaseUIState` which extends `UIState`.
- `viewState` will be assigned to `UIClosedState()` inside the `dispose()` method of the memory-leaking controller, so the reference to its previous value is destroyed.
- Ideally, this value reasignment of `viewState` should happen inside `BaseController`'s `dispose()`. However, current state of project is not allowed for side effect that can be caused by app wide changes. This can change in the future.
  
## Consequences

- `SingleEmailController` & `ComposerController`'s memory leak problem are resolved.
