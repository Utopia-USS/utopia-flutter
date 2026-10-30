import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

const _fieldCount = 20;

class FormDialogPage extends StatefulWidget {
  const FormDialogPage({super.key});

  @override
  State<FormDialogPage> createState() => _FormDialogPageState();
}

class _FormDialogPageState extends State<FormDialogPage> {
  bool _dismissible = true;
  bool _withOnBackPressed = false;

  VoidCallback? get _onBackPressed => _withOnBackPressed
      ? () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("onBackPressed called")));
          Navigator.of(context).maybePop();
        }
      : null;

  Widget _buildActions() {
    return DialogActions(
      children: [
        ElevatedButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text("Primary")),
        TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text("Secondary")),
      ],
    );
  }

  Future<void> _showRaw() {
    return AdaptiveDialog.show(
      context,
      FormDialog.raw(
        title: const Text("FormDialog.raw"),
        dismissible: _dismissible,
        onBackPressed: _onBackPressed,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(labelText: "Field $index", border: const OutlineInputBorder()),
              ),
            ),
            childCount: _fieldCount,
          ),
        ),
        bottom: _buildActions(),
      ),
      dismissible: _dismissible,
    );
  }

  Future<void> _showSimple() {
    return AdaptiveDialog.show(
      context,
      FormDialog.simple(
        title: const Text("FormDialog.simple"),
        dismissible: _dismissible,
        onBackPressed: _onBackPressed,
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _fieldCount; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(labelText: "Field $i", border: const OutlineInputBorder()),
                  ),
                ),
            ],
          ),
        ),
        bottom: _buildActions(),
      ),
      dismissible: _dismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FormDialog")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Dismissible"),
            value: _dismissible,
            onChanged: (value) => setState(() => _dismissible = value),
          ),
          SwitchListTile(
            title: const Text("Supply onBackPressed (back button also shows up in card mode)"),
            value: _withOnBackPressed,
            onChanged: (value) => setState(() => _withOnBackPressed = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _showRaw, child: const Text("Show FormDialog.raw (SliverList body)")),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _showSimple, child: const Text("Show FormDialog.simple (Column body)")),
        ],
      ),
    );
  }
}
