import 'package:flutter/material.dart';

class MainDraggableScrollableSheet extends StatefulWidget {
  final Widget firstChild;
  final Widget secondChild;
  final bool isDestination;
  const MainDraggableScrollableSheet(
      {super.key, required this.firstChild, required this.secondChild, required this.isDestination});

  @override
  State<MainDraggableScrollableSheet> createState() =>
      _MainDraggableScrollableSheetState();
}

class _MainDraggableScrollableSheetState
    extends State<MainDraggableScrollableSheet> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final ValueNotifier<double> _extentNotifier = ValueNotifier<double>(0.232);

  @override
  void initState() {
    super.initState();
    _draggableController.addListener(() {
      _extentNotifier.value = _draggableController.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.232,
      minChildSize: 0.232,
      maxChildSize: 0.94,
      expand: true,
      snap: true,
      snapSizes: const [0.232, 0.94],
      builder: (context, scrollController) {
        return ValueListenableBuilder<double>(
            valueListenable: _extentNotifier,
            builder: (context, extent, child) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  controller: scrollController,
                  padding: EdgeInsets.zero, 

                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedCrossFade(
                      firstChild: widget.firstChild,
                      secondChild: widget.secondChild,
                      crossFadeState: extent < 0.5
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 300),
                    )
                  ],
                ),
              );
            });
      },
    );
  }
}
