import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/shared/text_styles.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class PeriodSelector extends StatefulWidget {
  final Function onPeriodSelected;
  final double currentPadding;

  const PeriodSelector({Key key, this.onPeriodSelected, this.currentPadding})
      : super(key: key);
  @override
  _PeriodSelectorState createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'GERENCIAL',
            style: styles.medium(fontSize: 16),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                height: 25,
                width: 225,
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    AnimatedContainer(
                      height: 25,
                      width: 75,
                      duration: Duration(milliseconds: 150),
                      curve: Curves.linear,
                      margin: EdgeInsets.only(left: widget.currentPadding),
                      decoration: BoxDecoration(
                        color: colors.primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.onPeriodSelected('DAILY', 0.0);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 150),
                            height: 25,
                            width: 75,
                            child: Center(
                              child: Text(
                                'Diário',
                                style: styles.regular(
                                  fontSize: 13,
                                  color: widget.currentPadding == 0
                                      ? colors.backgroundColor
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.onPeriodSelected('WEEKLY', 75.0);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 150),
                            height: 25,
                            width: 75,
                            child: Center(
                              child: Text(
                                'Semanal',
                                style: styles.regular(
                                  fontSize: 13,
                                  color: widget.currentPadding == 75
                                      ? colors.backgroundColor
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            widget.onPeriodSelected('MONTHLY', 150.0);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 150),
                            height: 25,
                            width: 75,
                            child: Center(
                              child: Text(
                                'Mensal',
                                style: styles.regular(
                                  fontSize: 13,
                                  color: widget.currentPadding == 150
                                      ? colors.backgroundColor
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
