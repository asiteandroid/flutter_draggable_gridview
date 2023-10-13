part of draggable_grid_view;

class DragTargetGrid extends StatefulWidget {
  final int pageIndex;
  final int index;
  final VoidCallback? onChangeCallback;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final PlaceHolderWidget? placeHolder;
  final DragCompletion? dragCompletion;

  const DragTargetGrid({Key? key, required this.pageIndex, required this.index, required this.onChangeCallback, this.feedback, this.childWhenDragging, this.placeHolder, required this.dragCompletion}) : super(key: key);

  @override
  DragTargetGridState createState() => DragTargetGridState();
}

class DragTargetGridState extends State<DragTargetGrid> {
  static bool _draggedIndexRemoved = false;
  static int _lastIndex = -1;
  static int _draggedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      /// When drag is completes and other item index is ready to accept it.
      onAccept: (data) => setState(() {
        _onDragComplete(widget.index);
      }),
      onLeave: (details) {},

      /// Drag is acceptable in this index else this place.
      onWillAccept: (details) => true,
      onMove: (details) {
        if (_originPageIndex == -1) {
          _originPageIndex = widget.pageIndex;
          _originIndex = int.parse(details.data.toString());
        }
        _listSublist[widget.pageIndex][widget.index].dragCallback?.call(context, true);

        /// Update state when item is moving.
        setState(() {
          _setDragStartedData(details, widget.index);
          if (_originPageIndex == widget.pageIndex) {
            _checkIndexesAreDifferent(details, widget.index);
          } else {
            _checkPageIndexesAreDifferent(details, widget.index);
          }
          widget.onChangeCallback?.call();
        });
      },
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
        /// [_isOnlyLongPress] is true then set the 'LongPressDraggableGridView' class or else set 'PressDraggableGridView' class.
        ///
        return (_isOnlyLongPress)
            ? LongPressDraggableGridView(
                pageIndex: widget.pageIndex,
                index: widget.index,
                feedback: widget.feedback,
                childWhenDragging: widget.childWhenDragging,
                onDragCancelled: () {
                  _onDragCancel(widget.pageIndex);
                },
              )
            : PressDraggableGridView(
                pageIndex: widget.pageIndex,
                index: widget.index,
                feedback: widget.feedback,
                childWhenDragging: widget.childWhenDragging,
                onDragCancelled: () => _onDragComplete(_lastIndex),
              );
      },
    );
  }

  /// Set drag data when dragging start.
  void _setDragStartedData(DragTargetDetails details, int index) {
    if (_dragStarted) {
      _dragStarted = false;
      _draggedIndexRemoved = false;
      _draggedIndex = details.data;
      _draggedGridItem = DraggableGridItem(child: widget.placeHolder ?? const EmptyItem(), isDraggable: true, dragData: null);
      _lastIndex = _draggedIndex;
    }
  }

  /// When [_draggedIndex] and [_lastIndex] both are different that means item is dragged and travelling to other place.
  void _checkIndexesAreDifferent(DragTargetDetails details, int index) {
    /// Here, check [_draggedIndex] is != -1.
    /// And also check index is not equal to _lastIndex. Means if both will true then skip it. else do some operations.
    if (_draggedIndex != -1 && index != _lastIndex) {
      _listSublist[widget.pageIndex].removeWhere((element) {
        return (widget.placeHolder != null) ? element.child is PlaceHolderWidget : element.child is EmptyItem;
      });

      /// store _lastIndex as index.
      /// Means draggedIndex is 6 and dragged child is at index 4 then set _lastIndex to 4.
      _lastIndex = index;

      /// Here, we are checking _draggedIndex is greater than _lastIndex.
      /// For ex:
      /// If _draggedIndex is 6 and _lastIndex = 4 then _draggedChild will be 5.
      if (_draggedIndex > _lastIndex) {
        _draggedGridItem = _originalSublist[widget.pageIndex][_draggedIndex - 1];
      } else {
        int newIndex = (_draggedIndex + 1 >= _listSublist[widget.pageIndex].length) ? _draggedIndex : _draggedIndex + 1;
        _draggedGridItem = _originalSublist[widget.pageIndex][newIndex];
      }

      /// If dragged index and current index both are same then show place holder widget(if user it overridden). else show EmptyItem class.
      if (_draggedIndex == _lastIndex) {
        _draggedGridItem = DraggableGridItem(child: widget.placeHolder ?? const EmptyItem(), isDraggable: true, dragData: null);
      }

      if (!_draggedIndexRemoved) {
        _draggedIndexRemoved = true;
        _listSublist[widget.pageIndex].removeAt(_draggedIndex);
      }
      _listSublist[widget.pageIndex].insert(
        _lastIndex,
        DraggableGridItem(child: widget.placeHolder ?? const EmptyItem(), isDraggable: true, dragData: null),
      );

      setState(() {
        isGridInternalUpdate = true;
      });
    }
  }

  void _checkPageIndexesAreDifferent(DragTargetDetails details, int index) {
    /// Here, check [_draggedIndex] is != -1.
    /// And also check index is not equal to _lastIndex. Means if both will true then skip it. else do some operations.
    if ((_draggedIndex != -1) && !replacePlaceHolder
        //&&
        //(_listSublist[widget.pageIndex].length>= _lastIndex && _listSublist[widget.pageIndex][index] !=_listSublist[widget.pageIndex][_lastIndex])
        ) {
      _listSublist[_originPageIndex].removeWhere((element) {
        return (widget.placeHolder != null) ? element.child is PlaceHolderWidget : element.child is EmptyItem;
      });

      _listSublist[widget.pageIndex].removeWhere((element) {
        return (widget.placeHolder != null) ? element.child is PlaceHolderWidget : element.child is EmptyItem;
      });

      /// store _lastIndex as index.
      /// Means draggedIndex is 6 and dragged child is at index 4 then set _lastIndex to 4.
      _lastIndex = index;

      /// Here, we are checking _draggedIndex is greater than _lastIndex.
      /// For ex:
      /// If _draggedIndex is 6 and _lastIndex = 4 then _draggedChild will be 5.
      if (_originalSublist[widget.pageIndex].length <= _draggedIndex) {
        _draggedGridItem = _originalSublist[widget.pageIndex][_originalSublist[widget.pageIndex].length - 1];
      } else if (_draggedIndex > _lastIndex) {
        _draggedGridItem = _originalSublist[widget.pageIndex][_draggedIndex - 1];
      } else {
        int newIndex = (_draggedIndex + 1 >= _listSublist[widget.pageIndex].length) ? _draggedIndex : _draggedIndex + 1;
        _draggedGridItem = _originalSublist[widget.pageIndex][newIndex];
      }

      /// If dragged index and current index both are same then show place holder widget(if user it overridden). else show EmptyItem class.
      if (_draggedIndex == _lastIndex) {
        _draggedGridItem = DraggableGridItem(child: widget.placeHolder ?? const EmptyItem(), isDraggable: true, dragData: null);
      }

   _listSublist[widget.pageIndex].insert(
        _lastIndex,
        DraggableGridItem(
          child: widget.placeHolder ?? const EmptyItem(),
          isDraggable: true,
        ),
      );

      /*setState(() {
        replacePlaceHolder = true;
      });*/
    }
  }

  /// This method will execute when dragging is completes or else dragging is cancelled.
  void _onDragComplete(int index) {
    bool placeHolderRemove = checkPlaceHolder();
    List<DraggableGridItem> newDragList = [];
    if (_draggedIndex == -1) return;

    if (_originPageIndex == widget.pageIndex) {
      if (placeHolderRemove) _listSublist[widget.pageIndex].insert(index, _originalSublist[widget.pageIndex][_draggedIndex]);

      _originalSublist.clear();
      for (var mainList in _listSublist) {
        List<DraggableGridItem> newList = [];
        for (var element in mainList) {
          newList.add(element);
          newDragList.add(element);
        }
        _originalSublist.add(newList);
      }
    } else {
      if (_listSublist.any((element) => element.any((childElement) => childElement.child is PlaceHolderWidget || childElement.child is EmptyItem))) {
        _listSublist.every((element) {
          element.removeWhere((childElement) {
            return (widget.placeHolder != null) ? childElement.child is PlaceHolderWidget : childElement is EmptyItem;
          });
          return true;
        });
      }

      if (!isGridInternalUpdate) {
        _listSublist[_originPageIndex].removeAt(_originIndex);
      }

      int insertIndex = widget.pageIndex > _originPageIndex ? index + 1 : index;
      if (insertIndex > _listSublist[widget.pageIndex].length) {
        _listSublist[widget.pageIndex].insert(index, _originalSublist[_originPageIndex][_draggedIndex]);
      } else {
        _listSublist[widget.pageIndex].insert(insertIndex, _originalSublist[_originPageIndex][_draggedIndex]);
      }

      List<DraggableGridItem> tempList = [];
      for (var element in _listSublist) {
        for (var value in element) {
          tempList.add(value);
          newDragList.add(value);
        }
      }
      _listSublist.clear();
      _originalSublist.clear();
      for (int i = 0; i < tempList.length; i += subListLength) {
        _listSublist.add(tempList.sublist(i, i + subListLength > tempList.length ? tempList.length : i + subListLength));
        _originalSublist.add(tempList.sublist(i, i + subListLength > tempList.length ? tempList.length : i + subListLength));
      }
    }

    setDefaultValue(newDragList);
  }

  _onDragCancel(int index) {
    List<DraggableGridItem> newDragList = [];
    if (_originPageIndex != _activePage) {
      if (_listSublist.last.length < subListLength) {
        if (!isGridInternalUpdate) {
          _listSublist[_originPageIndex].removeAt(_originIndex);
        }
        _listSublist[_originPageIndex].removeWhere((element) {
          return (widget.placeHolder != null) ? element.child is PlaceHolderWidget : element.child is EmptyItem;
        });
        _listSublist[widget.pageIndex].removeWhere((element) {
          return (widget.placeHolder != null) ? element.child is PlaceHolderWidget : element.child is EmptyItem;
        });

        _listSublist.last.insert(_listSublist.last.length, _originalSublist[widget.pageIndex][_draggedIndex]);

        List<DraggableGridItem> tempList = [];
        for (var element in _listSublist) {
          for (var value in element) {
            tempList.add(value);
            newDragList.add(value);
          }
        }

        _listSublist.clear();
        _originalSublist.clear();
        for (int i = 0; i < tempList.length; i += subListLength) {
          _listSublist.add(tempList.sublist(i, i + subListLength > tempList.length ? tempList.length : i + subListLength));
          _originalSublist.add(tempList.sublist(i, i + subListLength > tempList.length ? tempList.length : i + subListLength));
        }
      }
    } else {
      List<DraggableGridItem> tempList = [];
      for (var element in _originalSublist) {
        for (var value in element) {
          tempList.add(value);
          newDragList.add(value);
        }
      }

      _listSublist.clear();
      _originalSublist.clear();
      for (int i = 0; i < tempList.length; i += subListLength) {
        _listSublist.add(tempList.sublist(i, i + subListLength > tempList.length ? tempList.length : i + subListLength));
        _originalSublist.add(tempList.sublist(i, i + subListLength > tempList.length ? tempList.length : i + subListLength));
      }
    }

    setDefaultValue(newDragList);
  }

  bool checkPlaceHolder() {
    bool isPlaceHolderRemove = false;
    _listSublist.forEach((element) {
      if (element.any((element) => element.child is PlaceHolderWidget || element.child is EmptyItem)) {
        element.removeWhere((childElement) {
          isPlaceHolderRemove = true;
          return (widget.placeHolder != null) ? childElement.child is PlaceHolderWidget : childElement is EmptyItem;
        });
      }
    });
    return isPlaceHolderRemove;
  }

  setDefaultValue(List<DraggableGridItem> list) {
    _dragStarted = false;
    _dragEnded = true;
    widget.onChangeCallback?.call();
    _draggedIndex = subListLength * (_originPageIndex) + _draggedIndex;
    _lastIndex = subListLength * (widget.pageIndex) + _lastIndex;
    widget.dragCompletion?.call(list, _draggedIndex, _lastIndex);
    _draggedIndex = -1;
    replacePlaceHolder = false;
    _lastIndex = -1;
    _originPageIndex = -1;
    _originIndex = -1;
    _draggedGridItem = null;
    isGridInternalUpdate = false;
  }
}
