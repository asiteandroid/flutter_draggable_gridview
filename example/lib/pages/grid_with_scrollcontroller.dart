import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

class GridWithScrollControllerExample extends StatefulWidget {
  const GridWithScrollControllerExample({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  GridWithScrollControllerExampleState createState() => GridWithScrollControllerExampleState();
}

class GridWithScrollControllerExampleState extends State<GridWithScrollControllerExample> {
  final List<DraggableGridItem> _listOfDraggableGridItem = [];
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  bool isTablet = false;

  bool enableEditMode = false;

  @override
  void initState() {
    _generateImageData();

    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    if (data.size.shortestSide < 550) {
      setState(() {
        isTablet = false;
      });
    } else {
      isTablet = true;
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /*InkWell(
              onTap: (){
                onAddItem();
              },
                child: Text("ADD")),*/
            Expanded(
              child: DraggableGridViewBuilder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTablet && MediaQuery.of(context).orientation == Orientation.landscape ? 5 : 3, childAspectRatio: 1, mainAxisSpacing: 0, crossAxisSpacing: 0),
                children: _listOfDraggableGridItem,
                shrinkWrap: true,
                dragCompletion: onDragAccept,
                isOnlyLongPress: true,
                dragFeedback: feedback,
                dragPlaceHolder: placeHolder
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget deleteItem(int listOfDraggableGridItem) {
    return Material(
      child: InkWell(
        onTap: (){
          onRemoveItem(listOfDraggableGridItem);
        },
        child: Container(
            decoration: const BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
            padding: const EdgeInsets.all(10.0),
            child: const Icon(
              Icons.delete,
              size: 30,
            )),
      ),
    );
  }

  Widget feedback(List<DraggableGridItem> list, int index) {
    return isTablet
        ? SizedBox(
            width: 220,
            height: 220,
            child: list[index].child,
          )
        : SizedBox(
            width: 120,
            height: 120,
            child: list[index].child,
          );
  }

  onAddItem() {
    _listOfDraggableGridItem.add(DraggableGridItem(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/4.jpeg'),
                const Text("new", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        dragData: DragItemDataObject(),
        isDraggable: true,
        dragCallback: (context, isDragging) {
          log('isDragging: $isDragging');
        }));

    setState(() {});
  }

  onRemoveItem(int item) {
    _listOfDraggableGridItem.removeAt(item);

    setState(() {});
  }

  PlaceHolderWidget placeHolder(List<DraggableGridItem> list, int index) {
    return PlaceHolderWidget(
      child: InkWell(
        onTap: () {
          if (kDebugMode) {
            print("Place holder index $index");
          }
        },
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  void onDragAccept(List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
    log('onDragAccept: $beforeIndex $afterIndex');
  }

  void _generateImageData() {
    for (int i = 0; i < 17; i++) {
      _listOfDraggableGridItem.add(
        DraggableGridItem(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: [
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/4.jpeg'),
                        Text(i.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  deleteItem(i)
                ],
              ),
            ),
            dragData: DragItemDataObject(),
            isDraggable: true,
            dragCallback: (context, isDragging) {
              log('isDragging: $isDragging');
            }),
      );
    }
  }
}


class DragItemDataObject{}