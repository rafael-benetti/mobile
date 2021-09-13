import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';

import '../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class StockItem extends StatelessWidget {
  final dynamic stockItem;
  final String groupLabel;
  final int numberOfGroups;

  const StockItem({
    Key key,
    @required this.stockItem,
    @required this.numberOfGroups,
    @required this.groupLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: colors.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            color: colors.lightBlack,
            offset: Offset(1, 1),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Nome:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    stockItem.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Quantidade:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    stockItem.quantity.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          if (numberOfGroups > 1)
            Column(
              children: [
                SizedBox(height: 7.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        'Parceria:',
                        style: styles.medium(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        child: Text(
                          groupLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )
        ],
      ),
    );
  }
}
