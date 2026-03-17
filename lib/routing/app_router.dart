import 'package:go_router/go_router.dart';
import 'package:todo_list/presentations/views/home_page.dart';
import 'package:todo_list/presentations/views/login_page.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';

  static final router = GoRouter(
    initialLocation: login,

    routes: [
      GoRoute(path: home, builder: (context, state) => HomePage()),
      GoRoute(path: login, builder: (context, state) => LoginPage()),
    ],
  );
}
