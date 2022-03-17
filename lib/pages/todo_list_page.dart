import 'package:flutter/material.dart';
import 'package:tarefas/models/todo.dart';
import 'package:tarefas/repositories/todo_repository.dart';
import 'package:tarefas/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);
  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController controller = TextEditingController();
  final TodoRepository repository = TodoRepository();

  List<Todo> todos = [];
  Todo? deleteTodo;
  int? deletedPos;

  final String? errorTxt = 'Precisa de texto';

  @override
  void initState() {
    super.initState();

    repository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Lista de Tarefas',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Adicione uma tarefa',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: addAssignment,
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Icon(
                        Icons.add,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos) 
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children:  [
                    Expanded(
                      child: Text(
                        'Você possui ${todos.length} tarefas',
                      ), 
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: removeAssignment,
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(16),
                      ), 
                      child: const Text(
                       'Limpar tudo',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addAssignment(){
    String text = controller.text;
    if(text.isEmpty) {
      setState(() {
        errorTxt;
      });
      return;
    }
    setState(() {
      Todo todo = Todo(
        title: text, 
        date: DateTime.now()
      );
      todos.add(todo);
      errorTxt;
    });
    controller.clear();
    repository.saveTodoList(todos);
  }

  void removeAssignment() {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Deseja realmente limpar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: onCancel, 
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: deleteAll, 
            child: const Text('Limpar tudo'),
          ),
        ],
      ),
    );
    for (Todo todo in todos) {
      todos.remove(todo);
    } 
  }

  void deleteAll() { 
    setState(() {
      todos.clear();
    });
    repository.saveTodoList(todos);
  }

  void onDelete(Todo todo) {
    deleteTodo = todo;
    deletedPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });

    repository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarefa removida com sucesso'),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              todos.insert(deletedPos!, deleteTodo!);
            });
            repository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void onCancel(){
    Navigator.of(context).pop();
  }
}