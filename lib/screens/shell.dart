import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/shuttlecock_icon.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'match_screen.dart';
import 'players_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _titles = ['ก๊วนวันนี้', 'รายชื่อผู้เล่น', 'จัดคู่', 'ประวัติ'];

  @override
  Widget build(BuildContext context) {
    final hydrated = ref.watch(appControllerProvider.select((s) => s.hydrated));
    if (!hydrated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }

    final pages = [
      HomeScreen(onStartMatch: () {
        setState(() => _index = 2);
        final controller = ref.read(appControllerProvider.notifier);
        if (ref.read(appControllerProvider).deal == null) {
          controller.reshuffle();
        }
      }),
      const PlayersScreen(),
      const MatchScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ScreenTitle(title: _titles[_index], showBack: _index != 0, onBack: () => setState(() => _index = 0)),
            Expanded(child: pages[_index]),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
          if (value == 2 && ref.read(appControllerProvider).deal == null) {
            ref.read(appControllerProvider.notifier).reshuffle();
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE5F6EC),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.green),
            label: 'ก๊วนวันนี้',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.green),
            label: 'รายชื่อผู้เล่น',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: AppColors.green),
            label: 'จัดคู่',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history, color: AppColors.green),
            label: 'ประวัติ',
          ),
        ],
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    super.key,
    required this.title,
    required this.showBack,
    required this.onBack,
  });

  final String title;
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 4),
      child: Row(
        children: [
          if (showBack)
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back))
          else
            const Padding(padding: EdgeInsets.only(left: 8), child: BrandMark()),
          if (!showBack) const SizedBox(width: 10),
          if (showBack) const BrandMark(size: 30),
          if (showBack) const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          if (!showBack)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: AppColors.ink),
            ),
        ],
      ),
    );
  }
}
