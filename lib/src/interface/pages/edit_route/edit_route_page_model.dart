import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../core/models/point_of_sale.dart';
import '../../../core/models/route.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/machines_provider.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/providers/routes_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import 'widgets.dart';
import '../../widgets/dialog_action.dart';

import '../../../locator.dart';

class EditRoutePageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  final userProvider = locator<UserProvider>();
  final machinesProvider = locator<MachinesProvider>();
  final routesProvider = locator<RoutesProvider>();

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await pointsOfSaleProvider.getAllPointsOfSale();
    interfaceService.closeLoader();
    setBusy(false);
  }

  OperatorRoute operatorRoute;
  String selectedOperatorId;
  String label;
  List<String> selectedPointsOfSaleIds = [];
  List<PointOfSale> previousPointsOfSale = [];

  void fillPreviousPointsOfSale() {
    selectedPointsOfSaleIds.forEach((pId) {
      previousPointsOfSale.add(
          pointsOfSaleProvider.pointsOfSale.firstWhere((p) => p.id == pId));
    });
  }

  void addToSelectedPointsOfSale(String id) {
    selectedPointsOfSaleIds.add(id);
    selectedOperatorId = null;
    notifyListeners();
  }

  void removeFromSelectedPointsOfSale(String id) {
    selectedPointsOfSaleIds.remove(id);
    selectedOperatorId = null;
    notifyListeners();
  }

  void clearSelectedPointsOfSale() {
    selectedPointsOfSaleIds = [];
    getAvailableOperators();
    selectedOperatorId = null;
    notifyListeners();
  }

  void popSelectPointsOfSaleDialog() {
    interfaceService.showDialogWithWidgets(
      title: 'Selecione os pontos de venda',
      color: colors.primaryColor,
      actions: [
        DialogAction(
            title: 'Desmarcar todos',
            onPressed: () {
              clearSelectedPointsOfSale();
              interfaceService.goBack();
            }),
        DialogAction(
          title: 'Confirmar',
          onPressed: () {
            getAvailableOperators();
            selectedOperatorId = null;
            interfaceService.goBack();
          },
        )
      ],
      widget: Container(
        width: 500,
        child: PointsOfSaleCheckboxes(
          addToSelectedPointsOfSale: addToSelectedPointsOfSale,
          removeFromSelectedPointsOfSale: removeFromSelectedPointsOfSale,
          selectedPointsOfSaleIds: selectedPointsOfSaleIds,
          availablePointsOfSale:
              pointsOfSaleProvider.routelessPointsOfSale + previousPointsOfSale,
        ),
      ),
    );
  }

  List<User> availableOperators = [];

  Future getAvailableOperators() async {
    var selectedPointsOfSale = <PointOfSale>[];
    selectedPointsOfSaleIds.forEach((id) {
      selectedPointsOfSale.add(pointsOfSaleProvider.pointsOfSale
          .firstWhere((element) => element.id == id));
    });
    var groupIds = <String>[];
    selectedPointsOfSale.forEach((element) {
      groupIds.add(element.groupId);
    });
    interfaceService.showLoader();
    availableOperators = await userProvider.getAvailableOperators(groupIds);
    interfaceService.closeLoader();
    notifyListeners();
  }

  Future editRoute() async {
    var shouldEditWithoutOperator = true;
    if (validateFields()) {
      if (selectedOperatorId == null) {
        await interfaceService.showDialogMessage(
          title: 'Atenção',
          message:
              'A sua rota não possui nenhum operador responsável. Você poderá adicioná-lo posteriormente.',
          actions: [
            DialogAction(
              title: 'Cancelar',
              onPressed: () {
                locator<InterfaceService>().goBack();
                shouldEditWithoutOperator = false;
              },
            ),
            DialogAction(
              title: 'Confirmar',
              onPressed: () {
                locator<InterfaceService>().goBack();
                locator<InterfaceService>().showLoader();
                shouldEditWithoutOperator = true;
              },
            )
          ],
        );
      }
      if (shouldEditWithoutOperator) {
        locator<InterfaceService>().showLoader();
        var response =
            await routesProvider.editRoute(getRouteData(), operatorRoute.id);
        locator<InterfaceService>().closeLoader();
        if (response.status == Status.success) {
          locator<InterfaceService>().showSnackBar(
              message: 'Rota editada com sucesso.',
              backgroundColor: colors.lightGreen);
          locator<InterfaceService>().goBack();
        } else {
          locator<InterfaceService>().showSnackBar(
              message: translateError(response.data),
              backgroundColor: colors.red);
        }
      }
    }
  }

  Future createRoute() async {
    var shouldCreateWithoutOperator = true;
    if (validateFields()) {
      if (selectedOperatorId == null) {
        await interfaceService.showDialogMessage(
          title: 'Atenção',
          message:
              'A sua rota não possui nenhum operador responsável. Você poderá adicioná-lo posteriormente.',
          actions: [
            DialogAction(
              title: 'Cancelar',
              onPressed: () {
                locator<InterfaceService>().goBack();
                shouldCreateWithoutOperator = false;
              },
            ),
            DialogAction(
              title: 'Confirmar',
              onPressed: () {
                locator<InterfaceService>().goBack();
                locator<InterfaceService>().showLoader();
                shouldCreateWithoutOperator = true;
              },
            )
          ],
        );
      }
      if (shouldCreateWithoutOperator) {
        locator<InterfaceService>().showLoader();
        var data = getRouteData();
        if (data['operatorId'] == null) {
          data.remove('operatorId');
        }
        var response = await routesProvider.createRoute(data);
        locator<InterfaceService>().closeLoader();
        if (response.status == Status.success) {
          locator<InterfaceService>().showSnackBar(
              message: 'Rota criada com sucesso.',
              backgroundColor: colors.lightGreen);
          locator<InterfaceService>().goBack();
        } else {
          locator<InterfaceService>().showSnackBar(
              message: translateError(response.data),
              backgroundColor: colors.red);
        }
      }
    }
  }

  Map<String, dynamic> getRouteData() {
    if (selectedOperatorId != null) {
      return {
        'label': label,
        'pointsOfSaleIds': selectedPointsOfSaleIds,
        'operatorId': selectedOperatorId,
      };
    } else {
      return {
        'label': label,
        'pointsOfSaleIds': selectedPointsOfSaleIds,
        'operatorId': null,
      };
    }
  }

  bool validateFields() {
    if (selectedPointsOfSaleIds.isEmpty) {
      interfaceService.showSnackBar(
          message: 'Selecione ao menos um ponto de venda',
          backgroundColor: colors.red);
      return false;
    }
    if (label == null) {
      interfaceService.showSnackBar(
          message: 'Dê um nome à rota', backgroundColor: colors.red);
      return false;
    }
    return true;
  }
}
