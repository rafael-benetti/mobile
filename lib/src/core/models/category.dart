import 'box.dart';

class Category {
  String id;
  String ownerId;
  String label;
  List<Box> boxes;

  Category() {
    boxes = [];
  }

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    boxes =
        List<Box>.from(json['boxes'].map((box) => Box.fromMap(box)).toList());
    ownerId = json['ownerId'];
  }

  Map<String, dynamic> toMap([bool creatingMachine]) {
    return {
      'label': label,
      'boxes': List.generate(
        boxes.length,
        (index) => boxes[index].toMap(creatingMachine),
      )
    };
  }
}
