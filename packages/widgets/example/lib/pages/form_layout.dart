import 'package:flutter/material.dart';
import 'package:utopia_widgets/layout/form_layout.dart';

class FormLayoutPage extends StatelessWidget {
  const FormLayoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UtopiaWidgets example'),
      ),
      body: FormLayout.simple(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < 30; i++) Container(color: Colors.red, margin: const EdgeInsets.all(8), height: 50)
          ],
        ),
        bottom: Container(color: Colors.green, margin: const EdgeInsets.all(8), height: 50),
      ),
    );
  }
}