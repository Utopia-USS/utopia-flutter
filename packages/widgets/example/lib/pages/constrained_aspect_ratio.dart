import 'dart:math';

import 'package:flutter/material.dart';
import 'package:utopia_widgets/utopia_widgets.dart';

class ConstrainedAspectRatioPage extends StatefulWidget {
  const ConstrainedAspectRatioPage({super.key});

  @override
  State<ConstrainedAspectRatioPage> createState() => _ConstrainedAspectRatioPageState();
}

class _ConstrainedAspectRatioPageState extends State<ConstrainedAspectRatioPage> {
  double _min = 0, _max = 1;
  bool _center = false;
  bool _tight = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 300, child: _buildControls()),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        _buildSlider(
          "Min",
          _min,
          (value) => setState(() {
            _min = value;
            _max = max(_min, _max);
          }),
        ),
        _buildSlider(
          "Max",
          _max,
          (value) => setState(() {
            _max = value;
            _min = min(_min, _max);
          }),
        ),
        CheckboxListTile(
          title: const Text("Center"),
          value: _center,
          onChanged: (value) => setState(() => _center = value!),
        ),
        CheckboxListTile(
          title: const Text("Tight"),
          value: _tight,
          onChanged: (value) => setState(() => _tight = value!),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: _tight ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: _tight ? FlexFit.tight : FlexFit.loose,
          child: ConstrainedAspectRatio(
            min: _toRatio(_min),
            max: _toRatio(_max),
            alignment: _center ? Alignment.center : null,
            child: const ColoredBox(color: Colors.red),
          ),
        ),
        Container(width: double.infinity, height: 100, color: Colors.blue),
      ],
    );
  }

  Widget _buildSlider(String label, double value, void Function(double) onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("$label: ${_toRatio(value)}"),
        Slider(value: value, onChanged: onChanged),
      ],
    );
  }

  double _toRatio(double value) => tan(pi / 2 * value);
}
