import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';
import 'package:utopia_widgets_example/util/stateful_item.dart';

class MultiWidgetPage extends StatefulWidget {
  const MultiWidgetPage({super.key});

  @override
  State<MultiWidgetPage> createState() => _MultiWidgetPageState();
}

class _MultiWidgetPageState extends State<MultiWidgetPage> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(onPressed: () => setState(() => _enabled = !_enabled), child: const Text("Toggle")),
          MultiWidget.keyed([
            MapEntry("1", (child) => _buildChild(child, 1)),
            if(_enabled) MapEntry("2", (child) => _buildChild(child, 2)),
            MapEntry("3", (child) => _buildChild(child, 3)),
          ])
        ],
      ),
    );
  }

  Widget _buildChild(Widget child, int index) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        children: [
          StatefulItem(index: index),
          child,
        ],
      ),
    );
  }
}