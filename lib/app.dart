import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/photos/photos_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'data/repositories/settings_repository.dart';
import 'data/providers/purchase_provider.dart';

class NailBiteApp extends ConsumerWidget {
  const NailBiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    // Watch premium state: reacts to purchases & restores in real time
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;

    return MaterialApp(
      title: 'NailBite Coach',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: settingsAsync.when(
        data: (settings) {
          final onboardingDone = settings?.onboardingDone == true;
          // Go to MainShell if onboarding is complete OR if user already has
          // an active entitlement (e.g. reinstall after purchase)
          if (onboardingDone || isPremium) return const MainShell();
          return const OnboardingScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const MainShell(),
      ),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    PhotosScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.white,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_outlined),
              selectedIcon: Icon(Icons.photo),
              label: 'Photos',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Analyses',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
