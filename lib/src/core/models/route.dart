class OperatorRoute {
  String id;
  String operatorId;
  List<String> groupIds;
  List<String> pointsOfSaleIds;
  String ownerId;
  String label;

  OperatorRoute.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    operatorId = json['operatorId'];
    groupIds = List<String>.from(json['groupIds']);
    pointsOfSaleIds = List<String>.from(json['pointsOfSaleIds']);
    ownerId = json['ownerId'];
    label = json['label'];
  }
}
