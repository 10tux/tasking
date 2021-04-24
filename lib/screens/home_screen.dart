import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/database.dart';
import '../logic/data_structures.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Container(
        child: Row(
          children: [
            Expanded(
              child: TaskCategoryMenu(),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: TasksList(),
                  ),
                  Container(
                    margin: EdgeInsets.all(20.0),
                    child: AddTask(),
                  ),
                ],
              ),
              flex: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCategoryMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text('Pending')),
        ListTile(title: Text('All')),
        ListTile(title: Text('Completed')),
      ],
    );
  }
}

class TasksList extends StatefulWidget {
  TasksList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, dbp, _) {
        return Scrollbar(
          isAlwaysShown: true,
          controller: _scrollController,
          child: ListView.builder(
            itemCount: dbp.tasks.length,
            controller: _scrollController,
            itemBuilder: (context, index) {
              return TaskWidget(task: dbp.tasks[index]);
            },
          ),
        );
      },
    );
  }
}

class TaskWidget extends StatelessWidget {
  int id;
  String name;
  TaskItemStatus status;

  TaskWidget({Key key, TaskItem task}) : super(key: key) {
    id = task.id;
    name = task.name;
    status = task.status;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, dbp, _) {
        return ListTile(
          leading: IconButton(
            icon: Icon(
              this.status == TaskItemStatus.Completed
                  ? Icons.check_circle_outline_rounded
                  : Icons.circle,
            ),
            onPressed: () {
              if (this.status == TaskItemStatus.Pending) {
                dbp.setTaskStatus(
                    taskId: this.id, status: TaskItemStatus.Completed);
              } else {
                dbp.setTaskStatus(
                    taskId: this.id, status: TaskItemStatus.Pending);
              }
              dbp.loadTasks();
            },
            splashRadius: 20.0,
          ),
          title: Text(this.name),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_rounded,
              color: Colors.red,
            ),
            splashRadius: 20.0,
            splashColor: Colors.red.shade200,
            onPressed: () {
              dbp.deleteTask(taskId: this.id);
              dbp.loadTasks();
            },
          ),
        );
      },
    );
  }
}

class AddTask extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String taskName = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, dbp, _) {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                    hintText: "Add the task on your mind!"),
                onChanged: (value) {
                  this.setState(() {
                    this.taskName = value;
                  });
                },
              ),
            ),
            IconButton(
              color: Colors.green,
              icon: Icon(
                Icons.add_rounded,
              ),
              onPressed: () {
                dbp.addNewTask(name: this.taskName);
                dbp.loadTasks();
              },
            ),
          ],
        );
      },
    );
  }
}
