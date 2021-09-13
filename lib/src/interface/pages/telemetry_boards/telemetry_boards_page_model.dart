import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/providers/user_provider.dart';

import '../../../core/models/telemetry_board.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/telemetry_boards_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/interface_service.dart';
import '../../../locator.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/dialog_action.dart';
import '../detailed_machine/detailed_machine_page.dart';

class TelemetryBoardsPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final telemetryBoardsProvider = locator<TelemetryBoardsProvider>();
  final groupsProvider = locator<GroupsProvider>();
  final userProvider = locator<UserProvider>();
  int offset = 0;
  String groupId;
  String telemetryBoardId;

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await telemetryBoardsProvider.getFilteredTelemetries(
        offset: offset, shouldClearCurrentList: true);
    await groupsProvider.getAllGroups();
    interfaceService.closeLoader();
    setBusy(false);
  }

  void transferBoard(String groupId, TelemetryBoard telemetryBoard) async {
    interfaceService.showLoader();
    var response = await telemetryBoardsProvider
        .transferBoard({'groupId': groupId}, telemetryBoard.id);
    interfaceService.closeLoader();
    if (response.status == Status.success) {
      interfaceService.showSnackBar(
          message: 'STG-${telemetryBoard.id} transferia com sucesso.',
          backgroundColor: colors.lightGreen);
    } else {
      interfaceService.showSnackBar(
          message: 'Erro ao transferir STG-${telemetryBoard.id}.',
          backgroundColor: colors.red);
    }
  }

  Future filterTelemetries(bool shouldClearCurrentList) async {
    if (shouldClearCurrentList) {
      offset = 0;
    }
    interfaceService.showLoader();
    await telemetryBoardsProvider.getFilteredTelemetries(
      offset: offset,
      shouldClearCurrentList: shouldClearCurrentList,
      groupId: groupId,
      telemetryBoardId: telemetryBoardId,
    );
    interfaceService.closeLoader();
  }

  void popTransferBoardDialog(TelemetryBoard telemetryBoard) async {
    String groupId;
    if (telemetryBoard.machineId == null) {
      if (userProvider.user.permissions.editGroups) {
        await interfaceService.showDialogWithWidgets(
          title: '(STG-${telemetryBoard.id})',
          message: 'Para qual parceria deseja transferir?',
          isDismissible: false,
          color: colors.primaryColor,
          widget: SizedBox(
            width: 500,
            child: CustomDropdownButton(
              initialValue: DropdownInputOption(title: ''),
              onSelect: (value) => groupId = groupsProvider.groups
                  .firstWhere((element) => element.label == value.title)
                  .id,
              values: List.generate(
                groupsProvider.groups.length,
                (index) => DropdownInputOption(
                    title: groupsProvider.groups[index].label),
              ),
            ),
          ),
          actions: [
            DialogAction(
              title: 'Cancelar',
              onPressed: () => interfaceService.goBack(),
            ),
            DialogAction(
                title: 'Confirmar',
                onPressed: () {
                  if (groupId == null) {
                    interfaceService.showSnackBar(
                        message: 'Selecione a parceria',
                        backgroundColor: colors.red);
                  } else {
                    interfaceService.goBack();
                    transferBoard(groupId, telemetryBoard);
                  }
                })
          ],
        );
      } else {
        await interfaceService.showDialogMessage(
          title: 'Não é possível transferir',
          message: 'Você não possui a permissão para transferir telemetrias',
        );
      }
    } else {
      await interfaceService.showDialogMessage(
        title: 'Não é possivel transferir!',
        message:
            'A placa STG-${telemetryBoard.id} está atualmente vinculada à uma máquina.',
        actions: [
          DialogAction(
            title: 'Voltar',
            onPressed: () {
              interfaceService.goBack();
            },
          ),
          DialogAction(
            title: 'Visão geral da máquina',
            onPressed: () {
              interfaceService.goBack();
              interfaceService.navigateTo(DetailedMachinePage.route,
                  arguments: telemetryBoard.machineId);
            },
          )
        ],
      );
    }
  }
}
