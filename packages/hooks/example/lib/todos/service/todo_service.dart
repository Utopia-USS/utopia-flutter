import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utopia_hooks_example/todos/model/todo.dart';

class TodoService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection("todos");

  const TodoService();

  Stream<List<Todo>> createActiveStream() =>
      _collection.where("isCompleted", isEqualTo: false).snapshots().map((it) => it.docs.map(_fromFirestore).toList());

  Future<void> set(Todo todo) => _getReference(todo.id).set({..._toFirestore(todo), "isCompleted": false});

  Future<void> markCompleted(TodoId id) => _getReference(id).update({"isCompleted": true});

  DocumentReference _getReference(TodoId id) => _collection.doc(id);

  Todo _fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) =>
      Todo(id: snapshot.id, title: snapshot.data()!["title"] as String);

  Map<String, dynamic> _toFirestore(Todo todo) => {"title": todo.title};
}
