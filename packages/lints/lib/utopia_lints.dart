import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class UtopiaLints extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    resolvedUnitResult.libraryElement.visitChildren((element) {
      if(element)
    })
  }
}

class _Visitor extends RecursiveElementVisitor<void> {
  @override
  void visitLocalVariableElement(LocalVariableElement element) {
    super.visitLocalVariableElement(element);
    el
  }
}