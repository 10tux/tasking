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