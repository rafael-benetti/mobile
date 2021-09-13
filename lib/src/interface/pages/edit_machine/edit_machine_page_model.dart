import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/pages/detailed_machine/detailed_machine_page.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../core/models/box.dart';
import '../../../core/models/category.dart';
import '../../../core/models/counter.dart';
import '../../../core/models/group.dart';
import '../../../core/models/machine.dart';
import '../../../core/models/point_of_sale.dart';
import '../../../core/models/telemetry_board.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/counter_types_provider.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/machines_provider.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/providers/telemetry_boards_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../edit_category/edit_category_page.dart';
import '../../shared/colors.dart';
import '../../widgets/dialog_action.dart';
import '../../../locator.dart';

class EditMachinePageModel extends BaseViewModel {
  Machine machine = Machine();
  List<Box> boxes = [];

  List<String> pinList = [
    'Pino 2',
    'Pino 3',
    'Pino 4',
    'Pino 5',
    'Pino 6',
    'Pino 7',
    'Pino 8',
    'Pino 9',
    'Pino 10',
    'Pino 11',
    'Pino 12',
    'Pino 13',
  ];

  void updatePinList() {
    pinList = [
      'Pino 2',
      'Pino 3',
      'Pino 4',
      'Pino 5',
      'Pino 6',
      'Pino 7',
      'Pino 8',
      'Pino 9',
      'Pino 10',
      'Pino 11',
      'Pino 12',
      'Pino 13'
    ];
    boxes.forEach((box) {
      box.counters.forEach((counter) {
        pinList.remove(counter.pin);
      });
    });
    notifyListeners();
  }

  final _machinesProvider = locator<MachinesProvider>();
  final userProvider = locator<UserProvider>();
  final counterTypesProvider = locator<CounterTypesProvider>();
  final telemetriesProvider = locator<TelemetryBoardsProvider>();
  final interfaceService = locator<InterfaceService>();

