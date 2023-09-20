part of draggable_grid_view;

class PressDraggableGridView extends StatelessWidget {
  final int pageIndex;
  final int index;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final VoidCallback onDragCancelled;

  const PressDraggableGridView({
    Key? key,
    required this.pageIndex,
    required this.index,
    required this.onDragCancelled,
    this.feedback,
    this.childWhenDragging,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      onDraggableCanceled: (_, __) => onDragCancelled(),
      onDragStarted: () {
        if (_dragEnded) {
          _dragStarted = true;
          _dragEnded = false;
        }
      },
      onDragEnd: (details) {
        _dragEnded = true;
        _dragStarted = false;
      },
      data: index,
      feedback: feedback ?? _listSublist[pageIndex][index].child,
      childWhenDragging:
          childWhenDragging ?? _draggedGridItem?.child ?? _listSublist[pageIndex][index].child,
      child: _listSublist[pageIndex][index].child,
    );
  }
}
