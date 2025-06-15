import 'dart:convert';
import '../helpers/encryption_helper.dart';

class Quotation {

  final String name, info, note, worker, taskId, modifiedDate, quotationId;
  final Map<String, String> serviceName, serviceType, serviceCharges,
      serviceUnit, serviceRemark, docketCharges, hamaliCharges, doorDelivery,
      pfCharges, greenTaxCharge, fovCharges, gstCharges,
      otherCharges, totalCharges;

  Quotation({
    required this.name,
    required this.info,
    required this.note,
    required this.worker,
    required this.taskId,
    required this.modifiedDate,
    this.quotationId = '',
    this.serviceName = const {},
    this.serviceType = const {},
    this.serviceCharges = const {},
    this.serviceUnit = const {},
    this.serviceRemark = const {},
    this.docketCharges = const {},
    this.hamaliCharges = const {},
    this.doorDelivery = const {},
    this.pfCharges = const {},
    this.greenTaxCharge = const {},
    this.fovCharges = const {},
    this.gstCharges = const {},
    this.otherCharges = const {},
    this.totalCharges = const {},
  });

  factory Quotation.fromMap(Map<String, dynamic> map) {

    // final str = jsonDecode(decodeAndDecompress((map["services"] ?? "[]")));
    //
    // final List<Map> dataList = List<Map>.from(str);
    //
    // final List<Map<String, String>> data = dataList.map((e) => e.map<String, String>((key, value) {
    //   return MapEntry(key.toString(), value.toString());
    // })).toList();

    return Quotation(
      taskId: map["taskId"],
      name: map["name"],
      info: map["info"],
      note: map["note"],
      worker: map["worker"],
      modifiedDate: map["modifiedDate"],
      quotationId: map["quotationId"],
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
    "serviceName": jsonEncode(serviceName),
    "serviceType": jsonEncode(serviceType),
    "serviceCharges": jsonEncode(serviceCharges),
    "serviceUnit": jsonEncode(serviceUnit),
    "serviceRemark": jsonEncode(serviceRemark),
    "docketCharges": jsonEncode(docketCharges),
    "hamaliCharges": jsonEncode(hamaliCharges),
    "doorDelivery": jsonEncode(doorDelivery),
    "pfCharges": jsonEncode(pfCharges),
    "greenTaxCharge": jsonEncode(greenTaxCharge),
    "fovCharges": jsonEncode(fovCharges),
    "gstCharges": jsonEncode(gstCharges),
    "otherCharges": jsonEncode(otherCharges),
    "totalCharges": jsonEncode(totalCharges),
  };

  Quotation copyWith(String id) => Quotation(
    quotationId: id,
    name: name,
    info: info,
    note: note,
    worker: worker,
    taskId: taskId,
    modifiedDate: modifiedDate,
    serviceName: serviceName,
    serviceType: serviceType,
    serviceCharges: serviceCharges,
    serviceUnit: serviceUnit,
    serviceRemark: serviceRemark,
    docketCharges: docketCharges,
    hamaliCharges: hamaliCharges,
    doorDelivery: doorDelivery,
    pfCharges: pfCharges,
    greenTaxCharge: greenTaxCharge,
    fovCharges: fovCharges,
    gstCharges: gstCharges,
    otherCharges: otherCharges,
    totalCharges: totalCharges,
  );
}
