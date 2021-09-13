import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../src/core/models/detailed_machine.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';

import '../../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class TypeSelector extends StatelessWidget {
  final Function onSelect;

  const TypeSelector({Key key, this.onSelect}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de evento',
          style: styles.light(fontSize: 16),
        ),
        SizedBox(height: 7.5),
        CustomDropdownButton(
          initialValue: DropdownInputOption(title: 'Todos'),
          onSelect: onSelect,
          values: [
            DropdownInputOption(title: 'Todos'),
            DropdownInputOption(title: 'Crédito', option: 'IN'),
            DropdownInputOption(title: 'Prêmio', option: 'OUT'),
          ],
        ),
      ],
    );
  }
}

class TelemetryLogCard extends StatelessWidget {
  final TelemetryLog telemetryLog;

  const TelemetryLogCard({Key key, this.telemetryLog}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 7.5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(1, 1),
            color: colors.mediumBlack,
            blurRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: telemetryLog.type == 'IN'
                      ? colors.lightGreen.withOpacity(0.5)
                      : colors.red.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Icon(
                    telemetryLog.type == 'IN'
                        ? Icons.attach_money_outlined
                        : Feather.shopping_bag,
                    size: 25,
                    color: colors.backgroundColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      telemetryLog.type == 'IN' ? 'Crédito' : 'Prêmio',
                      style: styles.medium(fontSize: 18),
                    ),
                    if (telemetryLog.offline)
                      FittedBox(
                        child: Text(
                          ' (offline)',
                          style: styles.medium(color: colors.red),
                        ),
                      ),
                  ],
                ),
                Text(
                  telemetryLog.type == 'IN'
                      ? 'R\$ ${telemetryLog.value.toStringAsFixed(2).replaceAll('.', ',')}'
                      : '${telemetryLog.value.toStringAsFixed(0)}',
                  style: styles.regular(
                      fontSize: 14,
                      color: telemetryLog.type == 'IN'
                          ? colors.lightGreen
                          : colors.red),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Row(
            children: [
              if (telemetryLog.maintenance)
                Icon(
                  Icons.construction,
                ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getFormattedDate(telemetryLog.date).split(' ')[0],
                    style: styles.regular(
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    getFormattedDate(telemetryLog.date).split(' ')[2],
                    style: styles.regular(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
