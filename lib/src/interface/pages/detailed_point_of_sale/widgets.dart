import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../src/core/models/detailed_point_of_sale.dart';
import '../../../../src/core/models/machine.dart';
import '../../../../src/core/models/point_of_sale.dart';
import '../../../../src/core/models/route.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/detailed_machine/detailed_machine_page.dart';
import '../../../../src/interface/pages/detailed_route/detailed_route_page.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../shared/colors.dart';
import '../../shared/text_styles.dart';
import 'dart:math' as math;
import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();
final chartColors = List.generate(
    30, (i) => Color((math.Random().nextDouble() * 0xFFFFFF).toInt()));

class Operational extends StatelessWidget {
  final String groupLabel;
  final PointOfSale pointOfSale;

  const Operational({Key key, this.groupLabel, this.pointOfSale})
      : super(key: key);
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
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parceria'),
                    Text(groupLabel, style: styles.regular(fontSize: 12)),
                    SizedBox(height: 15),
                    Text('Endreço'),
                    Text(
                        '${pointOfSale.street}, ${pointOfSale.number}\n${pointOfSale.city} - ${pointOfSale.state}',
                        style: styles.regular(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aluguel'),
                    Text(
                        pointOfSale.isPercentage
                            ? '${pointOfSale.rent}%'
                            : 'R\$ ${pointOfSale.rent.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: styles.regular(fontSize: 12)),
                    SizedBox(height: 15),
                    Text('Responsável'),
                    Text(
                      '${pointOfSale.contactName}\n${convertPhoneNumberFromAPI(pointOfSale.primaryPhoneNumber)}',
                      style: styles.regular(fontSize: 12),
                    ),
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

class BelongsToRoute extends StatelessWidget {
  final OperatorRoute route;
  final Function removeFromRoute;
  final Function onAddToRoute;

  const BelongsToRoute({
    Key key,
    this.route,
    this.removeFromRoute,
    this.onAddToRoute,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rota',
                style: styles.medium(fontSize: 15),
              ),
              if (locator<UserProvider>().user.permissions.editRoutes)
                Row(
                  children: [
                    if (route != null)
                      GestureDetector(
                        onTap: removeFromRoute,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            'Remover desta rota',
                            style: styles.regular(
                                fontSize: 14, color: colors.primaryColor),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onAddToRoute,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Text(
                            'Adicionar a uma rota',
                            style: styles.regular(
                                fontSize: 14, color: colors.primaryColor),
                          ),
                        ),
                      )
                  ],
                ),
            ],
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: route != null
                ? () {
                    locator<InterfaceService>().navigateTo(
                        DetailedRoutePage.route,
                        arguments: route.id);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route != null ? route.label : '-',
                    style: styles.regular(
                        color: route != null ? Colors.blue : Colors.black),
                  ),
                  SizedBox(width: 3),
                  if (route != null)
                    Icon(
                      Feather.external_link,
                      color: Colors.blue,
                      size: 15,
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Machines extends StatelessWidget {
  final List<MachineInfo> machinesInfo;
  final Function onAddMachine;

  const Machines({Key key, this.machinesInfo, this.onAddMachine})
      : super(key: key);

  String getTotalInBoxes(Machine machine) {
    var total = 0.0;
    machine.boxes.forEach((element) {
      total += element.currentMoney;
    });
    return total.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Máquinas neste ponto',
                style: styles.medium(fontSize: 15),
              ),
              if (locator<UserProvider>().user.permissions.editMachines)
                GestureDetector(
                  onTap: onAddMachine,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      'Adicionar máquina',
                      style: styles.regular(
                          fontSize: 14, color: colors.primaryColor),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          if (machinesInfo.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 2, right: 5),
              child: Column(
                children: List.generate(
                  machinesInfo.length,
                  (index) => GestureDetector(
                    onTap: () {
                      locator<InterfaceService>().navigateTo(
                        DetailedMachinePage.route,
                        arguments: machinesInfo[index].machine.id,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(7.5),
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
                            children: [
                              Text(
                                'Número de série:',
                                style: styles.medium(fontSize: 14),
                              ),
                              SizedBox(width: 5),
                              Text(machinesInfo[index].machine.serialNumber),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Categoria:',
                                style: styles.medium(fontSize: 14),
                              ),
                              SizedBox(width: 5),
                              Text(machinesInfo[index].machine.categoryLabel),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Valor na máquina:',
                                style: styles.medium(fontSize: 14),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'R\$ ${getTotalInBoxes(machinesInfo[index].machine)}',
                                style: styles.regular(color: colors.lightGreen),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Última coleta:',
                                style: styles.medium(fontSize: 14),
                              ),
                              SizedBox(width: 5),
                              Text(
                                machinesInfo[index].machine.lastCollection !=
                                        null
                                    ? getFormattedDate(machinesInfo[index]
                                        .machine
                                        .lastCollection)
                                    : '-',
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Status:',
                                style: styles.medium(fontSize: 14),
                              ),
                              SizedBox(width: 5),
                              getTelemetryStatus(
                                  machinesInfo[index].telemetryBoard),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Text('-')
        ],
      ),
    );
  }
}

class DetailedPointOfSaleChart extends StatefulWidget {
  final Map<String, dynamic> setup;

  const DetailedPointOfSaleChart({Key key, this.setup}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DetailedPointOfSaleChartState();
}

class DetailedPointOfSaleChartState extends State<DetailedPointOfSaleChart> {
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

class DetailedPointOfSalePieChart extends StatefulWidget {
  final List<MachineInfo> machinesInfo;

  const DetailedPointOfSalePieChart({Key key, this.machinesInfo})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => DetailedPointOfSalePieChartState();
}

class DetailedPointOfSalePieChartState
    extends State<DetailedPointOfSalePieChart> {
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
                  sections: showingSections(widget.machinesInfo),
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
                widget.machinesInfo.length,
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
                            widget.machinesInfo[index].machine.serialNumber,
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

  List<PieChartSectionData> showingSections(List<MachineInfo> machinesInfo) {
    return List.generate(
      machinesInfo.length,
      (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 20.0 : 16.0;
        final radius = isTouched ? 110.0 : 100.0;
        var totalIncome = 0.0;
        machinesInfo.forEach((element) {
          totalIncome += element.income;
        });
        var percentualValue = machinesInfo[i].income != 0
            ? ((machinesInfo[i].income / totalIncome) * 100).toStringAsFixed(0)
            : 0;
        return PieChartSectionData(
          color: chartColors[i].withOpacity(1.0),
          value: totalIncome == 0
              ? (100 / machinesInfo.length)
              : (machinesInfo[i].income / totalIncome) * 100,
          title: machinesInfo[i].income == 0 && totalIncome != 0
              ? ''
              : 'R\$ ${machinesInfo[i].income.toStringAsFixed(2).replaceAll('.', ',')}\n$percentualValue%',
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
