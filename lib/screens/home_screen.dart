import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _navigateToEdit(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    await context.push(path);
    // Refresh todos when returning from edit screen
    ref.read(todosProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider);
    print('Building HomeScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: todosAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(
              child: Text(
                'No todos yet!\nTap + to create one',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    todo.status
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: todo.status ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    todo.name,
                    style: TextStyle(
                      decoration: todo.status
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.status ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    'Created: ${dateFormat.format(todo.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _navigateToEdit(context, ref, '/todo/${todo.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(context, ref, '/todo/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
