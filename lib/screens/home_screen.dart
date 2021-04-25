import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/database.dart';
import '../logic/data_structures.dart';

/// Landing page with all task details
///
/// Widget contains a header with application name
/// On the left lies the menu for filtering tasks
/// On the right list of tasks are displayed
/// Towars the bottom input provided for new taks
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

/// Menu for filtering tasks
class TaskCategoryMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.date_range_rounded),
          title: Text('Planned'),
          hoverColor: Colors.black38,
          dense: true,
        ),
        ListTile(
          leading: Icon(Icons.all_inclusive_rounded),
          title: Text('All'),
          dense: true,
        ),
        ListTile(
          leading: Icon(Icons.check_circle_outline_rounded),
          title: Text('Completed'),
          dense: true,
        ),
      ],
    );
  }
}

/// Widget to display all tasks
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
              return Card(child: TaskWidget(task: dbp.tasks[index]));
            },
          ),
        );
      },
    );
  }
}

/// Widget to represent each task
///
/// Displays tasks status as icon, along with its name
/// and delete button to delete the task from database.
/// Pressing task status button toggles the task status
/// and reloads all the tasks
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
          dense: true,
          leading: IconButton(
            icon: Icon(
              this.status == TaskItemStatus.Completed
                  ? Icons.check_circle_outline_rounded
                  : Icons.brightness_1_outlined,
              color: this.status == TaskItemStatus.Completed
                  ? Colors.green
                  : Colors.blueAccent,
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
          title: Text(
            this.name,
            style: TextStyle(
                color: this.status == TaskItemStatus.Completed
                    ? Colors.black26
                    : Colors.black),
          ),
          subtitle: Text(
            'Task #${this.id}',
            style: TextStyle(color: Colors.black12),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_rounded,
              color: Colors.redAccent,
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

/// Widget to add new tasks to database
///
/// Contains an input field and a icon button to add task to database.
/// Clicking on add icon button adds the current text in input field
/// as task name. A new task is created marked as pending and tasks list
/// is reloaded.
class AddTask extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddTaskState();
}

/// State for `AddTask` widget
///
/// Holds the details of the current text in input field.
/// This helps add icon button in accessing the text in input
/// for uploading to database.
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
                  hintText: "Add the task on your mind!",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  this.setState(() {
                    this.taskName = value;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.green,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  color: Colors.green,
                  icon: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                  ),
                  tooltip: 'Add a new task',
                  onPressed: () {
                    dbp.addNewTask(name: this.taskName);
                    dbp.loadTasks();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
