import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:utopia_hooks_example/firebase_options.dart';
import 'package:utopia_hooks_example/search/firebase/search/search_page.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SearchFirebaseApp());
}

class SearchFirebaseApp extends StatelessWidget {
  const SearchFirebaseApp();

  @override
  Widget build(BuildContext context) => const MaterialApp(home: SearchPage());
}
