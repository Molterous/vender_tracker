import 'dart:convert';
import '../enums/task_status_enum.dart';

class Tasks {

  final String taskId, title, desc, dueDate, worker, creator;
  final TaskStatusEnum status;
  final Map<String, dynamic> updates;
  // time logged

  Tasks({
    required this.taskId,
    required this.title,
    required this.desc,
    required this.dueDate,
    required this.worker,
    required this.creator,
    this.status = TaskStatusEnum.idle,
    this.updates = const {},
  });

  factory Tasks.fromMap(Map<String, dynamic> map) => Tasks(
    taskId: map["id"],
    title: map["title"],
    desc: map["desc"],
    dueDate: map["dueDate"],
    worker: map["worker"],
    creator: map["creator"],
    updates: jsonDecode((map["updates"] ?? "")),
    status: taskMap(int.parse(map["status"])),
  );
}