import '../../../src/core/models/chart_item.dart';
import '../../../src/core/models/machine.dart';
import '../../../src/core/models/telemetry_board.dart';

class MachineLog {
  String user;
  double value;
  String type;
  String observations;
  DateTime date;

  MachineLog.fromMap(Map<String, dynamic> json) {
    user = json['user']['name'];
    value = json['quantity'].toDouble();
    observations = json['observations'];
    date = DateTime.parse(json['createdAt']);
    type = json['type'];
  }
}

class TelemetryLog {
  double value;
  DateTime date;
  String type;
  bool maintenance;
  bool offline;

  TelemetryLog.fromMap(Map<String, dynamic> json) {
    value = json['value'].toDouble();
    date = json['date'] != null ? DateTime.parse(json['date']) : null;
    type = json['type'];
    maintenance = json['maintenance'];
    offline = json['offline'];
  }
}

class BoxInfo {
  String boxId;
  double currentMoney;
  int currentPrizeCount;
  int givenPrizes;

  BoxInfo.fromJson(Map<String, dynamic> json) {
    boxId = json['boxId'];
    currentMoney = json['currentMoney'] != null
        ? double.parse(json['currentMoney'].toString())
        : null;
    currentPrizeCount = json['currentPrizeCount'];
    givenPrizes = json['givenPrizes'];
  }
}

class DetailedMachine {
  Machine machine;
  String pointOfSaleLabel;
  String groupLabel;
  double income;
  int givenPrizes;
  TelemetryBoard telemetryBoard;
  DateTime lastCollection;
  DateTime lastConnection;
  List<BoxInfo> boxesInfo;
  List<ChartItem> chartData;
  List<TelemetryLog> transactionHistory;
  List<MachineLog> eventHistory;
  String collectedBy;

  DetailedMachine.fromJson(Map<String, dynamic> json) {
    machine = Machine.fromMap(json['machine']);
    pointOfSaleLabel = json['machine']['pointOfSale'] != null
        ? json['machine']['pointOfSale']['label']
        : null;
    collectedBy = json['collectedBy'];
    groupLabel = json['machine']['group']['isPersonal']
        ? null
        : json['machine']['group']['label'];
    income =
        json['income'] != null ? double.parse(json['income'].toString()) : null;
    givenPrizes = json['givenPrizes'];
    telemetryBoard = json['machine']['telemetryBoard'] != null
        ? TelemetryBoard.fromJson(json['machine']['telemetryBoard'])
        : null;
    lastCollection = json['lastCollection'] != null
        ? DateTime.parse(json['lastCollection'])
        : null;
    lastConnection = json['machine']['telemetryBoard'] == null
        ? null
        : (json['machine']['telemetryBoard']['lastConnection'] == null
            ? null
            : DateTime.parse(
                json['machine']['telemetryBoard']['lastConnection']));
    boxesInfo = List<BoxInfo>.from(
        json['boxesInfo'].map((boxInfo) => BoxInfo.fromJson(boxInfo)).toList());
    chartData = List<ChartItem>.from(json['chartData']
        .map((chartItem) => ChartItem.fromMap(chartItem))
        .toList());
    transactionHistory = List<TelemetryLog>.from(json['transactionHistory']
        .map((transactionHistory) => TelemetryLog.fromMap(transactionHistory))
        .toList());
    eventHistory = json['machineLogs'] != null
        ? List<MachineLog>.from(json['machineLogs']
            .map((machineLog) => MachineLog.fromMap(machineLog))
            .toList())
        : null;
  }
}
