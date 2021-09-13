import '../../../src/core/models/sorted_machines.dart';

import 'chart_item.dart';
import 'income_method_distribution.dart';

class Dashboard {
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

  Dashboard.fromMap(Map<String, dynamic> json) {
    barChartData = json['chartData1'] != null
        ? List<ChartItem>.from(json['chartData1']
            .map((chartItem) => ChartItem.fromMap(chartItem))
            .toList())
        : null;
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
    incomeMethodDistributions = json['chartData2'] != null
        ? List<IncomeMethodDistribution>.from(json['chartData2']
            .map((data) => IncomeMethodDistribution.fromMap(data))
            .toList())
        : null;
    income = json['income'] != null ? json['income'].toDouble() : null;
    givenPrizesCount = json['givenPrizesCount'];
  }
}
