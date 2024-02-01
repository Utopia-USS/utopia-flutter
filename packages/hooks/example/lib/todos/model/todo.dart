import 'package:uuid/v4.dart';

typedef TodoId = String;

class Todo {
  final TodoId id;
  final String title;

  const Todo({required this.id, required this.title});

  static String randomId() => const UuidV4().generate();
}
