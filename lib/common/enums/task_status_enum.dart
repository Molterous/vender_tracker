
enum TaskStatusEnum {

  idle(0,       "IDLE"),
  working(1,    "In-Progress"),
  completed(2,  "Completed");

  final int id;
  final String title;

  const TaskStatusEnum(this.id, this.title);
}

TaskStatusEnum taskMap(int role) {
  switch(role) {
    case 0: return TaskStatusEnum.idle;
    case 1: return TaskStatusEnum.working;
    default: return TaskStatusEnum.completed;
  }
}