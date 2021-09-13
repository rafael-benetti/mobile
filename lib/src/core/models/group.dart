import 'stock.dart';

class Group {
  String id;
  String label;
  bool isPersonal;
  int numberOfMachines;
  Stock stock;

  Group.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    isPersonal = json['isPersonal'];
    numberOfMachines = json['numberOfMachines'];
    stock = Stock.fromJson(json['stock'], id);
    if (isPersonal) {
      label = 'Parceria Pessoal';
    }
  }
}
