import 'package:go_router/go_router.dart';
import 'package:todo_list/presentations/cubits/auth/auth_cubit.dart';
import 'package:todo_list/presentations/views/home_page.dart';
import 'package:todo_list/presentations/views/login_page.dart';
import 'package:todo_list/routing/go_router_refresh_stream.dart';

class AppRoutes {
  static final authCubit = AuthCubit();

  static const home = '/';
  static const login = '/login';

  static final router = GoRouter(
    initialLocation: home,

    redirect: (context, state) {
      final authState = authCubit.state;

      if (authState.status == AuthStatus.initial) return null;

      final bool isLoggedIn = authState.status == AuthStatus.authenticated;
      final bool isLoggingIn = state.matchedLocation == login;

      if (!isLoggedIn && !isLoggingIn) return login;
      if (isLoggedIn && isLoggingIn) return home;

      return null;
    },

    refreshListenable: GoRouterRefreshStream(authCubit.stream),

    routes: [
      GoRoute(path: home, builder: (context, state) => HomePage()),
      GoRoute(path: login, builder: (context, state) => LoginPage()),
    ],
  );
}
