import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class CollapsiblePage extends StatefulWidget {
  const CollapsiblePage({super.key});

  @override
  State<CollapsiblePage> createState() => _CollapsiblePageState();
}

class _CollapsiblePageState extends State<CollapsiblePage> {
  bool _verticalExpanded = true;
  bool _horizontalExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Collapsible")),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _verticalExpanded = !_verticalExpanded),
                child: Text(_verticalExpanded ? "Collapse vertical" : "Expand vertical"),
              ),
              const SizedBox(height: 16),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                child: Collapsible.vertical(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutBack,
                  isExpanded: _verticalExpanded,
                  child: Container(
                    width: 160,
                    height: 160,
                    color: Colors.orange.shade100,
                    alignment: Alignment.center,
                    child: const Text("Vertical\ncontent", textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _horizontalExpanded = !_horizontalExpanded),
                child: Text(_horizontalExpanded ? "Collapse horizontal" : "Expand horizontal"),
              ),
              const SizedBox(height: 16),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                child: Collapsible.horizontal(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutBack,
                  isExpanded: _horizontalExpanded,
                  child: Container(
                    width: 160,
                    height: 160,
                    color: Colors.purple.shade100,
                    alignment: Alignment.center,
                    child: const Text("Horizontal\ncontent", textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
