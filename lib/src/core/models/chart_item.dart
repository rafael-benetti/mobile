class ChartItem {
  DateTime date;
  int prizeCount;
  double income;

  ChartItem.fromMap(Map<String, dynamic> json) {
    date = json['date'] != null ? DateTime.parse(json['date']).toLocal() : null;
    prizeCount = json['prizeCount'];
    income = double.parse(json['income'].toString());
  }
}
