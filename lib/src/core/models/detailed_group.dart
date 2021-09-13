import '../../../src/core/models/sorted_machines.dart';

import 'chart_item.dart';
import 'group.dart';
import 'income_method_distribution.dart';

class PointOfSaleSortedByIncome {
  String id;
  String label;
  String numberOfMachines;
  double income;

  PointOfSaleSortedByIncome.fromMap(Map<String, dynamic> json) {
    id = json['pointOfSale']['id'];
    label = json['pointOfSale']['label'];
    numberOfMachines = json['numberOfMachines'].toString();
    income = json['income'].toDouble();
  }
}

class DetailedGroup {
  Group group;
  List<ChartItem> barChartData;
  int offlineMachines;
  int onlineMachines;
  int machinesNeverConnected;
  int machinesWithoutTelemetryBoard;
  List<MachineSortedByLastCollection> machinesSortedByLastCollection;
  List<MachineSortedByLastConnection> machinesSortedByLastConnection;
  List<MachineSortedByStock> machinesSortedByStock;
  List<IncomeMethodDistribution> incomeMethodDistributions;
  double income;
  int givenPrizesCount;
  List<PointOfSaleSortedByIncome> pointsOfSaleSortedByIncome;
  DateTime lastPurchaseDate;

  DetailedGroup.fromMap(Map<String, dynamic> json) {
    group = Group.fromMap(json['group']);
    lastPurchaseDate = json['lastPurchaseDate'] != null
        ? DateTime.parse(json['lastPurchaseDate'])
        : null;
    barChartData = List<ChartItem>.from(json['chartData1']
        .map((chartItem) => ChartItem.fromMap(chartItem))
        .toList());
    offlineMachines = json['offlineMachines'];
    onlineMachines = json['onlineMachines'];
    machinesNeverConnected = json['machinesNeverConnected'];
    machinesWithoutTelemetryBoard = json['machinesWithoutTelemetryBoard'];
    machinesSortedByLastCollection = List<MachineSortedByLastCollection>.from(
        json['machinesSortedByLastCollection']
            .map((e) => MachineSortedByLastCollection.fromMap(e))
            .toList());
    machinesSortedByLastConnection = List<MachineSortedByLastConnection>.from(
        json['machinesSortedByLastConnection']
            .map((e) => MachineSortedByLastConnection.fromMap(e))
            .toList());
    machinesSortedByStock = List<MachineSortedByStock>.from(
        json['machinesSortedByStock']
            .map((e) => MachineSortedByStock.fromMap(e))
            .toList());
    incomeMethodDistributions = List<IncomeMethodDistribution>.from(
        json['chartData2']
            .map((data) => IncomeMethodDistribution.fromMap(data))
            .toList());
    income = json['income'].toDouble();
    givenPrizesCount = json['givenPrizesCount'];
    pointsOfSaleSortedByIncome = json['pointsOfSaleSortedByIncome'] != null
        ? List<PointOfSaleSortedByIncome>.from(
            json['pointsOfSaleSortedByIncome']
                .map((pOs) => PointOfSaleSortedByIncome.fromMap(pOs))
                .toList())
        : null;
  }
}
