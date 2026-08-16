import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class AdaptiveDialogPage extends StatefulWidget {
  const AdaptiveDialogPage({super.key});

  @override
  State<AdaptiveDialogPage> createState() => _AdaptiveDialogPageState();
}

class _AdaptiveDialogPageState extends State<AdaptiveDialogPage> {
  bool _dismissible = true;
  bool _blur = false;

  Future<void> _show() {
    return AdaptiveDialog.show(
      context,
      AdaptiveDialog(
        builder: (context, isFullscreen) =>
            _DialogBody(isFullscreen: isFullscreen, onClose: () => Navigator.of(context).maybePop()),
      ),
      dismissible: _dismissible,
      barrierBlur: _blur ? 6 : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AdaptiveDialog")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Dismissible (tap the barrier to close)"),
            value: _dismissible,
            onChanged: (value) => setState(() => _dismissible = value),
          ),
          SwitchListTile(
            title: const Text("Blur barrier (sigma 6 instead of 0)"),
            value: _blur,
            onChanged: (value) => setState(() => _blur = value),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _show, child: const Text("Show via AdaptiveDialog.show")),
          const SizedBox(height: 24),
          const Text(
            "Same widget, embedded directly below (no route, no barrier): the breakpoint is measured "
            "against the incoming constraints, not the screen, so the narrow box stays fullscreen-mode "
            "even though the screen itself is wide.",
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _EmbeddedDemo(width: 300, height: 220, label: "Width 300 (narrow)"),
              _EmbeddedDemo(width: 700, height: 220, label: "Width 700 (wide)"),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmbeddedDemo extends StatelessWidget {
  final double width;
  final double height;
  final String label;

  const _EmbeddedDemo({required this.width, required this.height, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: AdaptiveDialog(builder: (context, isFullscreen) => _DialogBody(isFullscreen: isFullscreen)),
          ),
        ),
      ],
    );
  }
}

class _DialogBody extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback? onClose;

  const _DialogBody({required this.isFullscreen, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("isFullscreen: $isFullscreen", style: Theme.of(context).textTheme.titleMedium),
            if (onClose != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onClose, child: const Text("Close")),
            ],
          ],
        ),
      ),
    );
  }
}
