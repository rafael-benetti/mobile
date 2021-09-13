class IncomeMethodDistribution {
  String counterLabel;
  double total;
  IncomeMethodDistribution.fromMap(Map<String, dynamic> json) {
    total = json['total'].toDouble();
    counterLabel = json['counterLabel'];
  }
}
