import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../../src/core/models/detailed_machine.dart';
import '../../../../src/core/models/machine.dart';
import '../../../../src/core/models/telemetry_board.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/detailed_point_of_sale/detailed_point_of_sale_page.dart';
import '../../../../src/interface/pages/group_stock/group_stock_page.dart';
import '../../../../src/interface/pages/machine_logs/machine_logs_page.dart';
import '../../../../src/interface/pages/telemetry_logs/telemetry_logs_page.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/text_styles.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../../src/interface/widgets/custom_text_field.dart';
import '../../../../src/interface/widgets/icon_translator.dart';

import '../../../locator.dart';

final colors = locator<AppColors>();
final styles = locator<TextStyles>();

class TripleButtons extends StatelessWidget {
  final Function createCollection;
  final Function addRemoteCredit;
  final Function moveMachine;

  const TripleButtons(
      {Key key, this.createCollection, this.addRemoteCredit, this.moveMachine})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton(
              onPressed: createCollection,
              style: ElevatedButton.styleFrom(
                primary: colors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)),
              ),
              child: Text('Realizar coleta'),
            ),
          ),
          SizedBox(height: 7.5),
          Row(
            children: [
              if (addRemoteCredit != null)
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      onPressed: addRemoteCredit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                        primary: colors.darkGreen,
                      ),
                      child: Text('Crédito remoto'),
                    ),
                  ),
                ),
              if (addRemoteCredit != null && moveMachine != null)
                SizedBox(width: 7.5),
              if (moveMachine != null)
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      onPressed: moveMachine,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      child: Text('Mover máquina'),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}

class General extends StatelessWidget {
  final DateTime lastConnection;
  final DateTime lastCollection;
  final bool isMaintenance;
  final Function changeIsMaintenance;
  final TelemetryBoard telemetryBoard;
  final String collectedBy;

