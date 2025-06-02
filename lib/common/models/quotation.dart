import 'dart:convert';

class Quotation {
  final String name, info, note, worker, taskId, modifiedDate, quotationId;
  final Map<String, String> services;

  Quotation({
    required this.name,
    required this.info,
    required this.note,
    required this.worker,
    required this.taskId,
    required this.modifiedDate,
    this.quotationId = '',
    this.services = const {},
  });

  factory Quotation.fromMap(Map<String, dynamic> map) {
    final Map<String, String> dataMap =
        Map<String, String>.from(jsonDecode((map["services"] ?? "{}")));

    return Quotation(
      taskId: map["taskId"],
      name: map["name"],
      info: map["info"],
      note: map["note"],
      worker: map["worker"],
      modifiedDate: map["modifiedDate"],
      quotationId: map["quotationId"],
      services: dataMap,
    );
  }

  Map<String, String> toMap() => {
        "taskId": taskId.toString(),
        "name": name.toString(),
        "info": info.toString(),
        "note": note.toString(),
        "worker": worker.toString(),
        "modifiedDate": modifiedDate.toString(),
        "quotationId": quotationId.toString(),
        "services": jsonEncode(services),
      };

  Quotation copyWith(String id) => Quotation(
        name: name,
        info: info,
        note: note,
        worker: worker,
        taskId: taskId,
        modifiedDate: modifiedDate,
        services: services,
        quotationId: id,
      );
}
