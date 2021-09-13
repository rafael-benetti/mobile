import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/machine.dart';
import '../../../../src/core/models/route.dart';
import '../../../../src/core/providers/machines_provider.dart';
import '../../../../src/core/providers/points_of_sale_provider.dart';
import '../../../../src/core/providers/routes_provider.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/widgets/custom_dropdown.dart';
import '../../../../src/interface/widgets/dialog_action.dart';

import '../../../locator.dart';

class DetailedPointOfSalePageModel extends BaseViewModel {
  String pointOfSaleId;
  final interfaceService = locator<InterfaceService>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  final machinesProvider = locator<MachinesProvider>();
  final routesProvider = locator<RoutesProvider>();
  String period;
  double currentPadding;
  List<Machine> inStockInGroupMachines;

  double totalCurrentMoney = 0;

  void loadData() async {
    interfaceService.showLoader();
    setBusy(true);
    await pointsOfSaleProvider.getDetailedPointsOfSale(pointOfSaleId, 'DAILY');
    period = 'DAILY';
    currentPadding = 0;
    pointsOfSaleProvider.detailedPointOfSale.machinesInfo.forEach((element) {
      element.machine.boxes.forEach((element) {
        totalCurrentMoney += element.currentMoney;
      });
    });
    setBusy(false);
    interfaceService.closeLoader();
  }

