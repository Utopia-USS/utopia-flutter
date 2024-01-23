import 'package:utopia_hooks_example/search/clean/model/user.dart';

abstract interface class UserRepository {
  Future<List<User>> getUsers({String? name});
}

final class MockUserRepository implements UserRepository {
  static const users = [User(name: "A"), User(name: "B"), User(name: "C")];

  const MockUserRepository();

  @override
  Future<List<User>> getUsers({String? name}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (name == null) {
      return users;
    } else {
      return users.where((it) => it.name.contains(name)).toList();
    }
  }
}
