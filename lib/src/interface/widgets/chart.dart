import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../shared/enums.dart';
import '../shared/text_styles.dart';

import '../../locator.dart';

var styles = locator<TextStyles>();

class Chart extends StatefulWidget {
  final RangeSelector range;

  const Chart({@required this.range});
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: 0.5,
                      spreadRadius: 0.5,
                      offset: Offset(0, 0),
                      color: Colors.black12)
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 25, left: 25, top: 24, bottom: 12),
                child: LineChart(mainData()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.black26,
            strokeWidth: 0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          getTextStyles: (bc, d) => styles.regular(
            color: Color(0xff68737d),
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                if (widget.range == RangeSelector.DAILY) {
                  return '00:00';
                } else if (widget.range == RangeSelector.WEEKLY) {
                  return '${DateTime.now().subtract(Duration(days: 7)).day}/${DateTime.now().subtract(Duration(days: 7)).month}';
                }
                return '${DateTime.now().subtract(Duration(days: 25)).day}/${DateTime.now().subtract(Duration(days: 25)).month}';

              case 3:
                if (widget.range == RangeSelector.DAILY) {
                  return '08:00';
                } else if (widget.range == RangeSelector.WEEKLY) {
                  return '${DateTime.now().subtract(Duration(days: 5)).day}/${DateTime.now().subtract(Duration(days: 5)).month}';
                }
                return '${DateTime.now().subtract(Duration(days: 17)).day}/${DateTime.now().subtract(Duration(days: 17)).month}';

              case 7:
                if (widget.range == RangeSelector.DAILY) {
                  return '16:00';
                } else if (widget.range == RangeSelector.WEEKLY) {
                  return '${DateTime.now().subtract(Duration(days: 3)).day}/${DateTime.now().subtract(Duration(days: 3)).month}';
                }
                return '${DateTime.now().subtract(Duration(days: 9)).day}/${DateTime.now().subtract(Duration(days: 9)).month}';

              case 11:
                if (widget.range == RangeSelector.DAILY) return '23:59';
                return '${DateTime.now().subtract(Duration(days: 1)).day}/${DateTime.now().subtract(Duration(days: 1)).month}';
            }
            return '';
          },
          margin: 14,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (bc, d) => styles.regular(
            color: Color(0xff68737d),
            fontSize: 12,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 1:
                return '1,00';
              case 2:
                return '2,00';
              case 3:
                return '3,00';
              case 4:
                return '4,00';
              case 5:
                return '5,00';
            }
            return '';
          },
          reservedSize: 24,
          margin: 16,
        ),
      ),
      borderData: FlBorderData(
        show: false,
        // border: Border(
        //   bottom: BorderSide(color: colors.lightBack, width: 1),
        //   left: BorderSide(color: colors.lightBack, width: 1),
        //   top: BorderSide(color: colors.lightBack, width: 1),
        //   right: BorderSide(color: colors.lightBack, width: 1),
        // ),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          colors: [
            Color(0xff7366ff),
          ],
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: [Color(0xff7366ff).withOpacity(0.4)],
          ),
        ),
      ],
    );
  }
}
