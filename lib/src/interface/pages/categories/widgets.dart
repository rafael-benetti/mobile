import 'package:flutter/material.dart';
import '../../../core/models/category.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class TableName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              color: Colors.black12, style: BorderStyle.solid, width: 0.5),
          right: BorderSide(
              color: Colors.black12, style: BorderStyle.solid, width: 0.5),
          top: BorderSide(
              color: Colors.black26, style: BorderStyle.solid, width: 0.5),
          bottom: BorderSide(
              color: Colors.black26, style: BorderStyle.solid, width: 0.5),
        ),
      ),
      padding: EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      child: Text(
        'Nome',
        style: styles.bold(fontSize: 15),
      ),
    );
  }
}

class SingleCategory extends StatelessWidget {
  final int index;
  final Category category;

  const SingleCategory({@required this.index, @required this.category});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: index % 2 == 0
            ? Color.fromRGBO(245, 247, 250, 0.5)
            : colors.backgroundColor,
        border: Border(
          left: BorderSide(
              color: Colors.black12, style: BorderStyle.solid, width: 0.5),
          right: BorderSide(
              color: Colors.black12, style: BorderStyle.solid, width: 0.5),
          bottom: BorderSide(
              color: Colors.black12, style: BorderStyle.solid, width: 0.5),
        ),
      ),
      padding: EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      child: Text(
        category.label,
        style: styles.regular(fontSize: 14),
      ),
    );
  }
}
