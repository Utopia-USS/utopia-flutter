import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin client over the free https://jsonplaceholder.typicode.com API.
///
/// All demos in this example share this single client. It has no auth and no
/// state — every method is a plain HTTP call returning decoded models. The
/// caching, dedup, retries and background refetching all live in
/// utopia_hooks_query, not here.
class PlaceholderApi {
  PlaceholderApi({http.Client? client}) : _client = client ?? http.Client();

  static const _base = 'https://jsonplaceholder.typicode.com';

  final http.Client _client;

  Future<List<Post>> fetchPosts({int page = 1, int limit = 10}) async {
    final uri = Uri.parse('$_base/posts?_page=$page&_limit=$limit');
    final res = await _client.get(uri);
    _ensureOk(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((it) => Post.fromJson(it as Map<String, dynamic>)).toList();
  }

  Future<Post> fetchPost(int id) async {
    final res = await _client.get(Uri.parse('$_base/posts/$id'));
    _ensureOk(res);
    return Post.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<Post>> fetchPostsByUser(int userId) async {
    final res = await _client.get(Uri.parse('$_base/posts?userId=$userId'));
    _ensureOk(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((it) => Post.fromJson(it as Map<String, dynamic>)).toList();
  }

  Future<Post> createPost({required String title, required String body}) async {
    final res = await _client.post(
      Uri.parse('$_base/posts'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
    );
    _ensureOk(res);
    return Post.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<User>> fetchUsers() async {
    final res = await _client.get(Uri.parse('$_base/users'));
    _ensureOk(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((it) => User.fromJson(it as Map<String, dynamic>)).toList();
  }

  Future<List<Todo>> fetchTodos({int limit = 10}) async {
    final res = await _client.get(Uri.parse('$_base/todos?_limit=$limit'));
    _ensureOk(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((it) => Todo.fromJson(it as Map<String, dynamic>)).toList();
  }

  /// The API echoes the change back but does not persist it — enough to show
  /// the mutation round-trip. Optimistic UI + rollback lives in the demo.
  Future<Todo> updateTodo(Todo todo) async {
    final res = await _client.patch(
      Uri.parse('$_base/todos/${todo.id}'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'completed': todo.completed}),
    );
    _ensureOk(res);
    return todo;
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
    }
  }
}

class Post {
  const Post({required this.id, required this.userId, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int,
        userId: json['userId'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final int id;
  final int userId;
  final String title;
  final String body;
}

class User {
  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );

  final int id;
  final String name;
  final String email;
}

class Todo {
  const Todo({required this.id, required this.title, required this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
      );

  final int id;
  final String title;
  final bool completed;

  Todo copyWith({bool? completed}) =>
      Todo(id: id, title: title, completed: completed ?? this.completed);
}

/// Shared instance for all demos. Reassignable so tests can inject a fake
/// [http.Client] (see `package:http/testing.dart`).
PlaceholderApi api = PlaceholderApi();
