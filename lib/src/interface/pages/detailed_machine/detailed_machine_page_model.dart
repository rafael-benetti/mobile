import 'package:brasil_fields/brasil_fields.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/prize.dart';
import '../../../../src/core/models/user.dart';
import '../../../../src/core/providers/groups_provider.dart';
import '../../../../src/core/providers/machines_provider.dart';
import '../../../../src/core/providers/points_of_sale_provider.dart';
import '../../../../src/core/providers/telemetry_boards_provider.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/detailed_machine/widgets.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../../src/interface/widgets/custom_text_field.dart';
import '../../../../src/interface/widgets/dialog_action.dart';
import '../../../locator.dart';

class DetailedMachinePageModel extends BaseViewModel {
  String machineId;
  final interfaceService = locator<InterfaceService>();
  final machinesProvider = locator<MachinesProvider>();
  final userProvider = locator<UserProvider>();
  final groupsProvider = locator<GroupsProvider>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  final telemetryBoardsProvider = locator<TelemetryBoardsProvider>();
  final colors = locator<AppColors>();
  String period;
  double currentPadding;

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await getInitialDetailedMachine('DAILY');
    await userProvider.fetchUser();
    await telemetryBoardsProvider.getAllTelemetries();
    await pointsOfSaleProvider.filterPointsOfSale(
      clearCurrentList: true,
      groupId: machinesProvider.detailedMachine.machine.groupId,
      limitless: true,
    );
    interfaceService.closeLoader();
    currentPadding = 0;
    setBusy(false);
  }

  void changeMaintenanceMode(bool maintenance) async {
    var changeMaintenance = false;
    if (maintenance) {
      await interfaceService.showDialogMessage(
        title: 'Atenção',
        message:
            'Ao ativar modo manutenção as jogadas não serão contabilizadas.',
        actions: [
          DialogAction(
            title: 'Cancelar',
            onPressed: () {
              interfaceService.goBack();
            },
          ),
          DialogAction(
            title: 'Continuar',
            onPressed: () {
              changeMaintenance = true;
              interfaceService.goBack();
            },
          ),
        ],
      );
    }
    if (changeMaintenance || !maintenance) {
      interfaceService.showLoader();
      await machinesProvider.editMachine({'maintenance': maintenance},
          machinesProvider.detailedMachine.machine.id);
      notifyListeners();
      interfaceService.closeLoader();
    }
  }

  Future getInitialDetailedMachine(String p) async {
    period = p;
    await machinesProvider.getDetailedMachine(machineId, period);
  }

  Future refreshDetailedMachineData() async {
    await machinesProvider.getDetailedMachine(machineId, period);
  }

  void getDetailedMachine(String p, double padding) async {
    if (p != period) {
      period = p;
      currentPadding = padding;
      notifyListeners();
      interfaceService.showLoader();
      await machinesProvider.getDetailedMachine(machineId, p);
      interfaceService.closeLoader();
    }
  }

  Map<String, dynamic> getChartData() {
    var maxY = 0.0;
    var xArray = [];
    machinesProvider.detailedMachine.chartData.forEach((element) {
      if (element.income + element.prizeCount > maxY) {
        maxY = element.income + element.prizeCount;
      }
      xArray.add(element.date);
    });
    var incomeSpots = List<FlSpot>.generate(
      machinesProvider.detailedMachine.chartData.length,
      (index) => FlSpot(
        index.toDouble(),
        machinesProvider.detailedMachine.chartData[index].income,
      ),
    );

    var prizesSpots = List<FlSpot>.generate(
      machinesProvider.detailedMachine.chartData.length,
      (index) => FlSpot(
        index.toDouble(),
        machinesProvider.detailedMachine.chartData[index].prizeCount.toDouble(),
      ),
    );

    if (maxY == 0) maxY = 5;
    return {
      'xArray': xArray,
      'maxY': maxY,
      'period': period,
      'incomeSpots': incomeSpots,
      'prizesSpots': prizesSpots
    };
  }

  void popMoveMachineDialog() {
    var currentMoney = 0.0;
    var currentPrizes = 0;
    machinesProvider.detailedMachine.boxesInfo.forEach((element) {
      currentMoney += element.currentMoney;
      currentPrizes += element.currentPrizeCount;
    });
    interfaceService.showDialogWithWidgets(
      title: 'Para onde deseja mover a máquina?',
      widget: Column(
        children: [
          SizedBox(
            width: 500,
            child: ElevatedButton(
              onPressed: () async {
                var moveToGroup = false;
                interfaceService.goBack();
                await interfaceService.showDialogMessage(
                  title: 'Atenção',
                  message:
                      'Ao mover uma máquina para outra parceria, a mesma será movida para o estoque da parceria receptora. Também, a máquina perderá seu operador responsável, estoque mínimo e tipo de produto. Além disso, a placa de telemetria será removida da máquina. Caso também queira transferir a telemetria para a mesma parceria, essa ação pode ser feita pela página de Telemetrias. Deseja continuar?',
                  actions: [
                    DialogAction(
                      title: 'Cancelar',
                      onPressed: () {
                        interfaceService.goBack();
                      },
                    ),
                    DialogAction(
                      title: 'Continuar',
                      onPressed: () {
                        interfaceService.goBack();
                        moveToGroup = true;
                      },
                    ),
                  ],
                );
                if (moveToGroup && currentPrizes == 0 && currentMoney == 0) {
                  popMoveToGroupDialog();
                } else {
                  await interfaceService.showDialogMessage(
                    title: 'Atenção!',
                    message:
                        'Para mover uma máquina entre parcerias, primeiramente você deve retirar todo o dinheiro e prêmios que se encontram atualmente na máquina. Para isso, faça uma coleta e retire os prêmios.',
                    actions: [
                      DialogAction(
                        title: 'Ok',
                        onPressed: () {
                          interfaceService.goBack();
                        },
                      )
                    ],
                  );
                }
              },
              child: Text('Para outra parceria'),
            ),
          ),
          SizedBox(
            width: 500,
            child: ElevatedButton(
              onPressed: () {
                interfaceService.goBack();
                if (machinesProvider.detailedMachine.machine.locationId ==
                        null ||
                    currentMoney == 0) {
                  popMoveToPointOfSaleDialog();
                } else {
                  interfaceService.showDialogMessage(
                    title: 'Atenção!',
                    message:
                        'Para mover uma máquina entre pontos de venda, primeiramente você deve retirar todo o dinheiro que se encontra atualmente na máquina. Para isso, faça uma coleta.',
                    actions: [
                      DialogAction(
                        title: 'Ok',
                        onPressed: () {
                          interfaceService.goBack();
                        },
                      )
                    ],
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all(3),
                alignment: Alignment.center,
                child: Text(
                  machinesProvider.detailedMachine.machine.locationId == null
                      ? 'Para um ponto de venda'
                      : 'Para outro ponto de venda/estoque',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void popMoveToGroupDialog() {
    var selectedGroup;
    interfaceService.showDialogWithWidgets(
      title: 'Para qual parceria deseja mover a máquina?',
      color: Colors.blue,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome'),
          SizedBox(height: 15),
          SizedBox(
            width: 500,
            child: CustomDropdownButton(
              values: List.generate(
                groupsProvider.groups.length,
                (index) => DropdownInputOption(
                    title: groupsProvider.groups[index].label),
              ),
              maxHeight: 157.5,
              initialValue: DropdownInputOption(title: ''),
              onSelect: (option) {
                selectedGroup = groupsProvider.groups
                    .firstWhere((element) => element.label == option.title);
              },
            ),
          )
        ],
      ),
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () async {
            if (selectedGroup == null) {
              interfaceService.showSnackBar(
                  message: 'Selecione uma parceria',
                  backgroundColor: colors.red);
            } else {
              interfaceService.showLoader();
              var response = await machinesProvider.editMachine(
                  {'groupId': selectedGroup.id},
                  machinesProvider.detailedMachine.machine.id);
              if (response.status == Status.success) {
                interfaceService.showSnackBar(
                  message:
                      'Máquina transferida pra parceria ${selectedGroup.label}',
                  backgroundColor: colors.lightGreen,
                );
                await pointsOfSaleProvider.filterPointsOfSale(
                    clearCurrentList: true,
                    groupId: machinesProvider.detailedMachine.machine.groupId);
                machinesProvider.detailedMachine.groupLabel =
                    selectedGroup.label;
              }
              interfaceService.closeLoader();
            }
            interfaceService.goBack();
            notifyListeners();
          },
        ),
      ],
    );
  }

  void popDeleteMachine() {
    interfaceService.showDialogMessage(
      title: 'Atenção!',
      message:
          'Deletar uma máquina é um processo irreversível, ou seja, você perderá acesso a dados relacionados a esta máquina. Deseja continuar?',
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () async {
            interfaceService.goBack();
            interfaceService.showLoader();
            var response = await machinesProvider.editMachine(
                {'isActive': false},
                machinesProvider.detailedMachine.machine.id);
            interfaceService.closeLoader();
            if (response.status == Status.success) {
              interfaceService.goBack();
              interfaceService.showSnackBar(
                message: 'Máquina deletada com sucesso',
                backgroundColor: colors.lightGreen,
              );
            } else {
              interfaceService.showSnackBar(
                  message: translateError(response.data),
                  backgroundColor: colors.red);
            }
          },
        ),
      ],
    );
  }

  void popMoveToPointOfSaleDialog() {
    var selectedPointOfSale;
    interfaceService.showDialogWithWidgets(
      title: 'Para qual localização deseja mover a máquina?',
      color: Colors.blue,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome'),
          SizedBox(height: 15),
          SizedBox(
            width: 500,
            child: CustomDropdownButton(
              values: List.generate(
                    pointsOfSaleProvider.filteredPointsOfSale.length,
                    (index) => DropdownInputOption(
                        title: pointsOfSaleProvider
                            .filteredPointsOfSale[index].label),
                  ) +
                  [DropdownInputOption(title: 'Estoque')],
              maxHeight: 157.5,
              initialValue: DropdownInputOption(title: ''),
              onSelect: (option) {
                if (option.title.toLowerCase().contains('estoque')) {
                  selectedPointOfSale = -1;
                } else {
                  selectedPointOfSale = pointsOfSaleProvider
                      .filteredPointsOfSale
                      .firstWhere((element) => element.label == option.title);
                }
              },
            ),
          )
        ],
      ),
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () async {
            if (selectedPointOfSale == null) {
              interfaceService.showSnackBar(
                  message: 'Selecione um destino', backgroundColor: colors.red);
            } else {
              if (selectedPointOfSale == -1) {
                interfaceService.showLoader();
                var response = await machinesProvider.editMachine(
                    {'locationId': null},
                    machinesProvider.detailedMachine.machine.id);
                interfaceService.closeLoader();
                interfaceService.goBack();
                if (response.status == Status.success) {
                  interfaceService.showSnackBar(
                      message: 'Máquina transferida para o estoque',
                      backgroundColor: colors.lightGreen);
                  machinesProvider.detailedMachine.pointOfSaleLabel = null;
                }
              } else {
                interfaceService.showLoader();
                var response = await machinesProvider.editMachine(
                    {'locationId': selectedPointOfSale.id},
                    machinesProvider.detailedMachine.machine.id);
                interfaceService.closeLoader();
                interfaceService.goBack();
                if (response.status == Status.success) {
                  interfaceService.showSnackBar(
                      message:
                          'Máquina transferida para ${selectedPointOfSale.label}',
                      backgroundColor: colors.lightGreen);
                  machinesProvider.detailedMachine.pointOfSaleLabel =
                      selectedPointOfSale.label;
                }
              }
            }
            notifyListeners();
          },
        ),
      ],
    );
  }

  void chooseSourceToReload(String boxId, [String source]) {
    interfaceService.showDialogWithWidgets(
      title: machinesProvider.detailedMachine.machine.typeOfPrize == null
          ? 'Da onde deseja retirar os prêmios?'
          : 'Da onde deseja retirar o prêmio ${machinesProvider.detailedMachine.machine.typeOfPrize.label}?',
      widget: Column(
        children: [
          SizedBox(
            width: 500,
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: colors.primaryColor),
              onPressed: () {
                interfaceService.goBack();
                choosePrizeToReload(boxId, 'GROUP');
              },
              child: Text('Estoque da parceria'),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 500,
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: colors.primaryColor),
              onPressed: () {
                interfaceService.goBack();
                choosePrizeToReload(boxId, 'USER');
              },
              child: Text('Estoque pessoal'),
            ),
          )
        ],
      ),
    );
  }

  void choosePrizeToReload(String boxId, String source) {
    var selectedPrize;
    var prizes = <Prize>[];
    if (source == 'GROUP') {
      prizes = groupsProvider.groups
          .firstWhere((group) =>
              group.id == machinesProvider.detailedMachine.machine.groupId)
          .stock
          .prizes;
      ;
    } else {
      prizes = userProvider.user.stock.prizes;
    }
    if (machinesProvider.detailedMachine.machine.typeOfPrize == null) {
      interfaceService.showDialogWithWidgets(
        color: colors.primaryColor,
        title: 'Escolha o prêmio para reabastecer a máquina.',
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome'),
            SizedBox(height: 5),
            SizedBox(
              width: 500,
              child: CustomDropdownButton(
                initialValue: DropdownInputOption(title: ''),
                onSelect: (option) {
                  selectedPrize = prizes
                      .firstWhere((element) => element.label == option.title);
                },
                maxHeight: 157.5,
                values: List.generate(
                  prizes.length,
                  (index) => DropdownInputOption(title: prizes[index].label),
                ),
              ),
            )
          ],
        ),
        actions: [
          DialogAction(
            title: 'Voltar',
            onPressed: () {
              interfaceService.goBack();
            },
          ),
          DialogAction(
            title: 'Continuar',
            onPressed: () {
              interfaceService.goBack();
              if (selectedPrize != null) {
                reloadMachineFormDialog(boxId, selectedPrize, source);
              } else {
                interfaceService.showSnackBar(
                    message: 'Escolha um prêmio', backgroundColor: colors.red);
              }
            },
          ),
        ],
      );
    } else if (prizes.any((element) =>
        element.id ==
        machinesProvider.detailedMachine.machine.typeOfPrize.id)) {
      reloadMachineFormDialog(
          boxId,
          prizes.firstWhere((element) =>
              element.id ==
              machinesProvider.detailedMachine.machine.typeOfPrize.id),
          source);
    } else {
      interfaceService.showDialogMessage(
        title: 'Ops!',
        message:
            'Não há registro do produto ${machinesProvider.detailedMachine.machine.typeOfPrize.label} no seu estoque pessoal.',
      );
    }
  }

  void reloadMachineFormDialog(String boxId, Prize prize, String source) {
    var quantity;
    int getQuantity(int q) => quantity = q;

    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      widget: ReloadMachineForm(
        label: prize.label,
        getQuantity: getQuantity,
        available: prize.quantity,
      ),
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () async {
            if (quantity > prize.quantity) {
              interfaceService.showSnackBar(
                  message: 'Quantidade maior que total disponível',
                  backgroundColor: colors.red);
            } else {
              var data = {
                'productType': 'PRIZE',
                'productQuantity': quantity,
                'from': {
                  'id': source == 'USER'
                      ? userProvider.user.id
                      : machinesProvider.detailedMachine.machine.groupId,
                  'type': source,
                },
                'to': {
                  'id': machinesProvider.detailedMachine.machine.id,
                  'type': 'MACHINE',
                  'boxId': boxId,
                }
              };
              interfaceService.showLoader();
              var response =
                  await machinesProvider.reloadMachineBox(prize.id, data);
              interfaceService.closeLoader();
              interfaceService.goBack();
              if (response.status == Status.success) {
                interfaceService.showSnackBar(
                    message: 'Cabine reabastecida com sucesso.',
                    backgroundColor: colors.lightGreen);
                if (source == 'USER') {
                  await userProvider.fetchUser();
                } else {
                  await groupsProvider.getAllGroups();
                }
              } else {
                interfaceService.showSnackBar(
                    message: translateError(response.data),
                    backgroundColor: colors.red);
              }
            }
          },
        )
      ],
    );
  }

  void editTypeOfPrizeDialog() {
    var typeOfPrize;
    groupsProvider.getGroupPrizesByGroupId(
        machinesProvider.detailedMachine.machine.groupId);
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      title: 'Editar tipo de prêmio',
      widget: Container(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pelúcias'),
            SizedBox(height: 10),
            CustomDropdownButton(
              initialValue: DropdownInputOption(
                  title: machinesProvider.detailedMachine.machine.typeOfPrize !=
                          null
                      ? machinesProvider
                          .detailedMachine.machine.typeOfPrize.label
                      : ''),
              maxHeight: 157.5,
              onSelect: (option) {
                if (option.title == 'Indefinido') {
                  typeOfPrize = null;
                } else {
                  typeOfPrize = groupsProvider.prizes
                      .firstWhere((element) => element.label == option.title);
                }
              },
              values: [DropdownInputOption(title: 'Indefinido')] +
                  List.generate(
                    groupsProvider.prizes.length,
                    (index) => DropdownInputOption(
                      title: groupsProvider.prizes[index].label,
                    ),
                  ),
            )
          ],
        ),
      ),
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Editar',
          onPressed: () async {
            var response;
            if (typeOfPrize == null) {
              interfaceService.showLoader();
              response = await machinesProvider.editMachine(
                  {'typeOfPrizeId': null},
                  machinesProvider.detailedMachine.machine.id);
              interfaceService.closeLoader();
            } else {
              interfaceService.showLoader();
              response = await machinesProvider.editMachine(
                  {'typeOfPrizeId': typeOfPrize.id},
                  machinesProvider.detailedMachine.machine.id);
              interfaceService.closeLoader();
            }
            if (response.status == Status.success) {
              interfaceService.showSnackBar(
                  message: 'Tipo de prêmio atualizado',
                  backgroundColor: colors.lightGreen);
              interfaceService.goBack();
            } else {
              interfaceService.showSnackBar(
                  message: 'Erro ao atualizar tipo de prêmio. Tente novamente',
                  backgroundColor: colors.red);
            }
          },
        )
      ],
    );
  }

  void editMinimumPrizeCountDialog() {
    var newMinimumPrizeCount;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      title: 'Editar estoque mínimo',
      widget: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estoque mínimo'),
            SizedBox(height: 10),
            CustomTextField(
              initialValue: machinesProvider
                          .detailedMachine.machine.minimumPrizeCount !=
                      null
                  ? machinesProvider.detailedMachine.machine.minimumPrizeCount
                      .toString()
                  : '',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              onChanged: (v) {
                if (v == '') {
                  newMinimumPrizeCount = null;
                } else {
                  newMinimumPrizeCount = int.parse(v.replaceAll(',', '.'));
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Editar',
          onPressed: () async {
            if (newMinimumPrizeCount == null) {
              interfaceService.showSnackBar(
                  message: 'Insira um valor válido',
                  backgroundColor: colors.red);
            } else {
              interfaceService.showLoader();
              var response = await machinesProvider.editMachine(
                  {'minimumPrizeCount': newMinimumPrizeCount},
                  machinesProvider.detailedMachine.machine.id);
              interfaceService.closeLoader();
              if (response.status == Status.success) {
                interfaceService.showSnackBar(
                    message: 'Estoque mínimo atualizado',
                    backgroundColor: colors.lightGreen);
                interfaceService.goBack();
              } else {
                interfaceService.showSnackBar(
                    message: 'Erro ao atualizar estoque. Tente novamente',
                    backgroundColor: colors.red);
              }
            }
          },
        )
      ],
    );
  }

  void editIncomeGoal({bool perPrize}) {
    var newIncomeGoal;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      title: perPrize
          ? 'Editar meta de faturamento por prêmio'
          : 'Editar meta de faturamento por mês',
      widget: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              perPrize
                  ? 'Meta de faturamento por prêmio'
                  : 'Editar meta de faturamento por mês',
            ),
            SizedBox(height: 10),
            CustomTextField(
              initialValue: '',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                RealInputFormatter(centavos: true),
              ],
              keyboardType: TextInputType.number,
              onChanged: (v) {
                if (v == '') {
                  newIncomeGoal = null;
                } else {
                  newIncomeGoal =
                      double.parse(v.replaceAll('.', '').replaceAll(',', '.'));
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Editar',
          onPressed: () async {
            if (newIncomeGoal == null) {
              interfaceService.showSnackBar(
                  message: 'Insira um valor válido',
                  backgroundColor: colors.red);
            } else {
              interfaceService.showLoader();
              var response = await machinesProvider.editMachine(
                  perPrize
                      ? {'incomePerPrizeGoal': newIncomeGoal}
                      : {'incomePerMonthGoal': newIncomeGoal},
                  machinesProvider.detailedMachine.machine.id);
              interfaceService.closeLoader();
              if (response.status == Status.success) {
                interfaceService.showSnackBar(
                    message: perPrize
                        ? 'Meta por prẽmio atualizada'
                        : 'Meta por mês atualizada',
                    backgroundColor: colors.lightGreen);
                interfaceService.goBack();
              } else {
                interfaceService.showSnackBar(
                    message:
                        'Erro ao atualizar meta financeira. Tente novamente',
                    backgroundColor: colors.red);
              }
            }
          },
        )
      ],
    );
  }

  void initiateRecoverProcess(String boxId) {
    if (machinesProvider.detailedMachine.machine.typeOfPrize != null) {
      if (userProvider.user.role == Role.MANAGER) {
        chooseSourceToRecover(boxId);
      } else {
        recoverPrizeForm(
          boxId,
          machinesProvider.detailedMachine.machine.typeOfPrize,
          userProvider.user.role == Role.OWNER,
        );
      }
    } else {
      if (userProvider.user.role == Role.MANAGER) {
        chooseSourceToRecover(boxId);
      } else {
        choosePrizeToRecover(boxId, userProvider.user.role == Role.OWNER);
      }
    }
  }

  void chooseSourceToRecover(String boxId) {
    var typeOfPrize = machinesProvider.detailedMachine.machine.typeOfPrize;
    var shouldChoosePrize = typeOfPrize == null;
    interfaceService.showDialogWithWidgets(
      title: typeOfPrize != null
          ? 'Para onde deseja resgatar o ${typeOfPrize.label}?'
          : 'Para onde deseja resgatar os prêmios?',
      widget: Container(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  interfaceService.goBack();
                  if (shouldChoosePrize) {
                    choosePrizeToRecover(boxId, true);
                  } else {
                    recoverPrizeForm(boxId, typeOfPrize, true);
                  }
                },
                style: ElevatedButton.styleFrom(primary: colors.primaryColor),
                child: Text('Estoque da parceria'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  interfaceService.goBack();
                  if (shouldChoosePrize) {
                    choosePrizeToRecover(boxId, false);
                  } else {
                    recoverPrizeForm(boxId, typeOfPrize, false);
                  }
                },
                style: ElevatedButton.styleFrom(primary: colors.primaryColor),
                child: Text('Estoque pessoal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void choosePrizeToRecover(String boxId, bool isGroup) {
    var prizes = [];
    var selectedPrize;
    if (isGroup) {
      groupsProvider.getGroupPrizesByGroupId(
          machinesProvider.detailedMachine.machine.groupId);
      prizes = groupsProvider.prizes;
    } else {
      prizes = userProvider.user.stock.prizes;
    }
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      title: 'Escolha o prêmio para resgatar.',
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome'),
          SizedBox(height: 5),
          SizedBox(
            width: 500,
            child: CustomDropdownButton(
              initialValue: DropdownInputOption(title: ''),
              onSelect: (option) {
                selectedPrize = prizes
                    .firstWhere((element) => element.label == option.title);
              },
              maxHeight: 157.5,
              values: List.generate(
                prizes.length,
                (index) => DropdownInputOption(title: prizes[index].label),
              ),
            ),
          )
        ],
      ),
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Continuar',
          onPressed: () {
            interfaceService.goBack();
            recoverPrizeForm(boxId, selectedPrize, isGroup);
          },
        ),
      ],
    );
  }

  void recoverPrizeForm(String boxId, Prize prize, bool isGroup) {
    var quantity;
    var amount = machinesProvider.detailedMachine.boxesInfo
        .firstWhere((element) => element.boxId == boxId)
        .currentPrizeCount;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      title: 'Quantas unidades de ${prize.label} você deseja resgatar?',
      widget: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estoque atual: $amount'),
            SizedBox(height: 10),
            Text('Quantidade'),
            SizedBox(height: 5),
            CustomTextField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (v) {
                if (v == '') {
                  quantity = null;
                } else {
                  quantity = int.parse(v.replaceAll(',', '.'));
                }
              },
            )
          ],
        ),
      ),
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () async {
            if (quantity != null && quantity <= amount) {
              interfaceService.showLoader();
              var response = await machinesProvider.removeFromMachine({
                'machineId': machinesProvider.detailedMachine.machine.id,
                'boxId': boxId,
                'quantity': quantity,
                'toGroup': isGroup,
              }, prize.id);
              if (response.status == Status.success) {
                await machinesProvider.getDetailedMachine(
                    machinesProvider.detailedMachine.machine.id, period);
                interfaceService.showSnackBar(
                    message: 'Prêmio resgatado com sucesso.',
                    backgroundColor: colors.lightGreen);
                interfaceService.closeLoader();
                interfaceService.goBack();
              } else {
                interfaceService.closeLoader();
                interfaceService.showSnackBar(
                    message: 'Erro ao resgatar prêmio. Tente novamente.',
                    backgroundColor: colors.red);
              }
            } else {
              interfaceService.showSnackBar(
                  message: 'Insira um valor válido',
                  backgroundColor: colors.red);
            }
          },
        )
      ],
    );
  }

  void fixMachineStock(String boxId) {
    var quantity;
    var observations;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      title: 'Corrigir estoque',
      widget: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade'),
            SizedBox(height: 5),
            CustomTextField(
              initialValue: '',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (v) {
                if (v == '') {
                  quantity = null;
                } else {
                  quantity = int.parse(v.replaceAll(',', '.'));
                }
              },
            ),
            SizedBox(height: 15),
            Text('Motivo para correção'),
            SizedBox(height: 5),
            CustomTextField(
              initialValue: '',
              onChanged: (v) {
                if (v == '') {
                  observations = null;
                } else {
                  observations = v;
                }
              },
            )
          ],
        ),
      ),
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () async {
            if (quantity != null && observations != null) {
              interfaceService.showLoader();
              var response = await machinesProvider.fixMachineStock({
                'boxId': boxId,
                'quantity': quantity,
                'observations': observations,
              }, machinesProvider.detailedMachine.machine.id);
              if (response.status == Status.success) {
                await machinesProvider.getDetailedMachine(
                    machinesProvider.detailedMachine.machine.id, period);
                interfaceService.closeLoader();
                interfaceService.goBack();
                interfaceService.showSnackBar(
                    message: 'Estoque corrigido com sucesso',
                    backgroundColor: colors.lightGreen);
              } else {
                interfaceService.closeLoader();
                interfaceService.showSnackBar(
                    message: 'Algo deu errado. Tente novamente.',
                    backgroundColor: colors.red);
              }
            } else {
              interfaceService.showSnackBar(
                  message: 'Insira um valor válido e o motivo da correção',
                  backgroundColor: colors.red);
            }
          },
        )
      ],
    );
  }

  void popRemoteCreditDialog() {
    var quantity;
    var observations;
    if (machinesProvider.detailedMachine.telemetryBoard != null) {
      interfaceService.showDialogWithWidgets(
        color: colors.primaryColor,
        title: 'Corrigir estoque',
        widget: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantidade'),
              SizedBox(height: 5),
              CustomTextField(
                initialValue: '',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (v) {
                  if (v == '') {
                    quantity = null;
                  } else {
                    quantity = int.parse(v.replaceAll(',', '.'));
                  }
                },
              ),
              SizedBox(height: 15),
              Text('Motivo para o crédito remoto'),
              SizedBox(height: 5),
              CustomTextField(
                initialValue: '',
                onChanged: (v) {
                  if (v == '') {
                    observations = null;
                  } else {
                    observations = v;
                  }
                },
              )
            ],
          ),
        ),
        actions: [
          DialogAction(
            title: 'Voltar',
            onPressed: () {
              interfaceService.goBack();
            },
          ),
          DialogAction(
            title: 'Confirmar',
            onPressed: () async {
              if (quantity != null && observations != null) {
                interfaceService.showLoader();
                var response = await machinesProvider.addRemoteCredit({
                  'observations': observations,
                  'quantity': quantity,
                }, machinesProvider.detailedMachine.machine.id);
                if (response.status == Status.success) {
                  await machinesProvider.getDetailedMachine(
                      machinesProvider.detailedMachine.machine.id, period);
                  interfaceService.goBack();
                  interfaceService.showSnackBar(
                      message: 'Crédito remoto enviado com sucesso',
                      backgroundColor: colors.lightGreen);
                } else {
                  interfaceService.showSnackBar(
                      message: 'Algo deu errado. Tente novamente.',
                      backgroundColor: colors.red);
                }
                interfaceService.closeLoader();
              } else {
                interfaceService.showSnackBar(
                    message:
                        'Insira um valor válido e o motivo do crédito remoto',
                    backgroundColor: colors.red);
              }
            },
          )
        ],
      );
    } else {
      interfaceService.showSnackBar(
        message: 'Esta máquina não possui uma telemetria',
        backgroundColor: colors.red,
      );
    }
  }
}
