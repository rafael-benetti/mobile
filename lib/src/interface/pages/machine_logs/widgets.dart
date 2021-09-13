import 'package:flutter/material.dart';
import '../../../../src/core/models/detailed_machine.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';

import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class MachineLogCard extends StatelessWidget {
  final MachineLog machineLog;
  final Function(String) popObservationsDialog;

  const MachineLogCard({Key key, this.machineLog, this.popObservationsDialog})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => popObservationsDialog(machineLog.observations),
      child: Container(
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
                    color: machineLog.type == 'REMOTE_CREDIT'
                        ? colors.lightGreen.withOpacity(0.5)
                        : Colors.amber.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Icon(
                      machineLog.type == 'REMOTE_CREDIT'
                          ? Icons.attach_money_outlined
                          : Icons.auto_fix_high,
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
                  Text(
                    machineLog.type == 'REMOTE_CREDIT'
                        ? 'Crédito Remoto'
                        : 'Correção de estoque',
                    style: styles.medium(fontSize: 14),
                  ),
                  Text(
                    machineLog.type == 'REMOTE_CREDIT'
                        ? 'R\$ ${machineLog.value.toStringAsFixed(2).replaceAll('.', ',')}'
                        : '${machineLog.value.toStringAsFixed(0)}',
                    style: styles.regular(
                        fontSize: 14,
                        color: machineLog.type == 'REMOTE_CREDIT'
                            ? colors.lightGreen
                            : Colors.amber),
                  ),
                  SizedBox(height: 5),
                  Text(
                    machineLog.type == 'REMOTE_CREDIT'
                        ? 'Crédito remoto por: ${machineLog.user}'
                        : 'Correção feita por: ${machineLog.user}',
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getFormattedDate(machineLog.date).split(' ')[0],
                      style: styles.regular(
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      getFormattedDate(machineLog.date).split(' ')[2],
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
      ),
    );
  }
}

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
            DropdownInputOption(
                title: 'Crédito Remoto', option: 'REMOTE_CREDIT'),
            DropdownInputOption(
                title: 'Correção de estoque', option: 'FIX_STOCK'),
          ],
        ),
      ],
    );
  }
}
