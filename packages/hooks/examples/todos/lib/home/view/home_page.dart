import 'package:flutter/material.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/home/home.dart';
import 'package:flutter_todos/stats/stats.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:utopia_hooks/utopia_hooks.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const HookCoordinator(
        use: useHomePageState,
        builder: HomeView.new,
      );
}

class HomeView extends StatelessWidget {
  final HomePageState state;

  const HomeView(this.state);

  @override
  Widget build(BuildContext context) {
    final selectedTab = state.currentTab;

    return Scaffold(
      body: IndexedStack(
        index: selectedTab.value.index,
        children: const [TodosOverviewPage(), StatsPage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        key: const Key('homeView_addTodo_floatingActionButton'),
        onPressed: () => Navigator.of(context).push(EditTodoPage.route()),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _HomeTabButton(
              state: state,
              value: HomeTab.todos,
              icon: const Icon(Icons.list_rounded),
            ),
            _HomeTabButton(
              state: state,
              value: HomeTab.stats,
              icon: const Icon(Icons.show_chart_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.state,
    required this.value,
    required this.icon,
  });

  final HomePageState state;
  final HomeTab value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => state.currentTab.value = value,
      iconSize: 32,
      color: state.currentTab != value ? null : Theme.of(context).colorScheme.secondary,
      icon: icon,
    );
  }
}
