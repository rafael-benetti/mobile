import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/shared/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class DataPerPeriod extends StatelessWidget {
  final double incomePerPeriod;
  final int givenPrizesPerPeriod;

  const DataPerPeriod(
      {Key key, this.incomePerPeriod, this.givenPrizesPerPeriod})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: colors.lightBlack),
                    color: colors.backgroundColor,
                  ),
                  padding: EdgeInsets.fromLTRB(5, 7.5, 5, 7.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Feather.dollar_sign,
                        color: colors.lightGreen,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Text(
                                'Faturamento',
                                style: styles.medium(fontSize: 14),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                'R\$ ${incomePerPeriod.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: styles.regular(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7.5),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: colors.lightBlack),
                    color: colors.backgroundColor,
                  ),
                  padding: EdgeInsets.fromLTRB(5, 7.5, 5, 7.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Feather.shopping_bag,
                        color: colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              child: Text(
                                'Prêmios entregues',
                                style: styles.medium(fontSize: 14),
                              ),
                            ),
                            Text(
                              givenPrizesPerPeriod.toString(),
                              style: styles.regular(fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
