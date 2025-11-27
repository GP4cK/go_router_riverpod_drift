import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../database.dart';
import '../providers.dart';

class EditTodoScreen extends ConsumerStatefulWidget {
  final int? todoId;

  const EditTodoScreen({super.key, this.todoId});

  @override
  ConsumerState<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends ConsumerState<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _status = false;
  DateTime? _createdAt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodo();
  }

  Future<void> _loadTodo() async {
    if (widget.todoId != null) {
      final database = ref.read(databaseProvider);
      try {
        final todo = await database.getTodoById(widget.todoId!);
        setState(() {
          _nameController.text = todo.name;
          _status = todo.status;
          _createdAt = todo.createdAt;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading todo: $e')));
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final database = ref.read(databaseProvider);

    try {
      if (widget.todoId == null) {
        // Create new todo
        await database.insertTodo(
          TodosCompanion(
            name: drift.Value(_nameController.text),
            status: drift.Value(_status),
          ),
        );
      } else {
        // Update existing todo
        await database.updateTodo(
          Todo(
            id: widget.todoId!,
            name: _nameController.text,
            status: _status,
            createdAt: _createdAt!,
          ),
        );
      }

      if (mounted && widget.todoId == null) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving todo: $e')));
      }
    }
  }

  Future<void> _deleteTodo() async {
    if (widget.todoId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final database = ref.read(databaseProvider);
      try {
        await database.deleteTodo(widget.todoId!);
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting todo: $e')));
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNewTodo = widget.todoId == null;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewTodo ? 'New Todo' : 'Edit Todo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!isNewTodo)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTodo),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Todo Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a todo name';
                        }
                        return null;
                      },
                      autofocus: isNewTodo,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('Status:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SwitchListTile(
                            title: Text(
                              _status ? 'Done' : 'Not Done',
                              style: TextStyle(
                                color: _status ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: _status,
                            onChanged: (value) {
                              setState(() {
                                _status = value;
                              });
                            },
                            secondary: Icon(
                              _status
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: _status ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_createdAt != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Created: ${dateFormat.format(_createdAt!)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTodo,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isNewTodo ? 'Create Todo' : 'Update Todo',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