  const General({
    Key key,
    this.lastConnection,
    this.lastCollection,
    this.isMaintenance,
    this.collectedBy,
    this.changeIsMaintenance,
    this.telemetryBoard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GERAL',
                style: styles.medium(fontSize: 16),
              ),
              if (locator<UserProvider>()
                  .user
                  .permissions
                  .toggleMaintenanceMode)
                Row(
                  children: [
                    Text(
                      'Modo manutenção',
                      style: styles.regular(fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        value: isMaintenance,
                        activeColor: colors.primaryColor,
                        onChanged: (value) {
                          changeIsMaintenance(value);
                        },
                      ),
                    ),
                  ],
                )
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
                        Icons.wifi_tethering_rounded,
                        color: checkIfTelemetryIsOnline(telemetryBoard)
                            ? colors.lightGreen
                            : colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Última conexão',
                              style: styles.medium(fontSize: 14),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Status: ',
                                  style: styles.regular(fontSize: 13),
                                ),
                                if (telemetryBoard != null)
                                  Expanded(
                                    child: getTelemetryStatus(telemetryBoard),
                                  )
                                else
                                  Expanded(
                                    child: FittedBox(
                                      child: Text('Sem telemetria'),
                                    ),
                                  )
                              ],
                            ),
                            if (lastConnection != null)
                              FittedBox(
                                child: Text(
                                  getFormattedDate(lastConnection.toLocal()),
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
                        Feather.pocket,
                        color: Colors.blue,
                        size: 25,
                      ),
                      SizedBox(width: 7.5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Última coleta',
                              style: styles.medium(fontSize: 14),
                            ),
                            FittedBox(
                              child: Text(
                                lastCollection != null
                                    ? getFormattedDate(lastCollection.toLocal())
                                    : 'Nunca feita',
                                style: styles.regular(fontSize: 13),
                              ),
                            ),
                            if (lastCollection != null)
                              Row(
                                children: [
                                  Text(
                                    'Feita por: ',
                                    style: styles.regular(fontSize: 13),
                                  ),
                                  if (collectedBy != null)
                                    Expanded(
                                      child: Text(
                                        collectedBy,
                                        overflow: TextOverflow.ellipsis,
                                        style: styles.regular(fontSize: 13),
                                      ),
                                    )
                                  else
                                    Text(
                                      '-',
                                      style: styles.regular(fontSize: 13),
                                    ),
                                ],
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

class Operational extends StatelessWidget {
  final DetailedMachine detailedMachine;
  final Function editMinimumPrizeCountDialog;
  final Function editTypeOfPrizeDialog;
  final Function editIncomeGoal;

  const Operational({
    Key key,
    this.editMinimumPrizeCountDialog,
    this.editTypeOfPrizeDialog,
    this.detailedMachine,
    this.editIncomeGoal,
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
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parceria'),
                    Text(detailedMachine.groupLabel ?? 'Parceria Pessoal',
                        style: styles.regular(fontSize: 12)),
                    SizedBox(height: 15),
                    Text('Categoria'),
                    Text(detailedMachine.machine.categoryLabel,
                        style: styles.regular(fontSize: 12)),
                    SizedBox(height: 15),
                    Text('Operador responsável'),
                    Text(detailedMachine.machine.operatorName ?? '-',
                        style: styles.regular(fontSize: 12)),
                    SizedBox(height: 15),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap:
                          locator<UserProvider>().user.permissions.editMachines
                              ? editMinimumPrizeCountDialog
                              : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Estoque mínimo'),
                              if (locator<UserProvider>()
                                  .user
                                  .permissions
                                  .editMachines)
                                Container(
                                  margin: EdgeInsets.only(left: 2.5),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 7.5),
                                  child: Icon(Icons.edit,
                                      size: 15, color: colors.primaryColor),
                                )
                            ],
                          ),
                          Text(
                            detailedMachine.machine.minimumPrizeCount != null
                                ? detailedMachine.machine.minimumPrizeCount
                                    .toString()
                                : '-',
                            style: styles.regular(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: locator<UserProvider>()
                                  .user
                                  .permissions
                                  .editMachines &&
                              locator<UserProvider>().user.role != Role.OPERATOR
                          ? () => editIncomeGoal(perPrize: true)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Meta \$/prêmio'),
                              if (locator<UserProvider>()
                                  .user
                                  .permissions
                                  .editMachines)
                                Container(
                                  margin: EdgeInsets.only(left: 2.5),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 7.5),
                                  child: Icon(Icons.edit,
                                      size: 15, color: colors.primaryColor),
                                )
                            ],
                          ),
                          Text(
                            detailedMachine.machine.incomePerPrizeGoal != null
                                ? 'R\$ ${detailedMachine.machine.incomePerPrizeGoal.toStringAsFixed(2).replaceAll('.', ',')}'
                                : '-',
                            style: styles.regular(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (detailedMachine.machine.locationId != null) {
                          if (locator<UserProvider>().user.role !=
                              Role.OPERATOR) {
                            locator<InterfaceService>().navigateTo(
                              DetailedPointOfSalePage.route,
                              arguments: detailedMachine.machine.locationId,
                            );
                          }
                        } else {
                          locator<InterfaceService>()
                              .navigateTo(GroupStockPage.route);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ponto de venda'),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  detailedMachine.pointOfSaleLabel ??
                                      'Em estoque',
                                  overflow: TextOverflow.fade,
                                  style: styles.regular(
                                      fontSize: 12, color: Colors.blue),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Feather.external_link,
                                size: 15,
                                color: Colors.blue,
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                    Text('Telemetria'),
                    Text(
                        detailedMachine.machine.telemetryBoardId != null
                            ? 'STG-${detailedMachine.machine.telemetryBoardId}'
                            : 'Sem telemetria',
                        style: styles.regular(fontSize: 12)),
                    SizedBox(height: 15),
                    Text('Valor da jogada'),
                    Text(
                      'R\$ ${detailedMachine.machine.gameValue.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: styles.regular(fontSize: 12),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: locator<UserProvider>()
                                  .user
                                  .permissions
                                  .editMachines &&
                              locator<UserProvider>().user.role != Role.OPERATOR
                          ? editTypeOfPrizeDialog
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Tipo de prêmio'),
                              if (locator<UserProvider>()
                                      .user
                                      .permissions
                                      .editMachines &&
                                  locator<UserProvider>().user.role !=
                                      Role.OPERATOR)
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 2.5),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 7.5),
                                    child: Icon(Icons.edit,
                                        size: 15, color: colors.primaryColor),
                                  ),
                                )
                            ],
                          ),
                          Text(
                            detailedMachine.machine.typeOfPrize != null
                                ? detailedMachine.machine.typeOfPrize.label
                                : 'Indefinido',
                            style: styles.regular(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: locator<UserProvider>()
                                  .user
                                  .permissions
                                  .editMachines &&
                              locator<UserProvider>().user.role != Role.OPERATOR
                          ? () => editIncomeGoal(perPrize: false)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Meta \$/mês'),
                              if (locator<UserProvider>()
                                      .user
                                      .permissions
                                      .editMachines &&
                                  locator<UserProvider>().user.role !=
                                      Role.OPERATOR)
                                Container(
                                  margin: EdgeInsets.only(left: 2.5),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 7.5),
                                  child: Icon(Icons.edit,
                                      size: 15, color: colors.primaryColor),
                                )
                            ],
                          ),
                          Text(
                            detailedMachine.machine.incomePerMonthGoal != null
                                ? 'R\$ ${detailedMachine.machine.incomePerMonthGoal.toStringAsFixed(2).replaceAll('.', ',')}'
                                : '-',
                            style: styles.regular(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
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

class DataPerBox extends StatelessWidget {
  final String categoryLabel;
  final List<BoxInfo> boxesInfo;
  final Role role;
  final Function reloadBox;
  final Function fixMachineStock;
  final Function initiateRecoverProcess;

  const DataPerBox(
      {Key key,
      this.categoryLabel,
      this.fixMachineStock,
      this.initiateRecoverProcess,
      this.boxesInfo,
      this.role,
      this.reloadBox});

  Map getAllBoxesCombined() {
    var totalIncome = 0.0;
    var totalGivenPrizes = 0;
    var averageIncomePerPrizeGiven = 0.0;
    var totalCurrentPrizeCount = 0.0;
    boxesInfo.forEach((element) {
      totalIncome += element.currentMoney;
      totalGivenPrizes += element.givenPrizes;
      totalCurrentPrizeCount += element.currentPrizeCount;
    });
    if (totalGivenPrizes != 0) {
      averageIncomePerPrizeGiven = totalIncome / totalGivenPrizes;
    }

    return {
      'totalIncome': totalIncome,
      'totalGivenPrizes': totalGivenPrizes,
      'averageIncomePerPrizeGiven': averageIncomePerPrizeGiven,
      'totalCurrentPrizeCount': totalCurrentPrizeCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    var allBoxesCombined = getAllBoxesCombined();
    return SliverToBoxAdapter(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Text(
                    'Acumulado desde a última coleta',
                    style: styles.medium(fontSize: 15),
                  ),
                ),
              ] +
              List.generate(
                boxesInfo.length,
                (index) => Container(
                  margin: EdgeInsets.only(bottom: 7.5),
                  padding: EdgeInsets.all(7.5),
                  decoration: BoxDecoration(
                    color: colors.backgroundColor,
                    border: Border.all(width: 3, color: colors.lightBlack),
                  ),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 110, maxHeight: 125),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                categoryLabel.toLowerCase().contains('roleta')
                                    ? 'Haste ${index + 1}'
                                    : 'Cabine ${index + 1}',
                                style: styles.bold(fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Text('Faturamento: ', style: styles.medium()),
                                  Text(
                                    'R\$ ${boxesInfo[index].currentMoney.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: styles.regular(
                                        color: colors.lightGreen),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Prêmios entregues: ',
                                      style: styles.medium()),
                                  Text(
                                    '${boxesInfo[index].givenPrizes}',
                                    style: styles.regular(
                                      color: Colors.deepOrange,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Média: ', style: styles.medium()),
                                      Text(
                                        boxesInfo[index].givenPrizes != 0
                                            ? 'R\$ ${(boxesInfo[index].currentMoney / boxesInfo[index].givenPrizes).toStringAsFixed(2).replaceAll('.', ',')}/prêmio'
                                            : 'R\$ 0.00/prêmio',
                                        style: styles.regular(
                                          color: Colors.deepPurple,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Estoque atual: ',
                                    style: styles.medium(),
                                  ),
                                  Text(
                                    boxesInfo[index]
                                        .currentPrizeCount
                                        .toString(),
                                    style: styles.regular(color: Colors.amber),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (locator<UserProvider>()
                                .user
                                .permissions
                                .fixMachineStock)
                              GestureDetector(
                                onTap: () =>
                                    fixMachineStock(boxesInfo[index].boxId),
                                child: Container(
                                  padding: EdgeInsets.only(left: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    'Corrigir estoque',
                                    style: styles.medium(
                                      color: colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 7.5),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => initiateRecoverProcess(
                                      boxesInfo[index].boxId),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: colors.primaryColor,
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(1, 1),
                                          color: colors.mediumBlack,
                                          spreadRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      'Resgatar',
                                      style: styles.medium(
                                        color: colors.backgroundColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    var role =
                                        locator<UserProvider>().user.role;
                                    if (role == Role.MANAGER) {
                                      reloadBox(boxesInfo[index].boxId);
                                    } else if (role == Role.OPERATOR) {
                                      reloadBox(boxesInfo[index].boxId, 'USER');
                                    } else {
                                      reloadBox(
                                          boxesInfo[index].boxId, 'GROUP');
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: colors.primaryColor,
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(1, 1),
                                          color: colors.mediumBlack,
                                          spreadRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      'Abastecer',
                                      style: styles.medium(
                                        color: colors.backgroundColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ) +
              [
                if (boxesInfo.length > 1)
                  Container(
                    margin: EdgeInsets.only(bottom: 7.5),
                    padding: EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      color: colors.backgroundColor,
                      border: Border.all(width: 3, color: colors.lightBlack),
                    ),
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  categoryLabel.toLowerCase().contains('roleta')
                                      ? 'Resumo das hastes'
                                      : 'Resumo das cabines',
                                  style: styles.bold(fontSize: 16),
                                ),
                                SizedBox(height: 7.5),
                                Row(
                                  children: [
                                    Text('Valor total: ',
                                        style: styles.medium()),
                                    Text(
                                      'R\$ ${allBoxesCombined['totalIncome'].toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: styles.regular(
                                          color: colors.lightGreen),
                                    )
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text('Prêmios entregues: ',
                                        style: styles.medium()),
                                    Text(
                                      '${allBoxesCombined['totalGivenPrizes']}',
                                      style: styles.regular(
                                        color: Colors.deepOrange,
                                      ),
                                    )
                                  ],
                                ),
                                if (role != Role.OPERATOR)
                                  Column(
                                    children: [
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text('Média: ',
                                              style: styles.medium()),
                                          Text(
                                            'R\$ ${allBoxesCombined['averageIncomePerPrizeGiven'].toStringAsFixed(2).replaceAll('.', ',')}/prêmio',
                                            style: styles.regular(
                                              color: Colors.deepPurple,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text('Estoque total: ',
                                            style: styles.medium()),
                                        Text(
                                          '${allBoxesCombined['totalCurrentPrizeCount'].toStringAsFixed(0)}',
                                          style: styles.regular(
                                            color: Colors.deepPurple,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ]),
    );
  }
}

class TransactionHistory extends StatelessWidget {
  final List<TelemetryLog> transactionHistory;
  final Machine machine;

  const TransactionHistory({Key key, this.transactionHistory, this.machine});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HISTÓRICO DE JOGADAS',
                style: styles.medium(fontSize: 16),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    interfaceService.navigateTo(TelemetryLogsPage.route,
                        arguments: machine);
                  },
                  child: FittedBox(
                    child: Text(
                      'Ver histórico completo',
                      style: styles.regular(
                        fontSize: 14,
                        color: colors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.construction),
              Text(
                ' - Gerados em modo manutenção',
                style: styles.regular(fontSize: 12),
              )
            ],
          ),
          SizedBox(height: 10),
          Column(
            children: List.generate(
              transactionHistory.length,
              (index) => Container(
                margin: EdgeInsets.only(bottom: 7.5),
                padding: EdgeInsets.all(15),
                color: colors.backgroundColor,
                child: Row(
                  children: [
                    Container(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: transactionHistory[index].type == 'IN'
                                ? colors.lightGreen.withOpacity(0.5)
                                : colors.red.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Icon(
                              transactionHistory[index].type == 'IN'
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
                                transactionHistory[index].type == 'IN'
                                    ? 'Crédito'
                                    : 'Prêmio',
                                style: styles.medium(fontSize: 18),
                              ),
                              if (transactionHistory[index].offline)
                                FittedBox(
                                  child: Text(
                                    ' (offline)',
                                    style: styles.medium(color: colors.red),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            transactionHistory[index].type == 'IN'
                                ? 'R\$ ${transactionHistory[index].value.toStringAsFixed(2).replaceAll('.', ',')}'
                                : '${transactionHistory[index].value.toStringAsFixed(0)}',
                            style: styles.regular(
                                fontSize: 14,
                                color: transactionHistory[index].type == 'IN'
                                    ? colors.lightGreen
                                    : colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    Row(
                      children: [
                        if (transactionHistory[index].maintenance)
                          Icon(
                            Icons.construction,
                          ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getFormattedDate(transactionHistory[index].date)
                                  .split(' ')[0],
                              style: styles.regular(
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              getFormattedDate(transactionHistory[index].date)
                                  .split(' ')[2],
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
            ),
          )
        ],
      ),
    );
  }
}

class DetailedMachineChart extends StatefulWidget {
  final Map<String, dynamic> setup;

  const DetailedMachineChart({Key key, this.setup}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DetailedMachineChartState();
}

class DetailedMachineChartState extends State<DetailedMachineChart> {
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
                            : 100,
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
              return '${value.toStringAsFixed(2).replaceAll('.', ',')}';
            } else if (widget.setup['maxY'] <= 10) {
              return '${value.toStringAsFixed(2).replaceAll('.', ',')}';
            } else if (widget.setup['maxY'] <= 50) {
              if (value % 5 == 0) {
                return '${value.toStringAsFixed(2).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 100) {
              if (value % 10 == 0) {
                return '${value.toStringAsFixed(2).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 1000) {
              if (value % 100 == 0) {
                return '${value.toStringAsFixed(2).replaceAll('.', ',')}';
              }
            } else if (widget.setup['maxY'] <= 10000) {
              if (value % 1000 == 0) {
                return '${value.toStringAsFixed(2).replaceAll('.', ',')}';
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

class ReloadMachineForm extends StatelessWidget {
  final int available;
  final Function getQuantity;
  final String label;

  const ReloadMachineForm(
      {Key key, this.available, this.getQuantity, this.label})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Com quantas unidades de $label você deseja abaster a máquina?',
          style: styles.medium(fontSize: 16),
        ),
        SizedBox(height: 25),
        Text('Disponível: $available'),
        SizedBox(height: 25),
        Text('Quantidade'),
        SizedBox(height: 7.5),
        Container(
          child: CustomTextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => getQuantity(int.parse(value)),
          ),
        ),
      ],
    );
  }
}

class EventHistory extends StatelessWidget {
  final List<MachineLog> machineLogs;
  final Machine machine;

  const EventHistory({Key key, this.machineLogs, this.machine});
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HISTÓRICO DE EVENTOS',
                style: styles.medium(fontSize: 16),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    interfaceService.navigateTo(MachineLogsPage.route,
                        arguments: machine);
                  },
                  child: FittedBox(
                    child: Text(
                      'Ver histórico completo',
                      style: styles.regular(
                        fontSize: 14,
                        color: colors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Column(
            children: List.generate(
              machineLogs.length,
              (index) => Container(
                margin: EdgeInsets.only(bottom: 7.5),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: colors.backgroundColor,
                ),
                child: Row(
                  children: [
                    Container(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: machineLogs[index].type == 'REMOTE_CREDIT'
                                ? colors.lightGreen.withOpacity(0.5)
                                : Colors.amber.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Icon(
                              machineLogs[index].type == 'REMOTE_CREDIT'
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
                            machineLogs[index].type == 'REMOTE_CREDIT'
                                ? 'Crédito Remoto'
                                : 'Correção de estoque',
                            style: styles.medium(fontSize: 14),
                          ),
                          Text(
                            machineLogs[index].type == 'REMOTE_CREDIT'
                                ? 'R\$ ${machineLogs[index].value.toStringAsFixed(2).replaceAll('.', ',')}'
                                : '${machineLogs[index].value.toStringAsFixed(0)}',
                            style: styles.regular(
                                fontSize: 14,
                                color:
                                    machineLogs[index].type == 'REMOTE_CREDIT'
                                        ? colors.lightGreen
                                        : Colors.amber),
                          ),
                          SizedBox(height: 5),
                          Text(
                            machineLogs[index].type == 'REMOTE_CREDIT'
                                ? 'Crédito remoto por: ${machineLogs[index].user}'
                                : 'Correção feita por: ${machineLogs[index].user}',
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
                              getFormattedDate(machineLogs[index].date)
                                  .split(' ')[0],
                              style: styles.regular(
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              getFormattedDate(machineLogs[index].date)
                                  .split(' ')[2],
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
            ),
          )
        ],
      ),
    );
  }
}
