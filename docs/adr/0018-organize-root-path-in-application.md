# 18. Organize root path in application

Date: 2022-10-26

## Status

Accepted

## Context

Root path has differences between different platforms.

## Decision

Reorganized root paths to easily manage and navigate screens within the app:

- `AppRoutes`: Contains screen destination routes that you can navigate across platforms by calling
`Navigator.push` or type `path` in your browser's address bar
- `AppPages`: Contains the views or pages of the corresponding route of each screen in the application. 
When we call `Navigator.push` or type `path` in your browser's address bar, 
the views/pages will be displayed corresponding to the selected route.

## Consequences

- Navigate correctly to the screen when typing `path` in the browser address bar.
- Works well across platforms
