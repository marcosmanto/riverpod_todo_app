import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo_app/todo.dart';

final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends HookWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0)
          print('Scrolled to top');
        else
          print('Scrolled to bottom');
      }
    });

    return MaterialApp(
      home: Scaffold(
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
            onPressed: () =>
                ref.read(todoListProvider.notifier).add('Learn Riverpod'),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          );
        }),
      ),
    );
  }
}
