import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../src/core/models/detailed_operator_route.dart';
import '../../../../src/core/models/point_of_sale.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/detailed_point_of_sale/detailed_point_of_sale_page.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/shared/validators.dart';
import 'dart:math' as math;
import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();
final chartColors = List.generate(
    30, (i) => Color((math.Random().nextDouble() * 0xFFFFFF).toInt()));

class Operational extends StatelessWidget {
  final String operatorName;

  const Operational({
    Key key,
    this.operatorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'OPERACIONAL',
            style: styles.medium(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text('Operador responsável'),
          SizedBox(height: 10),
          Text(operatorName ?? '-', style: styles.regular(fontSize: 12))
        ],
      ),
    );
  }
}

class PointsOfSale extends StatelessWidget {
  final List<PointOfSale> pointsOfSale;

  const PointsOfSale({Key key, this.pointsOfSale}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Pontos de venda',
            style: styles.medium(fontSize: 15),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 2, right: 5),
            child: Column(
              children: List.generate(
                pointsOfSale.length,
                (index) => GestureDetector(
                  onTap: () {
                    if (locator<UserProvider>().user.role != Role.OPERATOR) {
                      locator<InterfaceService>().navigateTo(
                        DetailedPointOfSalePage.route,
                        arguments: pointsOfSale[index].id,
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pointsOfSale[index].label,
                          style: styles.medium(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              flex: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Endereço'),
                                  Text(
                                    '${pointsOfSale[index].street}, ${pointsOfSale[index].number}\n${pointsOfSale[index].city} - ${pointsOfSale[index].state}',
                                    style: styles.regular(fontSize: 13),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Responsável'),
                                  Text(
                                    '${pointsOfSale[index].contactName}\n${convertPhoneNumberFromAPI(pointsOfSale[index].primaryPhoneNumber)}',
                                    style: styles.regular(fontSize: 13),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DetailedRouteChart extends StatefulWidget {
  final Map<String, dynamic> setup;

  const DetailedRouteChart({Key key, this.setup}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DetailedRouteChartState();
}

class DetailedRouteChartState extends State<DetailedRouteChart> {
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
          reservedSize: 15,
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
          reservedSize: 30,
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

class DetailedRoutePieChart extends StatefulWidget {
  final List<PieChartItem> pieChartData;

  const DetailedRoutePieChart({Key key, this.pieChartData}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DetailedRoutePieChartState();
}

class DetailedRoutePieChartState extends State<DetailedRoutePieChart> {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
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
                  sections: showingSections(widget.pieChartData),
                ),
              ),
            ),
          ),
          Container(
            height: 250,
            width: 90,
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.pieChartData.length,
                (index) => Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: chartColors[index].withOpacity(1.0),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.pieChartData[index].label,
                            style: styles.regular(fontSize: 10),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<PieChartItem> pieChartData) {
    return List.generate(
      pieChartData.length,
      (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 20.0 : 16.0;
        final radius = isTouched ? 110.0 : 100.0;
        var totalIncome = 0.0;
        pieChartData.forEach((element) {
          totalIncome += element.income;
        });
        var percentualValue = pieChartData[i].income != 0
            ? ((pieChartData[i].income / totalIncome) * 100).toStringAsFixed(0)
            : 0;
        return PieChartSectionData(
          color: chartColors[i].withOpacity(1.0),
          value: totalIncome == 0
              ? (100 / pieChartData.length)
              : (pieChartData[i].income / totalIncome) * 100,
          title: pieChartData[i].income == 0 && totalIncome != 0
              ? ''
              : 'R\$ ${pieChartData[i].income.toStringAsFixed(2).replaceAll('.', ',')}\n$percentualValue%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff)),
        );
      },
    );
  }
}

class Machines extends StatelessWidget {
  final List<DetailedRouteMachine> machines;

  const Machines({Key key, this.machines}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          'Máquinas',
          style: styles.medium(fontSize: 15),
        ),
        SizedBox(height: 5),
        Card(
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
                      'Ordenadas pela data da coleta',
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
                          child: FittedBox(
                            child: Text(
                              'No. de série',
                              style: styles.medium(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Center(
                            child: Text(
                              'PdV',
                              style: styles.medium(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Última coleta',
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
                    machines.length,
                    (index) => GestureDetector(
                      onTap: () {},
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
                                  machines[index].serialNumber,
                                  style: styles.regular(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Center(
                                  child: Text(
                                    machines[index].pointOfSaleLabel,
                                    style: styles.regular(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  getFormattedDate(
                                          machines[index].lastCollection)
                                      .split('-')[0],
                                  style: styles.regular(fontSize: 12),
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
        ),
      ],
    );
  }
}
