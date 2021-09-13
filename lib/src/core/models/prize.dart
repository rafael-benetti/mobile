class Prize {
  String id;
  String groupId;
  String label;
  int quantity;

  Prize.fromMap(Map<String, dynamic> json, [String groupId]) {
    id = json['id'];
    this.groupId = groupId;
    label = json['label'];
    quantity = json['quantity'];
  }
}
