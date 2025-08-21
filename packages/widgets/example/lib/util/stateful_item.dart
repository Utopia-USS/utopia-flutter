import 'package:flutter/material.dart';

class StatefulItem extends StatefulWidget {
  final int index;

  const StatefulItem({super.key, required this.index});

  @override
  State<StatefulItem> createState() => _StatefulItemState();
}

class _StatefulItemState extends State<StatefulItem> {
  var _count = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: const Duration(seconds: 1), content: Text("Initialized item ${widget.index}")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(onPressed: () => setState(() => _count++), child: Text(_count.toString())),
    );
  }
}
