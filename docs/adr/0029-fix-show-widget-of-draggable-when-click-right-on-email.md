# 29. Fix show widget of Draggable when click right on email

Date: 2023-05-24

## Status

- Issue: [#1743](https://github.com/linagora/tmail-flutter/issues/1862)

## Context

When user click right on email, the feedback widget of Draggable will show.

## Root cause

The childWhenDragging widget will still be draggable, including the ability to trigger the right-click event. 
This is because the childWhenDragging widget is a part of the draggable behavior and inherits the drag-related properties and behaviors from the Draggable widget.
The Draggable widget allows you to customize the appearance and behavior of the dragged item during the dragging process by providing the feedback and childWhenDragging properties.
The feedback widget is used to display a visual representation of the dragged item, while the childWhenDragging widget is used to replace the original item when it is being dragged.


## Decision

Wrap it with a GestureDetector and handle the right-click event as mentioned in the previous answer. This way, you can have separate behavior for the original item and the item being dragged.

```
    GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapDown: (details) {
        // 1. Use empty callback to disable D&D on mouse right button
        // 2. Call `showMenu` to show context menu
      },
      child: Draggable<List<PresentationEmail>>(
        data: controller.listEmailDrag,
        feedback: _buildFeedBackWidget(context),
        childWhenDragging: _buildEmailItemWhenDragging(context, presentationEmail),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragStarted: () {
          controller.calculateDragValue(presentationEmail);
          controller.onDragMailBox(true);
        },
        onDragEnd: (_) => controller.onDragMailBox(false),
        onDraggableCanceled: (_,__) => controller.onDragMailBox(false),
        child: _buildEmailItemNotDraggable(context, presentationEmail)
      ),
    );
```
## Consequences

- Do not show the move dialog at all when I right click
