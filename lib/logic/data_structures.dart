import 'package:flutter/cupertino.dart';

/// Each task to be done
///
/// Each task has a unique id from database and a name for the task that is
/// displayed
class TaskItem {
  int id = 0;
  String name = "";
  TaskItemStatus status = TaskItemStatus.Pending;

  TaskItem({int id, String name, TaskItemStatus status}) {
    this.id = id;
    this.name = name;
    this.status = status;
  }
}

/// Possible values for task item status
enum TaskItemStatus { Completed, Pending }

/// Current selected menu item in `TaskCategoryMenu`
///
/// Datastructure for state management using provider package.
/// Holds the current selected menu item details
class SelectedTaskMenuProvider extends ChangeNotifier {
  TaskMenuItemTag _selectedItem = TaskMenuItemTag.Planned;

  TaskMenuItemTag get selectedItem => _selectedItem;
  set selectedItem(TaskMenuItemTag newSelection) {
    this._selectedItem = newSelection;
    notifyListeners();
  }
}

/// Enum of possible values for selected task menu
///
/// Each item in this enum corresponds with the list of menu widgets in
/// `TaskCategeoryMenu` of the same name.
enum TaskMenuItemTag { Planned, Completed, AllTasks }

/// Hold the details of currently displayed tasks
class CurrentDisplayedTasks extends ChangeNotifier {
  var _tasks = <TaskItem>[];

  get tasks => _tasks;
  set tasks(List<TaskItem> taskList) {
    _tasks = taskList;
    notifyListeners();
  }
}
