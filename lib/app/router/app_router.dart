import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aula/app/router/main_shell.dart';
import 'package:aula/app/router/routes.dart';
import 'package:aula/app/theme/theme_provider.dart';
import 'package:aula/core/services/security_service.dart';

import 'package:aula/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:aula/features/exams/presentation/screens/exam_detail_screen.dart';
import 'package:aula/features/grades/presentation/screens/grades_screen.dart';
import 'package:aula/features/home/presentation/screens/home_screen.dart';
import 'package:aula/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:aula/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:aula/features/search/presentation/screens/search_screen.dart';
import 'package:aula/features/settings/presentation/screens/security_lock_screen.dart';
import 'package:aula/features/settings/presentation/screens/settings_screen.dart';
import 'package:aula/features/subjects/presentation/screens/subject_detail_screen.dart';
import 'package:aula/features/subjects/presentation/screens/subjects_list_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(appLockProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notifier = ref.watch(routerNotifierProvider);
  final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding,
    redirect: (context, state) {
      final isLocked = ref.read(appLockProvider);
      final isGoingToLock = state.matchedLocation == AppRoutes.lock;
      final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (isLocked && !isGoingToLock) {
        return AppRoutes.lock;
      }
      if (!isLocked && isGoingToLock) {
        return hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding;
      }
      if (!hasCompletedOnboarding && !isGoingToOnboarding && !isLocked) {
        return AppRoutes.onboarding;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.lock,
        builder: (context, state) => const SecurityLockScreen(
          mode: SecurityScreenMode.unlock,
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/exams/:id',
        builder: (context, state) => ExamDetailScreen(
          examId: state.pathParameters['id']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subjects,
                builder: (context, state) => const SubjectsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => SubjectDetailScreen(
                      subjectId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.grades,
                builder: (context, state) => const GradesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
