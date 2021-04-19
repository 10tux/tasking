import 'package:flutter/material.dart';

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
            Expanded(child: TasksList(), flex: 5),
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
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: ListView.builder(
        itemCount: 100,
        controller: _scrollController,
        itemBuilder: (_, index) {
          return TaskWidget();
        },
      ),
    );
  }
}

class TaskWidget extends StatefulWidget {
  TaskWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          Icons.cancel,
          color: Colors.red,
        ),
        onPressed: () => {},
        splashRadius: 18.0,
      ),
      title: Text("task"),
    );
  }
}
