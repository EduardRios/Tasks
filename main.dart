import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, isHovered, isDragging) {
              double scale = isDragging ? 1.5 : (isHovered ? 1.2 : 1.0);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(scale),
                constraints: const BoxConstraints(
                    minWidth: 48, minHeight: 48, maxHeight: 48),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T, bool isHovered, bool isDragging) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  // Index being dragged
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return DragTarget<T>(
            onWillAcceptWithDetails: (details) {
              setState(() {
                _draggingIndex = index;
              });
              return true;
            },
            onAcceptWithDetails: (details) {
              setState(() {
                final oldIndex = _items.indexOf(details.data);
                _items.removeAt(oldIndex);
                _items.insert(index, details.data);
                _draggingIndex = null;
              });
            },
            onLeave: (_) {
              setState(() {
                _draggingIndex = null;
              });
            },
            builder: (context, candidateData, rejectedData) {
              final isHovered = _draggingIndex == index;
              return Draggable<T>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: widget.builder(item, false, true),
                ),
                childWhenDragging: const SizedBox.shrink(),
                onDragStarted: () {
                  setState(() {
                    _draggingIndex = index;
                  });
                },
                onDragEnd: (_) {
                  setState(() {
                    _draggingIndex = null;
                  });
                },
                child: widget.builder(item, isHovered, false),
              );
            },
          );
        }),
      ),
    );
  }
}
