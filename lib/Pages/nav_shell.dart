import 'package:exercise_app/Pages/home.dart';
import 'package:exercise_app/Pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavShell extends StatefulWidget {
  const NavShell({super.key});

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  final _controller = PageController(initialPage: 1);
  final _index = ValueNotifier<int>(1);
  final _navKeys = List.generate(3, (_) => GlobalKey<NavigatorState>());

  @override
  void dispose() {
    _controller.dispose();
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roots = [const SizedBox(), const HomePage(),  const Profile()];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _navKeys[_index.value].currentState!;
        if (nav.canPop()) {
          nav.pop();
        } else {
          SystemNavigator.pop(); // import 'package:flutter/services.dart'
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _controller,
          onPageChanged: (i) => _index.value = i,
          children: [
            for (var i = 0; i < 3; i++)
              KeepAlivePage(
                child: Navigator(
                  key: _navKeys[i],
                  onGenerateRoute: (_) =>
                      MaterialPageRoute(builder: (_) => roots[i]),
                ),
              ),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _index,
          builder: (_, index, __) => NavigationBar(
            height: 60,
            selectedIndex: index,
            onDestinationSelected: (i) => _controller.animateToPage(i,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut),
              destinations: const [
              NavigationDestination(icon: Icon(Icons.layers_outlined), label: 'Social'),
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      )
    );
  }
}

/// Keeps each page's state (scroll position, form input) alive when swiped away.
class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required
    return widget.child;
  }
}