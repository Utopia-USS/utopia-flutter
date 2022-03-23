import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class CrossFadeIndexedStackPage extends StatefulWidget {
  const CrossFadeIndexedStackPage({Key? key}) : super(key: key);

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
          for (var i = 0; i < 4; i++) _Item(index: i),
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

class _Item extends StatefulWidget {
  final int index;

  const _Item({Key? key, required this.index}) : super(key: key);

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  var _count = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Initialized item ${widget.index}"))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(onPressed: () => setState(() => _count++), child: Text(_count.toString())),
    );
  }
}
