import 'package:black_telemetry/src/core/models/sorted_machines.dart';
import 'package:black_telemetry/src/core/services/interface_service.dart';
import 'package:black_telemetry/src/interface/pages/detailed_machine/detailed_machine_page.dart';
import 'package:black_telemetry/src/interface/shared/validators.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';

class MachinesSortedByLastConnection extends StatelessWidget {
  final List<MachineSortedByLastConnection> machinesSortedByLastConnection;

  const MachinesSortedByLastConnection(
      {Key key, this.machinesSortedByLastConnection})
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
                  'Máquinas com maior tempo sem comunicação',
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
                        'Tempo',
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
                machinesSortedByLastConnection.length,
                (index) => GestureDetector(
                  onTap: () {
                    locator<InterfaceService>().navigateTo(
                        DetailedMachinePage.route,
                        arguments: machinesSortedByLastConnection[index].id);
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
                              machinesSortedByLastConnection[index]
                                  .serialNumber,
                              style: styles.regular(),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Center(
                              child: Text(
                                machinesSortedByLastConnection[index]
                                        .pointOfSaleLabel ??
                                    '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.regular(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              getElapsedTime(
                                  machinesSortedByLastConnection[index]
                                      .lastConnection),
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
