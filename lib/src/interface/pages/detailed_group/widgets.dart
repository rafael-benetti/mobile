import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../src/core/models/detailed_group.dart';
import '../../../../src/core/models/income_method_distribution.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/detailed_point_of_sale/detailed_point_of_sale_page.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import 'dart:math' as math;
import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();
final chartColors = List.generate(
    30, (i) => Color((math.Random().nextDouble() * 0xFFFFFF).toInt()));

class DetailedGroupChart extends StatefulWidget {
  final Map<String, dynamic> setup;

  const DetailedGroupChart({Key key, this.setup}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DetailedGroupChartState();
}

class DetailedGroupChartState extends State<DetailedGroupChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: colors.backgroundColor,
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 37,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: BarChart(
                      sample(),
                      swapAnimationDuration: const Duration(milliseconds: 100),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartData sample() {
    return BarChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: widget.setup['maxY'] < 10
            ? 2
            : widget.setup['maxY'] < 50
                ? 5
                : widget.setup['maxY'] < 100
                    ? 10
                    : widget.setup['maxY'] < 500
                        ? 50
                        : widget.setup['maxY'] < 1000
                            ? 100
                            : widget.setup['maxY'] < 10000
                                ? 1000
                                : widget.setup['maxY'] < 100000
                                    ? 10000
                                    : 10000,
      ),
      barTouchData: BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.y.round().toString(),
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          getTextStyles: (bc, value) => TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          margin: 3,
          getTitles: (value) {
            if (widget.setup['period'] == 'DAILY') {
              if (value % 6 == 0) {
                var hour;
                if (widget.setup['xArray'][(value.toInt())].hour
                        .toString()
                        .length ==
                    1) {
                  hour = '0${widget.setup['xArray'][(value.toInt())].hour}';
                } else {
                  hour =
                      widget.setup['xArray'][(value.toInt())].hour.toString();
                }
                return '$hour:00';
              }
            } else if (widget.setup['period'] == 'WEEKLY') {
              var day;
              var month;
              if (widget.setup['xArray'][(value.toInt())].day
                      .toString()
                      .length ==
                  1) {
                day = '0${widget.setup['xArray'][(value.toInt())].day}';
              } else {
                day = widget.setup['xArray'][(value.toInt())].day.toString();
              }
              if (widget.setup['xArray'][(value.toInt())].month
                      .toString()
                      .length ==
                  1) {
                month = '0${widget.setup['xArray'][(value.toInt())].month}';
              } else {
                month =
                    widget.setup['xArray'][(value.toInt())].month.toString();
              }
              return '$day/$month';
            } else {
              if (value % 6 == 0) {
                var day;
                var month;
                if (widget.setup['xArray'][(value.toInt())].day
                        .toString()
                        .length ==
                    1) {
                  day = '0${widget.setup['xArray'][(value.toInt())].day}';
                } else {
                  day = widget.setup['xArray'][(value.toInt())].day.toString();
                }
                if (widget.setup['xArray'][(value.toInt())].month
                        .toString()
                        .length ==
                    1) {
                  month = '0${widget.setup['xArray'][(value.toInt())].month}';
                } else {
                  month =
                      widget.setup['xArray'][(value.toInt())].month.toString();
                }
                return '$day/$month';
              }
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (bc, value) => TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          getTitles: (value) {
            if (value == 0) {
              return '';
            }
            if (value == widget.setup['maxY']) {
              return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
            } else if (widget.setup['maxY'] <= 10) {
              return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
            } else if (widget.setup['maxY'] <= 50) {
              if (value % 5 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 100) {
              if (value % 10 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 1000) {
              if (value % 100 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 10000) {
              if (value % 1000 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 1000000) {
              if (value % 10000 == 0) {
                return '${value.toStringAsFixed(0).replaceAll('.', ',')}';
              }
            }
            return '';
          },
          margin: 5,
          reservedSize: 33,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 1,
          ),
          left: BorderSide(
            color: Color(0xff4e4965),
            width: 1,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      groupsSpace: 4,
      barGroups: data(),
      maxY: widget.setup['maxY'],
      minY: 0,
    );
  }

  List<BarChartGroupData> data() {
    return List.generate(
      widget.setup['incomeSpots'].length,
      (index) {
        return BarChartGroupData(
          x: index,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
                y: widget.setup['incomeSpots'][index].y +
                    widget.setup['prizesSpots'][index].y,
                rodStackItems: [
                  BarChartRodStackItem(
                      0, widget.setup['prizesSpots'][index].y, Colors.red),
                  BarChartRodStackItem(
                      widget.setup['prizesSpots'][index].y,
                      widget.setup['incomeSpots'][index].y +
                          widget.setup['prizesSpots'][index].y,
                      Colors.green),
                ],
                borderRadius: const BorderRadius.all(Radius.zero))
          ],
        );
      },
    );
  }
}

class DetailedGroupPieChart extends StatefulWidget {
  final List<IncomeMethodDistribution> incomeMethodDistributions;

  const DetailedGroupPieChart({Key key, this.incomeMethodDistributions})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => DetailedGroupPieChartState();
}

class DetailedGroupPieChartState extends State<DetailedGroupPieChart> {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: colors.backgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 250,
                child: PieChart(
                  PieChartData(
                    pieTouchData:
                        PieTouchData(touchCallback: (pieTouchResponse) {
                      setState(() {
                        final desiredTouch =
                            pieTouchResponse.touchInput is! PointerExitEvent &&
                                pieTouchResponse.touchInput is! PointerUpEvent;
                        if (desiredTouch &&
                            pieTouchResponse.touchedSection != null) {
                        } else {
                          touchedIndex = -1;
                        }
                      });
                    }),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 1,
                    centerSpaceRadius: 0,
                    sections: showingSections(widget.incomeMethodDistributions),
                  ),
                ),
              ),
            ),
            Container(
              height: 250,
              width: 90,
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.incomeMethodDistributions.length,
                  (index) {
                    return Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: chartColors[index].withOpacity(1.0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(widget
                            .incomeMethodDistributions[index].counterLabel),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      List<IncomeMethodDistribution> incomeMethodDistributions) {
    var total = 0.0;
    incomeMethodDistributions.forEach((element) {
      total += element.total;
    });
    return List.generate(incomeMethodDistributions.length, (index) {
      return PieChartSectionData(
        color: chartColors[index].withOpacity(1.0),
        value: incomeMethodDistributions[index].total,
        title:
            '${incomeMethodDistributions[index].counterLabel}\nR\$${incomeMethodDistributions[index].total.toStringAsFixed(2).replaceAll('.', ',')}\n${(incomeMethodDistributions[index].total / total * 100).toStringAsFixed(0)}%',
        radius: 100,
        titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    });
  }
}

class PointsOfSaleSortedByIncome extends StatelessWidget {
  final List<PointOfSaleSortedByIncome> pointsOfSaleSortedByIncome;

  const PointsOfSaleSortedByIncome({Key key, this.pointsOfSaleSortedByIncome})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          children: [
            Container(
              height: 30,
              padding: EdgeInsets.only(left: 7.5, right: 7.5),
              color: colors.primaryColor.withOpacity(0.3),
              alignment: Alignment.center,
              child: FittedBox(
                child: Text(
                  'Pontos de venda por faturamento',
                  style: styles.medium(),
                ),
              ),
            ),
            Container(
              height: 30,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 7.5, right: 7.5),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'PdV',
                        style: styles.medium(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            'No. de Máquinas',
                            style: styles.medium(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Total (R\$)',
                        style: styles.medium(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 0, color: Colors.black),
            Column(
              children: List.generate(
                pointsOfSaleSortedByIncome
                    .where(
                        (element) => int.parse(element.numberOfMachines) != 0)
                    .toList()
                    .length,
                (index) => GestureDetector(
                  onTap: () {
                    locator<InterfaceService>().navigateTo(
                        DetailedPointOfSalePage.route,
                        arguments: pointsOfSaleSortedByIncome
                            .where((element) =>
                                int.parse(element.numberOfMachines) != 0)
                            .toList()[index]
                            .id);
                  },
                  child: Container(
                    height: 30,
                    color: index % 2 == 0
                        ? colors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 7.5, right: 7.5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              pointsOfSaleSortedByIncome
                                  .where((element) =>
                                      int.parse(element.numberOfMachines) != 0)
                                  .toList()[index]
                                  .label,
                              style: styles.regular(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  pointsOfSaleSortedByIncome
                                      .where((element) =>
                                          int.parse(element.numberOfMachines) !=
                                          0)
                                      .toList()[index]
                                      .numberOfMachines,
                                  style: styles.regular(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'R\$ ${pointsOfSaleSortedByIncome[index].income.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: styles.regular(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
