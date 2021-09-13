import 'counter.dart';

class Box {
  String id;
  int numberOfPrizes;
  double currentMoney;
  List<Counter> counters;

  Box([String bId]) {
    id = bId;
    counters = [];
  }

  Box.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    numberOfPrizes = json['numberOfPrizes'];
    counters = List<Counter>.from(
        json['counters'].map((counter) => Counter.fromJson(counter)).toList());
    currentMoney = double.parse(json['currentMoney'].toString());
  }

  Map<String, dynamic> toMap([bool creatingMachine]) {
    var result = {
      'counters': List.generate(
        counters.length,
        (index) => counters[index].toMap(creatingMachine),
      ),
      'id': id,
    };
    if (id == null || (creatingMachine != null && creatingMachine)) {
      result.remove('id');
    }
    return result;
  }
}
