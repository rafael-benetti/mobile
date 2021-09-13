import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/shared/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class MachinesStatuses extends StatelessWidget {
  final int onlineMachines;
  final int offlineMachines;
  final int machinesNeverConnected;
  final int machinesWithoutTelemetryBoard;

  const MachinesStatuses({
    this.onlineMachines,
    this.offlineMachines,
    this.machinesNeverConnected,
    this.machinesWithoutTelemetryBoard,
  });
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Máquinas',
            style: styles.medium(fontSize: 14),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: colors.lightBlack),
                    color: colors.backgroundColor,
                  ),
                  padding: EdgeInsets.fromLTRB(5, 7.5, 5, 7.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Feather.wifi,
                        color: colors.lightGreen,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Online',
                              style: styles.medium(fontSize: 14),
                            ),
                            FittedBox(
                              child: Text(
                                onlineMachines.toString(),
                                style: styles.regular(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7.5),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: colors.lightBlack),
                    color: colors.backgroundColor,
                  ),
                  padding: EdgeInsets.fromLTRB(5, 7.5, 5, 7.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Feather.wifi_off,
                        color: colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline',
                              style: styles.medium(fontSize: 14),
                            ),
                            FittedBox(
                              child: Text(
                                offlineMachines.toString(),
                                style: styles.regular(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: colors.lightBlack),
                    color: colors.backgroundColor,
                  ),
                  padding: EdgeInsets.fromLTRB(5, 7.5, 5, 7.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nunca conectadas',
                              style: styles.medium(fontSize: 14),
                            ),
                            FittedBox(
                              child: Text(
                                machinesNeverConnected.toString(),
                                style: styles.regular(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 7.5),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.2, color: colors.lightBlack),
                    color: colors.backgroundColor,
                  ),
                  padding: EdgeInsets.fromLTRB(5, 7.5, 5, 7.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Feather.shield_off,
                        color: Colors.black,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sem telemetria',
                              style: styles.medium(fontSize: 14),
                            ),
                            FittedBox(
                              child: Text(
                                machinesWithoutTelemetryBoard.toString(),
                                style: styles.regular(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
