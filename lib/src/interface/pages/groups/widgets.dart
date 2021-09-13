import 'package:flutter/material.dart';
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
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Text(
              'Nome',
              style: styles.bold(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          Spacer(flex: 2),
          Expanded(
            flex: 6,
            child: Text(
              'Máquinas',
              style: styles.bold(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SingleGroup extends StatelessWidget {
  final int index;
  final String title;
  final int numberOfMachines;

  const SingleGroup({
    @required this.index,
    @required this.title,
    @required this.numberOfMachines,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
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
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Text(
              title,
              style: styles.regular(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          Spacer(flex: 2),
          Expanded(
            flex: 4,
            child: Text(
              numberOfMachines.toString(),
              style: styles.regular(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
