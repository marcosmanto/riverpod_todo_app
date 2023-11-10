import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo_app/todo.dart';

/// Some keys used for testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);

/// The different ways to filter the list of todos
enum TodoListFilter {
  all,
  active,
  completed,
}

/// The currently active filter.
///
/// We use [StateProvider] here as there is no fancy logic behind manipulating
/// the value since it's just enum.
final todoListFilter = StateProvider((_) => TodoListFilter.all);

/// The number of uncompleted todos
///
/// By using [Provider], this value is cached, making it performant.\
/// Even multiple widgets try to read the number of uncompleted todos,
/// the value will be computed only once (until the todo-list changes).
///
/// This will also optimise unneeded rebuilds if the todo-list changes, but the
/// number of uncompleted todos doesn't (such as when editing a todo).
final uncompletedTodosCount = Provider<int>((ref) {
  return ref.watch(todoListProvider).where((todo) => !todo.completed).length;
});

/// The list of todos after applying of [todoListFilter].
///
/// This too uses [Provider], to avoid recomputing the filtered list unless either
/// the filter of or the todo-list updates.
final filteredTodos = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilter);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodoListFilter.all:
      return todos;
  }
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends HookConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0)
          print('Scrolled to top');
        else
          print('Scrolled to bottom');
      }
    });

    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final todos = ref.watch(todoListProvider);
          return ListView(
            controller: scrollController,
            children: [
              for (final todo in todos)
                Container(
                  alignment: Alignment.center,
                  color: Color.fromRGBO(Random().nextInt(256),
                      Random().nextInt(256), Random().nextInt(256), 1),
                  height: 250,
                  child: Text(todo.description),
                )
            ],
          );
        },
      ),
      floatingActionButton: Consumer(builder: (context, ref, _) {
        return FloatingActionButton(
          key: const Key('increment_floatingActionButton'),
          // The read method is a utility to read a provider without listening to it
          onPressed: () {
            ref.read(todoListProvider.notifier).add('Learn Riverpod');
            scrollController.animateTo(
              scrollController.position.maxScrollExtent + 300,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutExpo,
            );
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}
