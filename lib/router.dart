import 'package:go_router/go_router.dart';

import 'screens/edit_todo_screen.dart';
import 'screens/home_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/todo/new',
      builder: (context, state) => const EditTodoScreen(),
    ),
    GoRoute(
      path: '/todo/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EditTodoScreen(todoId: id);
      },
    ),
  ],
);