  Map<String, dynamic> getChartData() {
    var maxY = 0.0;
    var xArray = [];
    pointsOfSaleProvider.detailedPointOfSale.chartData.forEach((element) {
      if (element.income + element.prizeCount > maxY) {
        maxY = element.income + element.prizeCount;
      }
      xArray.add(element.date);
    });
    var incomeSpots = List<FlSpot>.generate(
      pointsOfSaleProvider.detailedPointOfSale.chartData.length,
      (index) => FlSpot(
        index.toDouble(),
        pointsOfSaleProvider.detailedPointOfSale.chartData[index].income,
      ),
    );

    var prizesSpots = List<FlSpot>.generate(
      pointsOfSaleProvider.detailedPointOfSale.chartData.length,
      (index) => FlSpot(
        index.toDouble(),
        pointsOfSaleProvider.detailedPointOfSale.chartData[index].prizeCount
            .toDouble(),
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

  void getDetailedPointOfSale(String p, double padding) async {
    if (p != period) {
      period = p;
      currentPadding = padding;
      notifyListeners();
      interfaceService.showLoader();
      await pointsOfSaleProvider.getDetailedPointsOfSale(
          pointsOfSaleProvider.detailedPointOfSale.pointOfSale.id, p);
      interfaceService.closeLoader();
    }
  }

  void onAddToRoute() async {
    interfaceService.showLoader();
    await routesProvider.getRoutes(shouldClearCurrentList: true);
    interfaceService.closeLoader();
    popRoutesDialog();
  }

  void popRoutesDialog() {
    OperatorRoute selectedRoute;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escolha a rota',
            style: styles.medium(fontSize: 16),
          ),
          SizedBox(height: 10),
          Container(
            width: 500,
            child: CustomDropdownButton(
              initialValue: DropdownInputOption(title: ''),
              maxHeight: 157.5,
              onSelect: (option) {
                selectedRoute = routesProvider.routes
                    .firstWhere((element) => element.label == option.title);
              },
              values: List.generate(
                routesProvider.routes.length,
                (index) => DropdownInputOption(
                  title: routesProvider.routes[index].label,
                ),
              ),
            ),
          )
        ],
      ),
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
            if (selectedRoute != null) {
              interfaceService.showLoader();
              var response = await routesProvider.editRoute({
                'pointsOfSaleIds': selectedRoute.pointsOfSaleIds +
                    [pointsOfSaleProvider.detailedPointOfSale.pointOfSale.id]
              }, selectedRoute.id);
              interfaceService.goBack();
              if (response.status == Status.success) {
                await pointsOfSaleProvider.getDetailedPointsOfSale(
                    pointOfSaleId, period);
                interfaceService.closeLoader();
                interfaceService.showSnackBar(
                  message: 'Ponto de venda adicionado a rota.',
                  backgroundColor: colors.lightGreen,
                );
              } else {
                interfaceService.closeLoader();
                interfaceService.showSnackBar(
                  message: 'Algo deu errado. Tente novamente',
                  backgroundColor: colors.red,
                );
              }
            } else {
              interfaceService.showSnackBar(
                message: 'Selecione uma rota.',
                backgroundColor: colors.red,
              );
            }
          },
        ),
      ],
    );
  }

  void onAddMachine() async {
    interfaceService.showLoader();
    await machinesProvider.filterMachines(
      pointOfSaleId: 'null',
      groupId: pointsOfSaleProvider.detailedPointOfSale.pointOfSale.groupId,
      clearCurrentList: true,
      noLimit: true,
    );
    interfaceService.closeLoader();
    popAvailableMachinesDialog();
  }

  void popRemovePointOfSaleFromRouteDialog() {
    interfaceService.showDialogMessage(
      title: 'Remover desta rota',
      message:
          'Deseja mesmo remover ${pointsOfSaleProvider.detailedPointOfSale.pointOfSale.label} de ${pointsOfSaleProvider.detailedPointOfSale.route.label}?',
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
            if (pointsOfSaleProvider
                    .detailedPointOfSale.route.pointsOfSaleIds.length >
                1) {
              interfaceService.showLoader();
              var response = await routesProvider.editRoute({
                'pointsOfSaleIds': pointsOfSaleProvider
                    .detailedPointOfSale.route.pointsOfSaleIds
                    .where((element) =>
                        element !=
                        pointsOfSaleProvider.detailedPointOfSale.pointOfSale.id)
                    .toList(),
              }, pointsOfSaleProvider.detailedPointOfSale.route.id);

              if (response.status == Status.success) {
                await pointsOfSaleProvider.getDetailedPointsOfSale(
                    pointOfSaleId, period);
                interfaceService.closeLoader();
                interfaceService.goBack();
                interfaceService.showSnackBar(
                  message: 'Ponto de venda removido da rota com sucesso.',
                  backgroundColor: colors.lightGreen,
                );
              }
            } else {
              interfaceService.goBack();
              await interfaceService.showDialogMessage(
                title: 'Atenção',
                message:
                    'Esta rota só possui este ponto de venda. Ao removê-lo, a rota será deletada. Deseja continuar?',
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
                      interfaceService.showLoader();
                      var response = await routesProvider.editRoute({
                        'pointsOfSaleIds': pointsOfSaleProvider
                            .detailedPointOfSale.route.pointsOfSaleIds
                            .where((element) =>
                                element !=
                                pointsOfSaleProvider
                                    .detailedPointOfSale.pointOfSale.id)
                            .toList(),
                      }, pointsOfSaleProvider.detailedPointOfSale.route.id);

                      if (response.status == Status.success) {
                        await pointsOfSaleProvider.getDetailedPointsOfSale(
                            pointOfSaleId, period);
                        interfaceService.closeLoader();
                        interfaceService.goBack();
                        interfaceService.showSnackBar(
                          message:
                              'Ponto de venda removido da rota com sucesso.',
                          backgroundColor: colors.lightGreen,
                        );
                      }
                    },
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  void popAvailableMachinesDialog() {
    var selectedMachineId;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Máquinas no estoque dessa parceria',
            style: styles.medium(fontSize: 16),
          ),
          SizedBox(height: 10),
          Container(
            width: 500,
            child: CustomDropdownButton(
              initialValue: DropdownInputOption(title: ''),
              maxHeight: 157.5,
              onSelect: (s) {
                selectedMachineId = machinesProvider.filteredMachines
                    .firstWhere((element) => element.serialNumber == s.title)
                    .id;
              },
              values: List.generate(
                machinesProvider.filteredMachines.length,
                (index) => DropdownInputOption(
                    title:
                        machinesProvider.filteredMachines[index].serialNumber),
              ),
            ),
          )
        ],
      ),
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
            if (selectedMachineId != null) {
              interfaceService.showLoader();
              var response = await machinesProvider.editMachine(
                {
                  'locationId':
                      pointsOfSaleProvider.detailedPointOfSale.pointOfSale.id
                },
                selectedMachineId,
              );
              if (response.status == Status.success) {
                await pointsOfSaleProvider.getDetailedPointsOfSale(
                    pointOfSaleId, 'DAILY');
                interfaceService.closeLoader();
                interfaceService.goBack();
                interfaceService.showSnackBar(
                  message: 'Máquina adicionada.',
                  backgroundColor: colors.lightGreen,
                );
              } else {
                interfaceService.closeLoader();
                interfaceService.showSnackBar(
                  message: 'Erro ao adicionar máquina.',
                  backgroundColor: colors.red,
                );
              }
            } else {
              interfaceService.showSnackBar(
                message: 'Selecione uma máquina.',
                backgroundColor: colors.red,
              );
            }
          },
        ),
      ],
    );
  }
}
