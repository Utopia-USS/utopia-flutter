import 'package:utopia_hooks/utopia_hooks.dart';

enum HomeTab { todos, stats }

class HomePageState {
  final MutableValue<HomeTab> currentTab;

  const HomePageState({required this.currentTab});
}

HomePageState useHomePageState() {
  final tabState = useState(HomeTab.todos);

  return HomePageState(currentTab: tabState);
}
