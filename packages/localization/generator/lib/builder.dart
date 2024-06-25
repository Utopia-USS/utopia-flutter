import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:utopia_localization_generator/utopia_localization_generator.dart';

Builder utopiaLocalizationGenerator(BuilderOptions options) =>
    SharedPartBuilder([UtopiaLocalizationGenerator()], 'utopia_localization_generator');
