class Supply {
  String id;
  String label;
  String groupId;
  int quantity;
  double cost;

  Supply.fromJson(Map<String, dynamic> json, [String groupId]) {
    id = json['id'];
    this.groupId = groupId;
    label = json['label'];
    quantity = json['quantity'];
    cost = json['cost'];
  }
}
