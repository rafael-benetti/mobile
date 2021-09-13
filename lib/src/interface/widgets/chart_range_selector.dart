import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../shared/enums.dart';
import '../shared/text_styles.dart';
import '../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class ChartRangeSelector extends StatefulWidget {
  final Function(RangeSelector) onSelect;

  const ChartRangeSelector({this.onSelect});

  @override
  _ChartRangeSelectorState createState() => _ChartRangeSelectorState();
}

class _ChartRangeSelectorState extends State<ChartRangeSelector> {
  int selector = 0;
  @override
  Widget build(BuildContext context) {
    final selectorList = [
      RangeSelector.DAILY,
      RangeSelector.WEEKLY,
      RangeSelector.MONTHLY
    ];

    String translateEnum(RangeSelector option) {
      switch (option) {
        case RangeSelector.DAILY:
          return 'Diário';
        case RangeSelector.WEEKLY:
          return 'Semanal';
        case RangeSelector.MONTHLY:
          return 'Mensal';

        default:
          return '';
      }
    }

    return Container(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Row(
          children: List.generate(
              selectorList.length,
              (index) => Padding(
                    padding: EdgeInsets.only(
                      left: index != 0 ? 10 : 0,
                      right: 10,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        widget.onSelect(selectorList[index]);
                        setState(() {
                          selector = index;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
                        child: Text(
                          translateEnum(selectorList[index]),
                          style: styles.medium(
                            color: selector == index
                                ? colors.primaryColor
                                : Color.fromRGBO(43, 43, 43, 0.7),
                          ),
                        ),
                      ),
                    ),
                  )),
        ));
  }
}
