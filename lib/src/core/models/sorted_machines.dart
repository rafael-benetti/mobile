class MachineSortedByLastCollection {
  String id;
  String serialNumber;
  String pointOfSaleLabel;
  DateTime lastCollection;

  MachineSortedByLastCollection.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    serialNumber = json['serialNumber'];
    pointOfSaleLabel =
        json['pointOfSale'] != null ? json['pointOfSale']['label'] : null;
    lastCollection = DateTime.parse(json['lastCollection']);
  }
}

class MachineSortedByLastConnection {
  String id;
  String serialNumber;
  String pointOfSaleLabel;
  DateTime lastConnection;

  MachineSortedByLastConnection.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    serialNumber = json['serialNumber'];
    pointOfSaleLabel =
        json['pointOfSale'] != null ? json['pointOfSale']['label'] : null;
    lastConnection = DateTime.parse(json['lastConnection']);
  }
}

class MachineSortedByStock {
  String id;
  String serialNumber;
  int total;
  int minimumPrizeCount;

  MachineSortedByStock.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    serialNumber = json['serialNumber'];
    total = json['total'];
    minimumPrizeCount = json['minimumPrizeCount'];
  }
}
