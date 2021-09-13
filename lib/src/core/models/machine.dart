import '../../../src/core/models/prize.dart';

import 'box.dart';

class LeanMachine {
  String id;
  String serialNumber;
  String locationId;

  LeanMachine.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    serialNumber = json['serialNumber'];
    locationId = json['locationId'];
  }
}

class Machine {
  String id;
  String ownerId;
  String groupId;
  int telemetryBoardId;
  int givenPrizes;
  String locationId;
  String operatorId;
  Prize typeOfPrize;
  int minimumPrizeCount;
  String operatorName;
  String serialNumber;
  double incomePerPrizeGoal;
  double incomePerMonthGoal;
  double gameValue;
  String categoryId;
  String categoryLabel;
  bool isActive;
  bool maintenance;
  DateTime lastConnection;
  DateTime lastCollection;
  List<Box> boxes;

  Machine() {
    boxes = [];
  }

  Machine.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    groupId = json['groupId'];
    givenPrizes = json['givenPrizes'];
    telemetryBoardId = json['telemetryBoardId'];
    minimumPrizeCount = json['minimumPrizeCount'];
    incomePerPrizeGoal = json['incomePerPrizeGoal'] != null
        ? json['incomePerPrizeGoal'].toDouble()
        : null;
    incomePerMonthGoal = json['incomePerMonthGoal'] != null
        ? json['incomePerMonthGoal'].toDouble()
        : null;
    locationId = json['locationId'];
    typeOfPrize = json['typeOfPrize'] != null
        ? Prize.fromMap(json['typeOfPrize'], groupId)
        : null;
    operatorId = json['operatorId'];
    operatorName = json['operator'] != null
        ? (json['operator'] is String ? null : json['operator']['name'])
        : null;
    serialNumber = json['serialNumber'];
    gameValue = double.parse(json['gameValue'].toString());
    categoryId = json['categoryId'];
    categoryLabel = json['categoryLabel'];
    isActive = json['isActive'];
    maintenance = json['maintenance'];
    lastConnection = json['lastConnection'] != null
        ? DateTime.parse(json['lastConnection'])
        : null;
    lastCollection = json['lastCollection'] != null
        ? DateTime.parse(json['lastCollection'])
        : null;
    boxes =
        List<Box>.from(json['boxes'].map((box) => Box.fromMap(box)).toList());
  }

  Map<String, dynamic> toMap(bool creatingMachine) {
    var tmp = {
      'serialNumber': serialNumber,
      'gameValue': gameValue,
      'groupId': groupId,
      'typeOfPrizeId': typeOfPrize != null ? typeOfPrize.id : null,
      'minimumPrizeCount': minimumPrizeCount,
      'categoryId': categoryId,
      'operatorId': operatorId,
      'telemetryBoardId': telemetryBoardId,
      'boxes': List.generate(
        boxes.length,
        (index) => boxes[index].toMap(creatingMachine),
      )
    };
    if (locationId != null) {
      tmp['locationId'] = locationId;
    }

    if (incomePerPrizeGoal != null) {
      tmp['incomePerPrizeGoal'] = incomePerPrizeGoal;
    }
    if (incomePerMonthGoal != null) {
      tmp['incomePerMonthGoal'] = incomePerMonthGoal;
    }

    return tmp;
  }
}
