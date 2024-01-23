import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/search/clean/repository/user_repository.dart';
import 'package:utopia_hooks_example/search/clean/search/search_page.dart';

void main() async => runApp(const SearchCleanApp());

class SearchCleanApp extends StatelessWidget {
  static const UserRepository _userRepository = MockUserRepository();

  const SearchCleanApp();

  @override
  Widget build(BuildContext context) {
    return const ValueProvider(
      _userRepository,
      child: MaterialApp(home: SearchPage()),
    );
  }
}
