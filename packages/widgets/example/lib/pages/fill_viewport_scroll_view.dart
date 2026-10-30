import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class FillViewportScrollViewPage extends StatefulWidget {
  const FillViewportScrollViewPage({super.key});

  @override
  State<FillViewportScrollViewPage> createState() => _FillViewportScrollViewPageState();
}

class _FillViewportScrollViewPageState extends State<FillViewportScrollViewPage> {
  bool _large = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FillViewportScrollView")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () => setState(() => _large = !_large),
              child: Text(
                _large
                    ? "Switch to small child (stretched to fill the viewport)"
                    : "Switch to large child (scrolls normally)",
              ),
            ),
          ),
          Expanded(
            child: FillViewportScrollView(
              child: _large
                  ? Column(
                      children: [
                        for (int i = 0; i < 20; i++)
                          Container(
                            height: 60,
                            color: i.isEven ? Colors.indigo.shade100 : Colors.indigo.shade200,
                            alignment: Alignment.center,
                            child: Text("Item $i"),
                          ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 60,
                          color: Colors.orange.shade100,
                          alignment: Alignment.center,
                          child: const Text("Header (fixed height)"),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.green.shade100,
                            alignment: Alignment.center,
                            child: const Text(
                              "Expanded fills the remaining viewport height\n"
                              "(would fail inside a plain SingleChildScrollView)",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          color: Colors.orange.shade100,
                          alignment: Alignment.center,
                          child: const Text("Footer (fixed height)"),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
