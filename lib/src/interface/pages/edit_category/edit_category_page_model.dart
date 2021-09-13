import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../core/services/api_service.dart';
import '../../shared/error_translator.dart';
import '../../../core/models/box.dart';
import '../../../core/models/category.dart';
import '../../../core/models/counter.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../core/providers/counter_types_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';

import '../../../locator.dart';

class EditCategoryPageModel extends BaseViewModel {
  Category category = Category();
  final categoriesProvider = locator<CategoriesProvider>();
  final counterTypesProvider = locator<CounterTypesProvider>();
  final interfaceService = locator<InterfaceService>();

  int numberOfCabins = 1;

  List<Box> boxes = [];

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    if (counterTypesProvider.counterTypes.isEmpty) {
      await counterTypesProvider.getAllCounterTypes();
    }
    interfaceService.closeLoader();
    setBusy(false);
  }

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

  void editCategory() async {
    category.boxes = boxes;
    if (!validateFields()) {
      return;
    }
    locator<InterfaceService>().showLoader();
    var response = await categoriesProvider.editCategory(
        category.toMap(false), category.id);
    if (response.status == Status.success) {
      locator<InterfaceService>().showSnackBar(
          message: 'Categoria editada com sucesso.',
          backgroundColor: locator<AppColors>().lightGreen);
      locator<InterfaceService>().goBack();
    } else {
      locator<InterfaceService>().showSnackBar(
          message: translateError(response.data),
          backgroundColor: locator<AppColors>().red);
    }
    locator<InterfaceService>().closeLoader();
  }

  void createCategory() async {
    category.boxes = boxes;
    if (!validateFields()) {
      return;
    }
    locator<InterfaceService>().showLoader();
    var response = await categoriesProvider.createCategory(category.toMap());
    if (response.status == Status.success) {
      locator<InterfaceService>().showSnackBar(
          message: 'Categoria criada com sucesso.',
          backgroundColor: locator<AppColors>().lightGreen);
      locator<InterfaceService>().goBack();
    } else {
      locator<InterfaceService>().showSnackBar(
          message: translateError(response.data),
          backgroundColor: locator<AppColors>().red);
    }
    locator<InterfaceService>().closeLoader();
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

  bool validateFields() {
    if (category.label == null) {
      locator<InterfaceService>().showSnackBar(
        message: 'O campo nome é obrigatório.',
        backgroundColor: locator<AppColors>().red,
      );
      return false;
    }
    for (var i = 0; i < category.boxes.length; i++) {
      for (var z = 0; z < category.boxes[i].counters.length; z++) {
        var singleCounter = category.boxes[i].counters[z].checkMissingFields();
        if (!singleCounter['allIsFilled']) {
          locator<InterfaceService>().showSnackBar(
              message:
                  'O campo ${singleCounter['uncompleteField']} é obrigatório.',
              backgroundColor: locator<AppColors>().red);
          return false;
        }
      }
    }
    if (category.boxes.isEmpty) {
      locator<InterfaceService>().showSnackBar(
          message: 'A categoria deve conter pelo menos uma cabine.',
          backgroundColor: locator<AppColors>().red);
      return false;
    }
    return true;
  }
}
