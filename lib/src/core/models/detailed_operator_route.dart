import '../../../src/core/models/point_of_sale.dart';
import '../../../src/core/models/route.dart';

import 'chart_item.dart';

class PieChartItem {
  String pointOfSaleId;
  String label;
  double income;

  PieChartItem.fromMap(Map<String, dynamic> json) {
    pointOfSaleId = json['pointOfSaleId'];
    label = json['label'];
    income = json['income'].toDouble();
  }
}

class DetailedRouteMachine {
  String id;
  String serialNumber;
  String pointOfSaleLabel;
  DateTime lastCollection;

  DetailedRouteMachine.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    serialNumber = json['serialNumber'];
    pointOfSaleLabel = json['pointOfSale']['label'];
    lastCollection = json['lastCollection'] != null
        ? DateTime.parse(json['lastCollection'])
        : null;
  }
}

class DetailedOperatorRoute {
  OperatorRoute route;
  String operatorName;
  List<PointOfSale> pointsOfSale;
  double income;
  int givenPrizesCount;
  List<DetailedRouteMachine> machines;
  List<ChartItem> chartData;
  List<PieChartItem> pieChartData;

  DetailedOperatorRoute.fromMap(Map<String, dynamic> json) {
    route =
        json['route'] != null ? OperatorRoute.fromJson(json['route']) : null;
    operatorName = json['operator'] != null ? json['operator']['name'] : null;
    income = json['income'].toDouble();
    machines = json['machines'] != null
        ? List<DetailedRouteMachine>.from(json['machines']
            .map((machine) => DetailedRouteMachine.fromMap(machine))
            .toList())
        : <DetailedRouteMachine>[];
    pointsOfSale = List<PointOfSale>.from(json['pointsOfSale']
        .map((pointOfSale) => PointOfSale.fromMap(pointOfSale))
        .toList());
    givenPrizesCount = json['givenPrizesCount'];
    chartData = List<ChartItem>.from(json['chartData1']
        .map((chartItem) => ChartItem.fromMap(chartItem))
        .toList());
    pieChartData = List<PieChartItem>.from(json['chartData2']
        .map((chartItem) => PieChartItem.fromMap(chartItem))
        .toList());
  }
}
