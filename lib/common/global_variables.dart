part of draggable_grid_view;

var _dragStarted = false;
var _dragEnded = true;
var replacePlaceHolder = false;
var isGridInternalUpdate = false;
int _originPageIndex = -1;
int _originIndex = -1;
bool wasAccepted = true;
bool? isDirectionChange = false;
late List<DraggableGridItem> _orgList;
int _activePage = 0;
List<List<DraggableGridItem>> _listSublist = [];
List<List<DraggableGridItem>> _originalSublist = [];
DraggableGridItem? _draggedGridItem;
int subListLength = 15;

/// [isOnlyLongPress] is Accepts 'true' and 'false'
/// If, it is true then only draggable works with long press.
/// and if it is false then it works with simple press.
bool _isOnlyLongPress = true;
int rn = 15;