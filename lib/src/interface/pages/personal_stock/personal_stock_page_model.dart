import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../core/models/group.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../shared/enums.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dialog_action.dart';
import '../../widgets/transfer.dart';

import '../../../locator.dart';

class PersonalStockPageModel extends BaseViewModel {
  final userProvider = locator<UserProvider>();
  final interfaceService = locator<InterfaceService>();
  final user = locator<UserProvider>().user;
  final colors = locator<AppColors>();
  final groupsProvider = locator<GroupsProvider>();

  CurrentlyShowing currentlyShowing = CurrentlyShowing.PRIZES;

  void toggleCurrentlyShowing(CurrentlyShowing value) {
    currentlyShowing = value;
    notifyListeners();
  }

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await userProvider.fetchUser();
    await groupsProvider.getAllGroups();
    await userProvider.getAllOperators();
    await userProvider.getAllManagers();
    interfaceService.closeLoader();
    setBusy(false);
  }

  void popSelectReceiverDialog(dynamic item, String type) {
    String selected;
    void getSelectedOption(int i) {
      if (i == 0) {
        selected = 'GROUP';
      } else if (i == 1) {
        selected = 'MANAGER';
      } else {
        selected = 'OPERATOR';
      }
    }

    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      actions: (userProvider.managers.isEmpty &&
              userProvider.operators.isEmpty &&
              groupsProvider.groups.length <= 1)
          ? []
          : [
              DialogAction(
                title: 'Voltar',
                onPressed: () => {interfaceService.goBack()},
              ),
              DialogAction(
                title: 'Continuar',
                onPressed: () {
                  if (selected != null) {
                    interfaceService.goBack();
                    if (selected == 'MANAGER' || selected == 'OPERATOR') {
                      popUserSelectionDialog(selected, item, type);
                    } else {
                      popGroupSelectionDialog(item, type);
                    }
                  } else {
                    interfaceService.showSnackBar(
                        message: 'Defina para quem deseja transferir',
                        backgroundColor: colors.red);
                  }
                },
              )
            ],
      title: 'Transferir para:',
      widget: RadioSelector(
        getSelectedOption: getSelectedOption,
        groups: groupsProvider.groups,
        managers: userProvider.managers,
        operators: user.role == Role.OPERATOR ? [] : userProvider.operators,
        isFromGroupStock: false,
      ),
    );
  }

  void popGroupSelectionDialog(dynamic item, String type) {
    Group selectedGroup;
    var groups = List<Group>.from(groupsProvider.groups);
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      title: 'Selecione a parceria:',
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
            popSelectReceiverDialog(item, type);
          },
        ),
        DialogAction(
          title: 'Continuar',
          onPressed: () {
            if (selectedGroup == null) {
              interfaceService.showSnackBar(
                  message: 'Selecione o destinatário da transferência',
                  backgroundColor: colors.red);
            } else {
              interfaceService.goBack();
              popGroupTransferDialog(selectedGroup, item, type);
            }
          },
        )
      ],
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome'),
          SizedBox(height: 10),
          Container(
            width: 500,
            child: CustomDropdownButton(
              maxHeight: 292.5,
              initialValue: DropdownInputOption(title: ''),
              onSelect: (option) {
                selectedGroup = groups
                    .firstWhere((element) => element.label == option.title);
              },
              values: List.generate(
                groups.length,
                (index) => DropdownInputOption(
                  title: groups[index].label,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void popUserSelectionDialog(String userType, dynamic item, String type) {
    User selectedUser;
    var operators = List<User>.from(userProvider.operators);
    var managers = List<User>.from(userProvider.managers);
    if (userType == 'OPERATOR' && user.role == Role.OPERATOR) {
      operators.removeWhere((element) => element.id == user.id);
    } else if (userType == 'MANAGER' && user.role == Role.MANAGER) {
      managers.removeWhere((element) => element.id == user.id);
    }

    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      actions: [
        DialogAction(
          title: 'Voltar',
          onPressed: () {
            interfaceService.goBack();
            popSelectReceiverDialog(item, type);
          },
        ),
        DialogAction(
          title: 'Continuar',
          onPressed: () {
            if (selectedUser == null) {
              interfaceService.showSnackBar(
                message: 'Selecione o destinatário da transferência.',
                backgroundColor: colors.red,
              );
            } else {
              interfaceService.goBack();
              popUserTransferDialog(selectedUser, item, type);
            }
          },
        )
      ],
      title: userType == 'OPERATOR'
          ? 'Selecione o operador:'
          : 'Selecione o colaborador:',
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nome'),
          SizedBox(height: 10),
          Container(
            width: 500,
            child: CustomDropdownButton(
              maxHeight: 292.5,
              initialValue: DropdownInputOption(title: ''),
              onSelect: (option) {
                if (userType == 'OPERATOR') {
                  selectedUser = userProvider.operators
                      .firstWhere((element) => element.name == option.title);
                } else {
                  selectedUser = userProvider.managers
                      .firstWhere((element) => element.name == option.title);
                }
              },
              values: userType == 'OPERATOR'
                  ? List.generate(
                      operators.length,
                      (index) => DropdownInputOption(
                        title: operators[index].name,
                      ),
                    )
                  : List.generate(
                      managers.length,
                      (index) => DropdownInputOption(
                        title: managers[index].name,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void popGroupTransferDialog(Group group, dynamic item, String type) {
    int amountToBeTransfered;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      actions: [
        DialogAction(
            title: 'Voltar',
            onPressed: () {
              interfaceService.goBack();
              popGroupSelectionDialog(item, type);
            }),
        DialogAction(
          title: 'Transferir',
          onPressed: () async {
            if (amountToBeTransfered > item.available) {
              interfaceService.showSnackBar(
                  message: 'Quantidade maior que total disponível',
                  backgroundColor: colors.red);
            } else {
              await transferStockItem({
                'from': {
                  'id': user.id,
                  'type': 'USER',
                },
                'productType': type,
                'productQuantity': amountToBeTransfered,
                'to': {
                  'id': group.id,
                  'type': 'GROUP',
                }
              }, item.id, item, amountToBeTransfered, group: group);
            }
          },
        ),
      ],
      title:
          'Quantas unidades de ${item.label} você deseja transferir para ${group.label}?',
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disponível: ${item.available}'),
          SizedBox(height: 25),
          Text('Quantidade'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => {amountToBeTransfered = int.parse(value)},
            ),
          ),
        ],
      ),
    );
  }

  void popUserTransferDialog(User selectedUser, dynamic item, String type) {
    int amountToBeTransfered;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      actions: [
        DialogAction(
            title: 'Voltar',
            onPressed: () {
              interfaceService.goBack();
              popUserSelectionDialog(selectedUser.role.toString(), item, type);
            }),
        DialogAction(
          title: 'Transferir',
          onPressed: () async {
            if (amountToBeTransfered > item.quantity) {
              interfaceService.showSnackBar(
                  message: 'Quantidade maior que total disponível',
                  backgroundColor: colors.red);
            } else {
              await transferStockItem({
                'from': {
                  'id': user.id,
                  'type': 'USER',
                },
                'productType': type,
                'productQuantity': amountToBeTransfered,
                'to': {
                  'id': selectedUser.id,
                  'type': 'USER',
                }
              }, item.id, item, amountToBeTransfered, user: selectedUser);
            }
          },
        ),
      ],
      title:
          'Quantas unidades de ${item.label} você deseja transferir para ${selectedUser.name}?',
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disponível: ${item.quantity}'),
          SizedBox(height: 25),
          Text('Quantidade'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => {amountToBeTransfered = int.parse(value)},
            ),
          ),
        ],
      ),
    );
  }

  Future transferStockItem(Map<String, dynamic> data, String id, dynamic item,
      int amountToBeTransfered,
      {Group group, User user}) async {
    interfaceService.showLoader();
    var response = await userProvider.transferFromUserStock(data, id);
    interfaceService.closeLoader();
    if (response.status == Status.success) {
      interfaceService.goBack();
      await interfaceService.showDialogMessage(
        title: 'Relatório de transferência',
        message: group != null
            ? 'Quantidade: $amountToBeTransfered\nDe: ${item.label}\nPara: ${group.label}'
            : 'Quantidade: $amountToBeTransfered\nDe: ${item.label}\nPara: ${user.name}',
        actions: [
          DialogAction(
            title: 'Confirmar',
            onPressed: interfaceService.goBack,
          )
        ],
      );
    } else {
      interfaceService.showSnackBar(
          message: 'Oops! Algo deu errado. Tente novamente.',
          backgroundColor: colors.red);
    }
  }
}
