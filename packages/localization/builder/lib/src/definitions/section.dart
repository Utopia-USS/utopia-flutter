import 'package:equatable/equatable.dart';
import 'package:recase/recase.dart' as recase;
import 'package:utopia_localization_builder/utopia_localization_builder.dart';

/// A section is a set of labels, grouped together to to make them
/// easier to find.
class Section extends Equatable {
  const Section({
    required this.key,
    required this.labels,
    required this.children,
  });

  /// Merges [value] and [other] into a new [Section] with combined [labels] and merged [children].
  factory Section.merge(Section value, Section other) {
    final labels = <Label>[];
    final children = <Section>[];
    // Merging labels
    if (value.labels.isEmpty) {
      labels.addAll(other.labels);
    } else {
      for (final otherLabel in other.labels) {
        final existingLabel = value.labels.cast<Label?>().firstWhere(
              (x) => x!.key == otherLabel.key,
              orElse: () => null,
            );
        if (existingLabel == null) {
          labels.add(otherLabel);
        } else {
          labels.add(Label.merge(existingLabel, otherLabel));
        }
      }
      final labelsOnlyInValue = value.labels.where(
        (x) => !other.labels.any((o) => o.key == x.key),
      );
      labels.addAll(labelsOnlyInValue);
    }

    // Merging children
    if (value.children.isEmpty) {
      children.addAll(other.children);
    } else {
      for (final otherChild in other.children) {
        final existingChild = value.children.cast<Section?>().firstWhere(
              (x) => x!.key == otherChild.key,
              orElse: () => null,
            );
        if (existingChild == null) {
          children.add(otherChild);
        } else {
          children.add(Section.merge(existingChild, otherChild));
        }
      }
      final childrenOnlyInValue = value.children.where(
        (x) => !other.children.any((o) => o.key == x.key),
      );
      children.addAll(childrenOnlyInValue);
    }

    final result = Section(
      key: value.key,
      labels: labels,
      children: children,
    );

    return result;
  }

  /// A new section with the [Translation] inserted at [path].
  Section withTranslations(
    String path,
    String? condition,
    List<Translation> translations,
  ) {
    final trimmedPath = path.trim();
    assert(trimmedPath.isNotEmpty);
    var pathSplits = trimmedPath.split('.');

    final label = Label(
      key: pathSplits.last,
      cases: [
        Case(
          condition: Condition.parse(condition),
          translations: translations,
        ),
      ],
    );

    pathSplits = pathSplits.take(pathSplits.length - 1).toList();

    if (pathSplits.isEmpty) {
      return Section.merge(
        this,
        Section(
          key: key,
          labels: [label],
          children: [],
        ),
      );
    }

    var child = Section(
      key: pathSplits.last,
      labels: [label],
      children: [],
    );

    pathSplits = pathSplits.take(pathSplits.length - 1).toList();

    while (pathSplits.isNotEmpty) {
      child = Section(
        key: pathSplits.last,
        labels: [],
        children: [child],
      );
      pathSplits = pathSplits.take(pathSplits.length - 1).toList();
    }

    return Section.merge(
      this,
      Section(
        key: key,
        labels: [],
        children: [child],
      ),
    );
  }

  final String key;
  final List<Label> labels;
  final List<Section> children;

  String get normalizedKey => recase.ReCase(key).camelCase;

  bool get hasTemplatedValues {
    if (labels.any((x) => x.templatedValues.isNotEmpty)) {
      return true;
    }
    return children.any((x) => x.hasTemplatedValues);
  }

  List<Label> get allLabels {
    final result = <Label>[];
    result.addAll(labels);
    result.addAll(children.expand((x) => x.allLabels));
    return result;
  }

  @override
  List<Object> get props => [
        key,
        labels,
        children,
      ];
}
