import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class UnfocusOnTapPage extends StatefulWidget {
  const UnfocusOnTapPage({super.key});

  @override
  State<UnfocusOnTapPage> createState() => _UnfocusOnTapPageState();
}

class _UnfocusOnTapPageState extends State<UnfocusOnTapPage> {
  final _firstFocus = FocusNode();
  final _secondFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstFocus.addListener(_onFocusChange);
    _secondFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _firstFocus.dispose();
    _secondFocus.dispose();
    super.dispose();
  }

  String get _focusedLabel {
    if (_firstFocus.hasFocus) return "First field";
    if (_secondFocus.hasFocus) return "Second field";
    return "Nothing (tap a field to focus it, tap empty space to unfocus)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UnfocusOnTap")),
      body: UnfocusOnTap(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Focused: $_focusedLabel", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                focusNode: _firstFocus,
                decoration: const InputDecoration(labelText: "First field", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                focusNode: _secondFocus,
                decoration: const InputDecoration(labelText: "Second field", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              const Expanded(child: Center(child: Text("Tap this empty space to dismiss the keyboard / unfocus"))),
            ],
          ),
        ),
      ),
    );
  }
}
