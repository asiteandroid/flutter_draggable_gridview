part of draggable_grid_view;

/// This class helps to manage widget and dragging enable/disable.
/// [child] will show the widgets in Gridview.builder.
/// [isDraggable] is boolean, you want to allow dragging then set it true or else false.
class DraggableGridItem {
  DraggableGridItem(
      {required this.child, this.isDraggable = true, this.dragCallback, this.dragData});

  final bool isDraggable;
  final Widget child;
  final Object? dragData;
  final Function(BuildContext context, bool isDragging)? dragCallback;
}
