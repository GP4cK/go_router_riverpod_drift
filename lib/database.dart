import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Define the todos table
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get status => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Define the database
@DriftDatabase(tables: [Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD operations for todos
  Future<List<Todo>> getAllTodos() => select(todos).get();
  
  Stream<List<Todo>> watchAllTodos() => select(todos).watch();
  
  Future<Todo> getTodoById(int id) =>
      (select(todos)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> insertTodo(TodosCompanion todo) => into(todos).insert(todo);
  
  Future<bool> updateTodo(Todo todo) => update(todos).replace(todo);
  
  Future<int> deleteTodo(int id) =>
      (delete(todos)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todos.sqlite'));
    return NativeDatabase(file);
  });
}
