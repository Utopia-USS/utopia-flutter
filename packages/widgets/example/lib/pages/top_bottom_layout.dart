import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class TopBottomLayoutPage extends StatefulWidget {
  const TopBottomLayoutPage({super.key});

  @override
  State<TopBottomLayoutPage> createState() => _TopBottomLayoutPageState();
}

class _TopBottomLayoutPageState extends State<TopBottomLayoutPage> {
  bool _tall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TopBottomLayout")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => setState(() => _tall = !_tall),
              child: Text(
                _tall
                    ? "Switch to short top (fits: top and bottom get spread apart)"
                    : "Switch to tall top (overflows: whole thing scrolls, no gap)",
              ),
            ),
          ),
          Expanded(
            child: TopBottomLayout(
              padding: const EdgeInsets.all(16),
              top: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                height: _tall ? 1200 : 150,
                alignment: Alignment.center,
                child: Text(
                  _tall ? "Tall top\n(1200px, overflows the viewport)" : "Short top\n(150px, fits comfortably)",
                  textAlign: TextAlign.center,
                ),
              ),
              bottom: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                height: 80,
                alignment: Alignment.center,
                child: const Text("Bottom"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
