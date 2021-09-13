import '../../interface/shared/enums.dart';

class CounterType {
  String id;
  String ownerId;
  String label;
  CType type;

  CounterType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    label = json['label'];
    type = json['type'] == 'IN'
        ? CType.IN
        : json['type'] == 'OUT'
            ? CType.OUT
            : CType.UNDEFINED;
  }
}