  Future loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await userProvider.getAllOperators();
    await counterTypesProvider.getAllCounterTypes();
    await telemetriesProvider.getAllTelemetries();
    if (categories.isEmpty) {
      popNoCategoriesFoundDialog();
    }
    interfaceService.closeLoader();
    setBusy(false);
  }

  void popNoCategoriesFoundDialog() {
    interfaceService.showDialogMessage(
        title: 'Atenção',
        isDismissible: false,
        message:
            'Você não possui nenhuma categoria cadastrada. É necessário ter ao menos uma para criar uma máquina.',
        actions: [
          DialogAction(
            title: 'Voltar para o menu',
            onPressed: () {
              interfaceService.goBack();
              interfaceService.goBack();
              interfaceService.goBack();
            },
          ),
          DialogAction(
              title: 'Criar uma categoria',
              onPressed: () {
                interfaceService.goBack();
                interfaceService.goBack();
                interfaceService.navigateTo(EditCategoryPage.route);
              })
        ]);
  }

  final List<PointOfSale> pointsOfSale =
      locator<PointsOfSaleProvider>().pointsOfSale;

  final List<Category> categories = locator<CategoriesProvider>().categories;

  final List<Group> groups = locator<GroupsProvider>().groups;
  final groupsProvider = locator<GroupsProvider>();
  List<PointOfSale> pointsOfSaleByGroup = [];
  List<TelemetryBoard> telemetriesByGroup = [];
  List<User> operatorsByGroup = [];

  bool creatingInStock = false;

  void sortListsByGroup() async {
    interfaceService.showLoader();
    pointsOfSaleByGroup = pointsOfSale
        .where((element) => element.groupId == machine.groupId)
        .toList();
    operatorsByGroup =
        await userProvider.getAvailableOperators([machine.groupId]);
    telemetriesByGroup = telemetriesProvider.telemetries
        .where((element) => element.groupId == machine.groupId)
        .where((element) => element.machineId == null)
        .toList();
    groupsProvider.getGroupPrizesByGroupId(machine.groupId);
    interfaceService.closeLoader();
    notifyListeners();
  }

  void setSelectedCategory(String label) {
    boxes = categories.firstWhere((element) => element.label == label).boxes;
    machine.categoryId =
        categories.firstWhere((element) => element.label == label).id;
    machine.categoryLabel = label;
    notifyListeners();
  }

  void addBox(ScrollController scrollController) async {
    boxes.add(Box());
    notifyListeners();
    Future.delayed(Duration(milliseconds: 300), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  void removeBox(int index) {
    boxes.removeAt(index);
    notifyListeners();
  }

  void removeCounter(int cabinIndex, int counterIndex) {
    boxes[cabinIndex].counters.removeAt(counterIndex);
    notifyListeners();
  }

  void addCounter(int index) {
    boxes[index].counters.add(Counter());
    notifyListeners();
  }

  void createMachine() async {
    machine.boxes = boxes;
    if (validateFields()) {
      interfaceService.showLoader();
      var response = await _machinesProvider.createMachine(machine.toMap(true));
      if (response.status == Status.success) {
        interfaceService.showSnackBar(
            message: 'Máquina criada com sucesso.',
            backgroundColor: locator<AppColors>().lightGreen);
        interfaceService.goBack();
        await interfaceService.navigateTo(DetailedMachinePage.route,
            arguments: response.data['id']);
      } else {
        interfaceService.showSnackBar(
            message: translateError(response.data),
            backgroundColor: locator<AppColors>().red);
      }
      interfaceService.closeLoader();
    }
    return;
  }

  void editMachine() async {
    machine.boxes = boxes;
    if (validateFields()) {
      interfaceService.showLoader();
      var response =
          await _machinesProvider.editMachine(machine.toMap(false), machine.id);
      interfaceService.closeLoader();
      if (response.status == Status.success) {
        interfaceService.showSnackBar(
            message: 'Máquina editada com sucesso.',
            backgroundColor: locator<AppColors>().lightGreen);
        interfaceService.goBack();
      } else {
        interfaceService.showSnackBar(
          message: translateError(json.encode(response.data)),
          backgroundColor: locator<AppColors>().red,
        );
      }
    }
    return;
  }

  bool validateFields() {
    //FIELDS
    if (machine.serialNumber == null || machine.serialNumber == '') {
      interfaceService.showSnackBar(
        message: 'O campo número de série é obrigatório.',
        backgroundColor: locator<AppColors>().red,
      );
      return false;
    }
    if (machine.groupId == null) {
      interfaceService.showSnackBar(
        message: 'O campo parceria é obrigatório.',
        backgroundColor: locator<AppColors>().red,
      );
      return false;
    }
    if (machine.gameValue == null) {
      interfaceService.showSnackBar(
          message: 'O campo valor da jogada é obrigatório.',
          backgroundColor: locator<AppColors>().red);
      return false;
    }

    if (boxes.isEmpty) {
      interfaceService.showSnackBar(
          message: 'Selecione a categoria da máquina.',
          backgroundColor: locator<AppColors>().red);
      return false;
    }

    //BOXES
    for (var i = 0; i < machine.boxes.length; i++) {
      for (var z = 0; z < machine.boxes[i].counters.length; z++) {
        var singleCounter = machine.boxes[i].counters[z].checkMissingFields();
        if (!singleCounter['allIsFilled']) {
          interfaceService.showSnackBar(
              message:
                  'O campo ${singleCounter['uncompleteField']} é obrigatório.',
              backgroundColor: locator<AppColors>().red);
          return false;
        }
      }
    }
    return true;
  }

  void popMinimumPrizeCountInfo() {
    interfaceService.showDialogMessage(
        title: 'Estoque mínimo',
        message:
            'Este campo define o estoque mínimo aceitável em cada cabine desta máquina para que o sistema dispare uma notificação para o operador responsável.');
  }

  void popIncomePerPrizeGoalInfo() {
    interfaceService.showDialogMessage(
        title: 'Meta de faturamento por prêmio',
        message:
            'Este campo define a meta financeira que a máquina coletará por prêmio entregue. Este valor aparecerá nos relatórios para comparação do faturamento por prêmio real.');
  }

  void popIncomePerMonthGoalInfo() {
    interfaceService.showDialogMessage(
        title: 'Meta de faturamento por mês',
        message:
            'Este campo define a meta financeira que a máquina coletará por mês. Este valor aparecerá nos relatórios para comparação do faturamento mensal real.');
  }
}
