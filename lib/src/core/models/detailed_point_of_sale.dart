import '../../../src/core/models/machine.dart';
import '../../../src/core/models/point_of_sale.dart';
import '../../../src/core/models/route.dart';
import '../../../src/core/models/telemetry_board.dart';

import 'chart_item.dart';

class MachineInfo {
  double income;
  Machine machine;
  TelemetryBoard telemetryBoard;

  MachineInfo.fromJson(Map<String, dynamic> json) {
    telemetryBoard = json['machine']['telemetryBoard'] != null
        ? TelemetryBoard.fromJson(json['machine']['telemetryBoard'])
        : TelemetryBoard.fake();
    telemetryBoard.lastConnection = json['machine']['lastConnection'];
    income = json['income'].toDouble();
    machine = Machine.fromMap(json['machine']);
  }
}

class DetailedPointOfSale {
  List<MachineInfo> machinesInfo;
  PointOfSale pointOfSale;
  String groupLabel;
  double income;
  OperatorRoute route;
  int givenPrizesCount;
  List<ChartItem> chartData;

  DetailedPointOfSale.fromJson(Map<String, dynamic> json) {
    machinesInfo = List<MachineInfo>.from(json['machinesInfo']
        .map((machineInfo) => MachineInfo.fromJson(machineInfo))
        .toList());
    route =
        json['route'] != null ? OperatorRoute.fromJson(json['route']) : null;
    givenPrizesCount = json['givenPrizesCount'];
    chartData = List<ChartItem>.from(json['chartData']
        .map((chartItem) => ChartItem.fromMap(chartItem))
        .toList());
    pointOfSale = PointOfSale.fromMap(json['pointOfSale']);
    income = json['income'].toDouble();
    groupLabel = json['pointOfSale']['group']['label'];
  }
}
