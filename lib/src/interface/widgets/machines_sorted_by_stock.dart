import 'package:black_telemetry/src/core/models/sorted_machines.dart';
import 'package:black_telemetry/src/core/services/interface_service.dart';
import 'package:black_telemetry/src/interface/pages/detailed_machine/detailed_machine_page.dart';
import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/shared/text_styles.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class MachinesSortedByStock extends StatelessWidget {
  final List<MachineSortedByStock> machinesSortedByStock;

  const MachinesSortedByStock({Key key, this.machinesSortedByStock})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        child: Column(
          children: [
            Container(
              height: 30,
              padding: EdgeInsets.only(left: 7.5),
              color: colors.primaryColor.withOpacity(0.3),
              alignment: Alignment.center,
              child: FittedBox(
                child: Text(
                  'Máquinas com pouco estoque',
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
                          'Mínimo',
                          style: styles.medium(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Atual',
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
                machinesSortedByStock.length,
                (index) => GestureDetector(
                  onTap: () {
                    locator<InterfaceService>().navigateTo(
                        DetailedMachinePage.route,
                        arguments: machinesSortedByStock[index].id);
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
                              machinesSortedByStock[index].serialNumber,
                              style: styles.regular(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  machinesSortedByStock[index]
                                      .minimumPrizeCount
                                      .toString(),
                                  style: styles.regular(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              machinesSortedByStock[index].total.toString(),
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
