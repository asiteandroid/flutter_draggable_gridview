import 'dart:developer';

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
  List<DraggableGridItem> _listOfDraggableGridItem = [];
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                    onTap: () {
                      setState(() {
                        enableEditMode = !enableEditMode;
                      });
                    },
                    child: const Text("Edit", style: TextStyle(fontSize: 24,color: Colors.blue))),
              ),
            ),
            Expanded(
              child: DraggableGridViewBuilder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTablet && MediaQuery.of(context).orientation == Orientation.landscape ? 5 : 3, childAspectRatio: isTablet && MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * .25 / (MediaQuery.of(context).size.width / 5) : MediaQuery.of(context).size.width * .25 / (MediaQuery.of(context).size.height / 8), mainAxisSpacing: 20, crossAxisSpacing: 20),
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

  Widget deleteItem(DraggableGridItem listOfDraggableGridItem) {
    return InkWell(
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

  onRemoveItem(DraggableGridItem item) {
    _listOfDraggableGridItem.remove(item);

    setState(() {});
  }

  PlaceHolderWidget placeHolder(List<DraggableGridItem> list, int index) {
    return PlaceHolderWidget(
      child: InkWell(
        onTap: () {
          print("Place holder index $index");
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
    for (int i = 0; i < 37; i++) {
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
                        Text(i.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // deleteItem(_listOfDraggableGridItem[i])
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