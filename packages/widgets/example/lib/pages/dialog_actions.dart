import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class DialogActionsPage extends StatelessWidget {
  const DialogActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DialogActions")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            _buildDemo(context, width: 300, label: "Width 300 (narrow -> Column, Primary ends up at the bottom)"),
            _buildDemo(context, width: 700, label: "Width 700 (wide -> Row, Primary ends up at the right)"),
          ],
        ),
      ),
    );
  }

  Widget _buildDemo(BuildContext context, {required double width, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: width, child: Text(label)),
        const SizedBox(height: 8),
        Container(
          width: width,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: DialogActions(
            children: [
              ElevatedButton(onPressed: () => _tap(context, "Primary"), child: const Text("Primary")),
              OutlinedButton(onPressed: () => _tap(context, "Secondary"), child: const Text("Secondary")),
            ],
          ),
        ),
      ],
    );
  }

  void _tap(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$label tapped")));
  }
}
