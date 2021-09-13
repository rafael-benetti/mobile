import 'package:black_telemetry/src/core/models/machine.dart';
import 'package:black_telemetry/src/core/models/user.dart';
import 'package:black_telemetry/src/core/providers/collections_provider.dart';
import 'package:black_telemetry/src/core/providers/machines_provider.dart';
import 'package:black_telemetry/src/core/providers/routes_provider.dart';
import 'package:black_telemetry/src/core/providers/user_provider.dart';
import 'package:black_telemetry/src/core/services/interface_service.dart';
import 'package:black_telemetry/src/interface/pages/collections/widgets.dart';
import 'package:black_telemetry/src/interface/pages/edit_collection/edit_collection_page.dart';
import 'package:black_telemetry/src/interface/shared/colors.dart';
import 'package:black_telemetry/src/interface/widgets/dialog_action.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../locator.dart';

class CollectionsPageModel extends BaseViewModel {
  final machinesProvider = locator<MachinesProvider>();
  final interfaceService = locator<InterfaceService>();
  final routesProvider = locator<RoutesProvider>();
  final userProvider = locator<UserProvider>();
  final colors = locator<AppColors>();
  final collectionsProvider = locator<CollectionsProvider>();
  List<User> availableUsers = [];
  List<LeanMachine> searchedMachines;
  Machine selectedMachine;
  String selectedMachineId;
  int offset = 0;
  String keywords;
  String userId;
  String routeId;
  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await machinesProvider.getLeanMachines();
    await routesProvider.getRoutes(shouldClearCurrentList: true);
    await userProvider.getAllOperators();
    await userProvider.getAllManagers();
    availableUsers = userProvider.managers + userProvider.operators;
    await collectionsProvider.getCollections(
        offset: offset, clearCurrentList: true);
    searchedMachines = machinesProvider.leanMachines
        .where((element) => element.locationId != null)
        .toList();
    interfaceService.closeLoader();
    setBusy(false);
  }

  void filterCollections(bool clearCurrentList) async {
    interfaceService.showLoader();
    if (clearCurrentList) offset = 0;
    await collectionsProvider.getCollections(
      clearCurrentList: clearCurrentList,
      offset: offset,
      keywords: keywords,
      routeId: routeId,
      operatorId: userId,
    );
    interfaceService.closeLoader();
  }

  void setSelectedMachine(LeanMachine leanMachine) async {
    if (leanMachine == null) {
      selectedMachine = null;
      return;
    }
    selectedMachineId = leanMachine.id;
  }

  void newCollection() {
    interfaceService.showDialogWithWidgets(
      title: 'Selecione a máquina',
      color: colors.primaryColor,
      isDismissible: false,
      widget: SingleChildScrollView(
        child: MachinesList(
          searchedMachines: searchedMachines,
          setSelectedMachine: setSelectedMachine,
        ),
      ),
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            selectedMachine = null;
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () async {
            if (selectedMachineId != null) {
              interfaceService.showLoader();
              await machinesProvider.getDetailedMachine(
                  selectedMachineId, 'DAILY');
              selectedMachine = machinesProvider.detailedMachine.machine;
              interfaceService.closeLoader();
              interfaceService.goBack();
              if (selectedMachine.telemetryBoardId != null) {
                if (selectedMachine.lastConnection != null) {
                  var isOnline = DateTime.now()
                          .difference(selectedMachine.lastConnection.toLocal())
                          .inMinutes <
                      10;
                  if (isOnline) {
                    await interfaceService.navigateTo(EditCollectionPage.route,
                        arguments: selectedMachine);
                    selectedMachine = null;
                  } else {
                    interfaceService.showSnackBar(
                      message: 'Essa máquina está offline.',
                      backgroundColor: colors.red,
                    );
                  }
                } else {
                  interfaceService.showSnackBar(
                    message: 'Essa máquina está offline.',
                    backgroundColor: colors.red,
                  );
                }
              } else {
                interfaceService.showSnackBar(
                  message: 'Essa máquina não possui uma telemetria.',
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
