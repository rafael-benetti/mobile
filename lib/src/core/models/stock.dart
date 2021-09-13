import 'prize.dart';
import 'supply.dart';

class Stock {
  List<Supply> supplies;
  List<Prize> prizes;

  Stock.fromJson(Map<String, dynamic> json, [String groupId]) {
    supplies = List<Supply>.from(json['supplies']
        .map((supply) => Supply.fromJson(supply, groupId))
        .toList());
    prizes = List<Prize>.from(
        json['prizes'].map((prize) => Prize.fromMap(prize, groupId)).toList());
  }
}
