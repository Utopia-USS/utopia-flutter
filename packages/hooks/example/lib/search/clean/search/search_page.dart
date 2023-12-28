import 'package:flutter/cupertino.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/search/clean/search/state/search_page_state.dart';
import 'package:utopia_hooks_example/search/clean/search/view/search_page_view.dart';

class SearchPage extends StatelessWidget {
  const SearchPage();

  @override
  Widget build(BuildContext context) => const HookCoordinator(use: useSearchPageState, builder: SearchPageView.new);
}
