import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';
import 'package:utopia_widgets_example/util/stateful_item.dart';

class CrossFadeIndexedStackPage extends StatefulWidget {
  const CrossFadeIndexedStackPage({super.key});

  @override
  State<CrossFadeIndexedStackPage> createState() => _CrossFadeIndexedStackPageState();
}

class _CrossFadeIndexedStackPageState extends State<CrossFadeIndexedStackPage> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CrossFadeIndexedStack")),
      body: CrossFadeIndexedStack(
        index: _index,
        duration: const Duration(milliseconds: 500),
        lazy: true,
        children: [
          for (var i = 0; i < 4; i++) StatefulItem(index: i),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: [
          for (var i = 0; i < 4; i++) BottomNavigationBarItem(label: i.toString(), icon: Text(i.toString())),
        ],
      ),
    );
  }
}
