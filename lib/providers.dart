import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';

// Provider for the database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

// Provider to watch all todos
final todosProvider = StreamProvider<List<Todo>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.watchAllTodos();
});
