import 'package:black_telemetry/src/interface/shared/validators.dart';
import 'package:flutter/material.dart';
import '../../core/models/group.dart';
import '../../core/models/machine.dart';
import '../../core/models/point_of_sale.dart';
import '../../core/models/telemetry_board.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';

import '../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class MachineCard extends StatelessWidget {
  final Machine machine;
  final List<Group> groups;
  final List<PointOfSale> pointsOfSale;
  final List<TelemetryBoard> telemetryBoards;
  final bool stockPage;

  const MachineCard({
    Key key,
    @required this.machine,
    @required this.groups,
    @required this.telemetryBoards,
    @required this.pointsOfSale,
    @required this.stockPage,
  }) : super(key: key);

  TelemetryBoard getTelemetryBoard() {
    if (machine.telemetryBoardId != null) {
      return telemetryBoards
          .firstWhere((element) => element.id == machine.telemetryBoardId);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Num. Série:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    machine.serialNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Operador:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    machine.operatorName ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Categoria:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Text(
                    machine.categoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          if (groups.length > 1)
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        'Parceria:',
                        style: styles.medium(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        child: Text(
                          groups
                              .firstWhere(
                                  (element) => element.id == machine.groupId)
                              .label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 7.5),
              ],
            ),
          if (!stockPage)
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        'Localização:',
                        style: styles.medium(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        child: Text(
                          machine.locationId == null
                              ? 'Em estoque'
                              : pointsOfSale
                                  .firstWhere((element) =>
                                      element.id == machine.locationId)
                                  .label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.regular(
                            color: machine.locationId == null
                                ? Colors.amber
                                : Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 7.5),
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Prêmios entregues:',
                      style: styles.medium(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Row(
                    children: [
                      Text(
                        machine.givenPrizes.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 7.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: Text(
                  'Telemetria:',
                  style: styles.medium(fontSize: 16),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (machine.telemetryBoardId == null)
                        Text('-')
                      else
                        Row(
                          children: [
                            getTelemetryIconFromMachineLastConnection(
                                machine.lastConnection),
                            SizedBox(width: 5),
                            if (getTelemetryBoard() != null)
                              Text('(STG-${getTelemetryBoard().id})')
                          ],
                        ),
                      Row(
                        children: [
                          Text(
                            'Visão geral',
                            style: styles.regular(color: colors.primaryColor),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: colors.primaryColor,
                            size: 15,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
