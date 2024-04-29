import 'package:flutter/material.dart';
import 'package:utopia_widgets_example/pages/constrained_aspect_ratio.dart';
import 'package:utopia_widgets_example/pages/cross_fade_indexed_stack.dart';
import 'package:utopia_widgets_example/pages/form_layout.dart';
import 'package:utopia_widgets_example/pages/multi_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Utopia widgets example")),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final page in _pageMap.entries)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => page.value)),
                  child: Text(page.key),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final _pageMap = <String, Widget>{
  "FormLayout": const FormLayoutPage(),
  "CrossFadeIndexedStack": const CrossFadeIndexedStackPage(),
  "MultiWidget": const MultiWidgetPage(),
  "ConstrainedAspectRatio": const ConstrainedAspectRatioPage(),
};
