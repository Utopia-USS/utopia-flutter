import 'package:flutter/material.dart';
import 'package:utopia_widgets_example/pages/adaptive_dialog.dart';
import 'package:utopia_widgets_example/pages/collapsible.dart';
import 'package:utopia_widgets_example/pages/constrained_aspect_ratio.dart';
import 'package:utopia_widgets_example/pages/cross_fade_indexed_stack.dart';
import 'package:utopia_widgets_example/pages/dialog_actions.dart';
import 'package:utopia_widgets_example/pages/fill_viewport_scroll_view.dart';
import 'package:utopia_widgets_example/pages/form_dialog.dart';
import 'package:utopia_widgets_example/pages/form_layout.dart';
import 'package:utopia_widgets_example/pages/loader_wrapper_layout.dart';
import 'package:utopia_widgets_example/pages/multi_widget.dart';
import 'package:utopia_widgets_example/pages/overflow_transform_box.dart';
import 'package:utopia_widgets_example/pages/top_bottom_layout.dart';
import 'package:utopia_widgets_example/pages/unfocus_on_tap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  "TopBottomLayout": const TopBottomLayoutPage(),
  "Collapsible": const CollapsiblePage(),
  "OverflowTransformBox": const OverflowTransformBoxPage(),
  "LoaderWrapperLayout": const LoaderWrapperLayoutPage(),
  "FillViewportScrollView": const FillViewportScrollViewPage(),
  "UnfocusOnTap": const UnfocusOnTapPage(),
  "AdaptiveDialog": const AdaptiveDialogPage(),
  "FormDialog": const FormDialogPage(),
  "DialogActions": const DialogActionsPage(),
};
