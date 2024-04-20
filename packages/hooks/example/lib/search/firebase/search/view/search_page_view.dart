import 'package:flutter/material.dart';
import 'package:utopia_hooks/utopia_hooks.dart';
import 'package:utopia_hooks_example/search/firebase/search/state/search_page_state.dart';

class SearchPageView extends StatelessWidget {
  final SearchPageState state;

  const SearchPageView(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildSearchField()),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return TextEditingControllerWrapper(
      text: state.search,
      builder: (controller) => TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Search..."),
      ),
    );
  }

  Widget _buildBody() {
    if (state.isLoading) return _buildLoading();
    if (state.isEmpty) return _buildEmpty();
    return _buildList();
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildEmpty() => const Center(child: Text("No results"));

  Widget _buildList() {
    return ListView.builder(
      itemCount: state.results!.length,
      itemBuilder: (context, index) => ListTile(dense: true, title: Text(state.results![index])),
    );
  }
}
