import 'package:black_telemetry/src/interface/shared/validators.dart';
import 'package:flutter/material.dart';

class DateRangePlaceHolder extends StatelessWidget {
  final DateTimeRange dateRange;

  const DateRangePlaceHolder({Key key, this.dateRange}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 47.5,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.lightBlack, width: 1),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              dateRange == null
                  ? 'De'
                  : getFormattedDate(dateRange.start).split(' -')[0],
            ),
          ),
        ),
        Container(
          width: 15,
          height: 1,
          margin: EdgeInsets.symmetric(horizontal: 7.5),
          color: colors.primaryColor,
        ),
        Expanded(
          child: Container(
            height: 47.5,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: colors.backgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.lightBlack, width: 1),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              dateRange == null
                  ? 'Até'
                  : getFormattedDate(dateRange.end).split(' -')[0],
            ),
          ),
        ),
      ],
    );
  }
}
