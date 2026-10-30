import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

enum _TransformKind { unboundedWidth, doubleMaxWidth }

class OverflowTransformBoxPage extends StatefulWidget {
  const OverflowTransformBoxPage({super.key});

  @override
  State<OverflowTransformBoxPage> createState() => _OverflowTransformBoxPageState();
}

class _OverflowTransformBoxPageState extends State<OverflowTransformBoxPage> {
  static const _alignments = [Alignment.centerLeft, Alignment.center, Alignment.centerRight];

  _TransformKind _kind = _TransformKind.doubleMaxWidth;
  Alignment _alignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OverflowTransformBox")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final kind in _TransformKind.values)
                  ChoiceChip(
                    label: Text(kind == _TransformKind.unboundedWidth ? "Unbound width" : "Double maxWidth"),
                    selected: _kind == kind,
                    onSelected: (_) => setState(() => _kind = kind),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final alignment in _alignments)
                  ChoiceChip(
                    label: Text(
                      alignment == Alignment.centerLeft
                          ? "Left"
                          : alignment == Alignment.center
                          ? "Center"
                          : "Right",
                    ),
                    selected: _alignment == alignment,
                    onSelected: (_) => setState(() => _alignment = alignment),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: ClipRect(
                child: OverflowTransformBox(
                  alignment: _alignment,
                  transform: _kind == _TransformKind.unboundedWidth
                      ? (constraints) => constraints.copyWith(maxWidth: double.infinity)
                      : (constraints) => constraints.copyWith(maxWidth: constraints.maxWidth * 2),
                  child: Container(
                    width: 500,
                    height: 100,
                    color: Colors.teal.shade100,
                    alignment: Alignment.center,
                    child: const Text("500 wide child\n(overflows the 200x150 parent)", textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
