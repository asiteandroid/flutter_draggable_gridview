library draggable_grid_view;

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/constants/colors.dart';

part 'common/global_variables.dart';

part 'models/draggable_grid_item.dart';

part 'widgets/drag_target_grid.dart';

part 'widgets/empty_item.dart';

part 'widgets/long_press_draggable_grid.dart';

part 'widgets/placeholder_widget.dart';

part 'widgets/press_draggable_grid.dart';

typedef DragCompletion = void Function(List<DraggableGridItem> list, int beforeIndex, int afterIndex);
typedef DragFeedback = Widget Function(List<DraggableGridItem> list, int index);
typedef DragChildWhenDragging = Widget Function(List<DraggableGridItem> list, int index);
typedef DragPlaceHolder = PlaceHolderWidget Function(List<DraggableGridItem> list, int index);
typedef DeleteItem = void Function(List<List<DraggableGridItem>> list, int index, int pageIndex);

class DraggableGridViewBuilder extends StatefulWidget {
  /// [children] will show the widgets in Gridview.builder.
  final List<DraggableGridItem> children;

  /// [isOnlyLongPress] is Accepts 'true' and 'false'
  final bool isOnlyLongPress;

  /// [dragFeedback] you can set this to display the widget when the widget is being dragged.
  final DragFeedback? dragFeedback;

  /// [dragChildWhenDragging] you can set this to display the widget at dragged widget place when the widget is being dragged.
  final DragChildWhenDragging? dragChildWhenDragging;

  /// [dragPlaceHolder] you can set this to display the widget at the drag target when the widget is being dragged.
  final DragPlaceHolder? dragPlaceHolder;

  /// [dragCompletion] you have to set this callback to get the updated list.
  final DragCompletion dragCompletion;

  /// all the below variables for Gridview.builder.
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final SliverGridDelegate gridDelegate;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final DeleteItem? onRemove;
  final Widget? deleteWidget;

  const DraggableGridViewBuilder({
    Key? key,
    required this.gridDelegate,
    required this.children,
    required this.dragCompletion,
    this.isOnlyLongPress = true,
    this.dragFeedback,
    this.dragChildWhenDragging,
    this.dragPlaceHolder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.onRemove,
    this.deleteWidget,
  }) : super(key: key);

  @override
  DraggableGridViewBuilderState createState() => DraggableGridViewBuilderState();
}

class DraggableGridViewBuilderState extends State<DraggableGridViewBuilder> {
  PageController pageController = PageController(keepPage: true);
  final _pageViewKey = GlobalKey();
  bool _isDragging = true;

  @override
  void initState() {
    print("init called");
    super.initState();
    assert(widget.children.isNotEmpty, 'Children must not be empty.');

    /// [orgList] will set when the drag completes.
    _orgList = [...widget.children];
    _isOnlyLongPress = widget.isOnlyLongPress;

    _listSublist.clear();
    _originalSublist.clear();
    for (var i = 0; i < _orgList.length; i += subListLength) {
      _listSublist.add(_orgList.sublist(i, i + subListLength > _orgList.length ? _orgList.length : i + subListLength));
    }
    for (var i = 0; i < _orgList.length; i += subListLength) {
      _originalSublist.add(_orgList.sublist(i, i + subListLength > _orgList.length ? _orgList.length : i + subListLength));
    }
    _activePage = 0;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageController.addListener(() {
        setState(() {
          _activePage = pageController.page!.ceil();
        });
      });
    });
  }

  @override
  void didUpdateWidget(DraggableGridViewBuilder oldWidget) {
    print("Did update widget called ${oldWidget}");
    super.didUpdateWidget(oldWidget);
    assert(widget.children.isNotEmpty, 'Children must not be empty.');

    _orgList = [...widget.children];
    _listSublist.clear();
    _originalSublist.clear();
    for (var i = 0; i < _orgList.length; i += subListLength) {
      _listSublist.add(_orgList.sublist(i, i + subListLength > _orgList.length ? _orgList.length : i + subListLength));
    }
    for (var i = 0; i < _orgList.length; i += subListLength) {
      _originalSublist.add(_orgList.sublist(i, i + subListLength > _orgList.length ? _orgList.length : i + subListLength));
    }
    _isOnlyLongPress = widget.isOnlyLongPress;
    print("_originalSublist $_originalSublist");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
              key: _pageViewKey,
              itemCount: _listSublist.length,
              controller: pageController,
              pageSnapping: true,
              allowImplicitScrolling: false,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, pageIndex) {
                return Listener(
                  onPointerMove: (event) {
                    var renderObject = context.findRenderObject() as RenderBox;
                    var dragOffset = renderObject.localToGlobal(event.localPosition);

                    if (_draggedGridItem != null && _isDragging) {
                      if (dragOffset.dx > MediaQuery.of(context).size.width - 30) {
                        pageController.animateToPage(_activePage + 1, duration: const Duration(milliseconds: 300), curve: Curves.linear);
                        setState(() {
                          _isDragging = false;
                        });

                        Future.delayed(const Duration(milliseconds: 1500), () {
                          setState(() {
                            _isDragging = true;
                          });
                        });
                      } else if (dragOffset.dx < 30) {
                        pageController.animateToPage(_activePage - 1, duration: const Duration(milliseconds: 300), curve: Curves.linear);
                        setState(() {
                          _isDragging = false;
                        });

                        Future.delayed(const Duration(milliseconds: 1500), () {
                          setState(() {
                            _isDragging = true;
                          });
                        });
                      }
                    }
                  },
                  child: GridView.builder(
                    scrollDirection: widget.scrollDirection,
                    reverse: widget.reverse,
                    controller: widget.controller,
                    primary: false,
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: widget.shrinkWrap,
                    padding: widget.padding,
                    addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
                    addRepaintBoundaries: widget.addRepaintBoundaries,
                    addSemanticIndexes: widget.addSemanticIndexes,
                    semanticChildCount: widget.semanticChildCount,
                    dragStartBehavior: widget.dragStartBehavior,
                    keyboardDismissBehavior: widget.keyboardDismissBehavior,
                    restorationId: widget.restorationId,
                    clipBehavior: widget.clipBehavior,
                    gridDelegate: widget.gridDelegate,
                    itemBuilder: (_, index) {
                      return (!_listSublist[pageIndex][index].isDraggable)
                          ? _listSublist[pageIndex][index].child
                          : DragTargetGrid(
                              pageIndex: pageIndex,
                              index: index,
                              onChangeCallback: () => setState(() {}),
                              feedback: widget.dragFeedback?.call(_listSublist[pageIndex], index),
                              childWhenDragging: widget.dragChildWhenDragging?.call(_orgList, index),
                              placeHolder: widget.dragPlaceHolder?.call(_orgList, index),
                              dragCompletion: widget.dragCompletion,
                            );
                    },
                    itemCount: _listSublist[pageIndex].length,
                  ),
                );
              }),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
                _listSublist.length,
                (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: _activePage == index ? Colors.blue : Colors.grey,
                      ),
                    ))),
      ],
    );
  }
}
