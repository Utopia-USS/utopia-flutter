import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

void main() {
  group("StatelessTextEditingControllerWrapper", () {
    testWidgets("should initialize with given text", (tester) async {
      final text = MutableValue("test");

      await tester.pumpWidget(_buildWidget(text));

      expect(_findTextField(tester).controller!.text, "test");
    });

    testWidgets("should change field when text changes", (tester) async {
      final text = MutableValue("");

      await tester.pumpWidget(_buildWidget(text));

      text.value = "test";
      await tester.pumpWidget(_buildWidget(text));
      await tester.pumpAndSettle();

      expect(_findTextField(tester).controller!.text, "test");
    });

    testWidgets("should change text when field changes", (tester) async {
      final text = MutableValue("");

      await tester.pumpWidget(_buildWidget(text));

      _findTextField(tester).controller!.text = "test";
      await tester.pumpAndSettle();

      expect(text.value, "test");
    });
  });
}

Widget _buildWidget(MutableValue<String> text) {
  return Localizations(
    locale: const Locale("en"),
    delegates: const [DefaultWidgetsLocalizations.delegate, DefaultMaterialLocalizations.delegate],
    child: Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TextEditingControllerWrapper(
          text: text,
          builder: (controller) => TextField(controller: controller),
        ),
      ),
    ),
  );
}

TextField _findTextField(WidgetTester tester) => tester.widget(find.byType(TextField));
