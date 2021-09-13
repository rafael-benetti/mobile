import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../core/models/group.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/points_of_sale_provider.dart';
import '../../../core/providers/telemetry_boards_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../edit_machine/edit_machine_page.dart';
import '../../shared/colors.dart';
import '../../shared/enums.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dialog_action.dart';
import '../../widgets/transfer.dart';

import '../../../locator.dart';

class GroupStockPageModel extends BaseViewModel {
  final interfaceService = locator<InterfaceService>();
  final user = locator<UserProvider>().user;
  final colors = locator<AppColors>();

  final groupsProvider = locator<GroupsProvider>();
  final pointsOfSaleProvider = locator<PointsOfSaleProvider>();
  final userProvider = locator<UserProvider>();
  final telemetryBoardsProvider = locator<TelemetryBoardsProvider>();

  CurrentlyShowing currentlyShowing = CurrentlyShowing.PRIZES;

  void toggleCurrentlyShowing(CurrentlyShowing value) {
    currentlyShowing = value;
    notifyListeners();
  }

  Future filterStock([String groupId]) async {
    interfaceService.showLoader();
    if (groupId != null) {
      await groupsProvider.getStock(groupId: groupId);
    } else {
      await groupsProvider.getStock();
    }
    setCurrentlyShowing();
    interfaceService.closeLoader();
  }

  void setCurrentlyShowing() {
    if (groupsProvider.prizes.isNotEmpty) {
      toggleCurrentlyShowing(CurrentlyShowing.PRIZES);
    } else if (groupsProvider.machinesInStock.isNotEmpty) {
      toggleCurrentlyShowing(CurrentlyShowing.MACHINES);
    } else if (groupsProvider.supplies.isNotEmpty) {
      toggleCurrentlyShowing(CurrentlyShowing.PRIZES);
    }
  }

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await groupsProvider.getAllGroups();
    await groupsProvider.getStock();
    await userProvider.getAllOperators();
    await userProvider.getAllManagers();
    await telemetryBoardsProvider.getAllTelemetries();
    setCurrentlyShowing();
    interfaceService.closeLoader();
    setBusy(false);
  }

//CREATING STOCK BRUH
  void popSelectItemToCreateDialog() {
    String chosenStockItem;
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      actions: [
        DialogAction(title: 'Voltar', onPressed: interfaceService.goBack),
        DialogAction(
            title: 'Continuar',
            onPressed: () {
              if (chosenStockItem == null) {
                interfaceService.showSnackBar(
                    message: 'Escolha um tipo de produto para criar',
                    backgroundColor: colors.red);
                return;
              }
              interfaceService.goBack();
              if (chosenStockItem == 'Máquina') {
                interfaceService.navigateTo(EditMachinePage.route,
                    arguments: 'create@stock');
              } else {
                popCreateItemDialog(chosenStockItem);
              }
            }),
      ],
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tipo do produto'),
          SizedBox(height: 10),
          Container(
            width: 255,
            child: CustomDropdownButton(
              initialValue: DropdownInputOption(title: ''),
              onSelect: (option) {
                chosenStockItem = option.title;
              },
              values: [
                DropdownInputOption(title: 'Prêmio'),
                DropdownInputOption(title: 'Máquina'),
                DropdownInputOption(title: 'Suprimento'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void popCreateItemDialog(String type) {
    int quantity;
    String label;
    double cost;
    String groupId;
    switch (type) {
      case 'Prêmio':
        type = 'PRIZE';
        break;
      case 'Suprimento':
        type = 'SUPPLY';
        break;
      default:
    }
    interfaceService.showDialogWithWidgets(
      color: colors.primaryColor,
      actions: [
        DialogAction(
            title: 'Voltar',
            onPressed: () {
              interfaceService.goBack();
              popSelectItemToCreateDialog();
            }),
        DialogAction(
            title: 'Criar',
            onPressed: () {
              createStockItem(quantity, type, label, cost, groupId);
            }),
      ],
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parceria'),
          SizedBox(height: 5),
          Container(
            width: 270,
            child: CustomDropdownButton(
              maxHeight: 157.5,
              initialValue: DropdownInputOption(title: ''),
              onSelect: (option) {
                groupId = groupsProvider.groups
                    .firstWhere((element) => element.label == option.title)
                    .id;
              },
              values: List.generate(
                groupsProvider.groups.length,
                (index) => DropdownInputOption(
                    title: groupsProvider.groups[index].label),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(type == 'PRIZE' ? 'Nome do prêmio' : 'Nome do suprimento'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              onChanged: (value) => {
                if (value == '')
                  {
                    label = null,
                  }
                else
                  {
                    label = value,
                  }
              },
            ),
          ),
          SizedBox(height: 10),
          Text('Quantidade'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => {
                if (value == '')
                  {quantity = null}
                else
                  {quantity = int.parse(value)}
              },
            ),
          ),
          SizedBox(height: 10),
          Text('Custo unitário (R\$)'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                RealInputFormatter(centavos: true)
              ],
              onChanged: (value) {
                if (value == '') {
                  cost = null;
                } else {
                  var tmp = value.replaceAll('.', '').replaceAll(',', '.');
                  cost = double.parse(tmp);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool validateCreateItemFields(
    int quantity,
    String label,
    double cost,
    String groupId,
  ) {
    if (groupId == null) {
      interfaceService.showSnackBar(
          message: 'Parceria é obrigatório', backgroundColor: colors.red);
      return false;
    }
    if (label == null && label == '') {
      interfaceService.showSnackBar(
          message: 'Nome é obrigatório', backgroundColor: colors.red);
      return false;
    }
    if (quantity == null) {
      interfaceService.showSnackBar(
          message: 'Quantidade é obrigatório', backgroundColor: colors.red);
      return false;
    }
    if (quantity < 0) {
      interfaceService.showSnackBar(
          message: 'Quantidade deve ser maior ou igual à zero.',
          backgroundColor: colors.red);
      return false;
    }
    if (cost == null) {
      interfaceService.showSnackBar(
          message: 'Custo unitário é obrigatório', backgroundColor: colors.red);
      return false;
    }
    if (cost < 0) {
      interfaceService.showSnackBar(
          message: 'Custo deve ser maior ou igual à zero',
          backgroundColor: colors.red);
      return false;
    }
    return true;
  }

  Future createStockItem(int quantity, String type, String label, double cost,
      String groupId) async {
    if (validateCreateItemFields(quantity, label, cost, groupId)) {
      if (type == 'PRIZE') {
        interfaceService.showLoader();
        var response = await groupsProvider.createPrize({
          'groupId': groupId,
          'label': label,
          'type': type,
          'quantity': quantity,
          'cost': cost
        });

        if (response.status == Status.success) {
          interfaceService.closeLoader();
          interfaceService.goBack();
          interfaceService.showSnackBar(
              message: 'Prêmio criado com sucesso.',
              backgroundColor: colors.lightGreen);
        }
      } else {
        interfaceService.showLoader();
        var response = await groupsProvider.createSupply({
          'groupId': groupId,
          'label': label,
          'type': type,
          'quantity': quantity,
          'cost': cost
        });

        if (response.status == Status.success) {
          interfaceService.closeLoader();
          interfaceService.goBack();
          interfaceService.showSnackBar(
              message: 'Suprimento criado com sucesso.',
              backgroundColor: colors.lightGreen);
        }
      }
    }
  }

//ADDING TO STOCK BRUH
  void popAddToStockDialog(dynamic item, String type) {
    int quantity;
    double cost;
    interfaceService.showDialogWithWidgets(
      title: 'Adicionar à ${item.label}',
      color: colors.primaryColor,
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Adicionar',
          onPressed: () {
            addToStock(item, cost, quantity, type);
          },
        ),
      ],
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantidade'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => {
                if (value == '')
                  {
                    quantity = null,
                  }
                else
                  {
                    quantity = int.parse(value),
                  }
              },
            ),
          ),
          SizedBox(height: 10),
          Text('Custo unitário (R\$)'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                RealInputFormatter(centavos: true)
              ],
              onChanged: (value) {
                if (value == '') {
                  cost = null;
                } else {
                  var tmp = value.replaceAll(',', '.');
                  cost = double.parse(tmp);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool validateAddToStockFields(double cost, int quantity) {
    if (cost == null) {
      interfaceService.showSnackBar(
          message: 'Custo unitário é obrigatório', backgroundColor: colors.red);
      return false;
    }
    if (quantity == null) {
      interfaceService.showSnackBar(
          message: 'Quantidade é obrigatório', backgroundColor: colors.red);
      return false;
    }

    if (quantity < 0) {
      interfaceService.showSnackBar(
          message: 'Quantidade deve ser maior que 0',
          backgroundColor: colors.red);
      return false;
    }
    return true;
  }

  Future addToStock(
      dynamic item, double cost, int quantity, String type) async {
    if (validateAddToStockFields(cost, quantity)) {
      var response = await groupsProvider.addToStock({
        'groupId': item.groupId,
        'quantity': quantity,
        'cost': cost,
        'type': type,
      }, item.id);
      if (response.status == Status.success) {
        interfaceService.goBack();
        interfaceService.showSnackBar(
            message: '$quantity unidades adicionadas à ${item.label}',
            backgroundColor: colors.lightGreen);
      } else {
        interfaceService.showSnackBar(
          message:
              'Não foi possível adicionar à ${item.label}. Tente novamente.',
          backgroundColor: colors.red,
        );
      }
    }
  }

//REMOVING FROM STOCK BRUH
  void popRemoveFromStockDialog(dynamic item, String type) {
    int quantity;
    double cost;
    interfaceService.showDialogWithWidgets(
      title: 'Remover de \'${item.label}\'',
      color: colors.primaryColor,
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Remover',
          onPressed: () {
            if (quantity != null && quantity > item.quantity) {
              interfaceService.showSnackBar(
                  message: 'Quantidade maior que disponível em estoque',
                  backgroundColor: colors.red);
            } else {
              removeFromStock(item, cost, quantity, type);
            }
          },
        ),
      ],
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disponível: ${item.quantity}'),
          SizedBox(height: 15),
          Text('Quantidade'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => {
                if (value == '')
                  {
                    quantity = null,
                  }
                else
                  {
                    quantity = int.parse(value),
                  }
              },
            ),
          ),
          SizedBox(height: 10),
          Text('Custo unitário (R\$)'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                RealInputFormatter(centavos: true)
              ],
              onChanged: (value) {
                if (value == '') {
                  cost = null;
                } else {
                  var tmp = value.replaceAll(',', '.');
                  cost = double.parse(tmp);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool validateRemoveFromStock(double cost, int quantity) {
    if (cost == null) {
      interfaceService.showSnackBar(
          message: 'Custo unitário é obrigatório', backgroundColor: colors.red);
      return false;
    }

    if (cost <= 0) {
      interfaceService.showSnackBar(
          message: 'Custo deve ser maior que zero',
          backgroundColor: colors.red);
      return false;
    }

    if (quantity == null) {
      interfaceService.showSnackBar(
          message: 'Quantidade é obrigatório', backgroundColor: colors.red);
      return false;
    }

    if (quantity <= 0) {
      interfaceService.showSnackBar(
          message: 'Quantidade deve ser maior que 0',
          backgroundColor: colors.red);
      return false;
    }
    return true;
  }

  Future removeFromStock(
      dynamic item, double cost, int quantity, String type) async {
    if (validateRemoveFromStock(cost, quantity)) {
      var response = await groupsProvider.addToStock({
        'groupId': item.groupId,
        'quantity': quantity * -1,
        'cost': cost,
        'type': type,
      }, item.id);
      if (response.status == Status.success) {
        interfaceService.goBack();
        interfaceService.showSnackBar(
            message: '$quantity unidades removidas de ${item.label}',
            backgroundColor: colors.lightGreen);
      } else {
        interfaceService.showSnackBar(
          message:
              'Não foi possível remover de ${item.label}. Tente novamente.',
          backgroundColor: colors.red,
        );
      }
    }
  }

//TRANSFERING FROM GROUP STOCK BRUH
  void popSelectReceiverDialog(dynamic item, String type) {
    String selected;
    void getSelectedOption(int i) {
      if (i == 0) {
        selected = 'GROUP';
      } else if (i == 1) {
        selected = 'MANAGER';
      } else if (i == 2) {
        selected = 'OPERATOR';
      } else {
        selected = 'MACHINE';
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
                    } else if (selected == 'GROUP') {
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
        operators: userProvider.operators,
        isFromGroupStock: true,
      ),
    );
  }

  void popGroupSelectionDialog(dynamic item, String type) {
    Group selectedGroup;
    var groups = List<Group>.from(groupsProvider.groups);
    groups.remove(groups.firstWhere((element) => element.id == item.groupId));
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
                  message: 'Selecione o destinatário da transferência',
                  backgroundColor: colors.red);
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
                      userProvider.operators.length,
                      (index) => DropdownInputOption(
                        title: userProvider.operators[index].name,
                      ),
                    )
                  : List.generate(
                      userProvider.managers.length,
                      (index) => DropdownInputOption(
                        title: userProvider.managers[index].name,
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
    double cost;
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
            if (amountToBeTransfered > item.quantity) {
              interfaceService.showSnackBar(
                  message: 'Quantidade maior que total disponível',
                  backgroundColor: colors.red);
            } else {
              await transferStockItem({
                'from': {
                  'id': item.groupId,
                  'type': 'GROUP',
                },
                'productType': type,
                'productQuantity': amountToBeTransfered,
                'cost': cost,
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
          SizedBox(height: 10),
          Text('Custo unitário (R\$)'),
          SizedBox(height: 5),
          Container(
            child: CustomTextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value == '') {
                  cost = null;
                } else {
                  var tmp = value.replaceAll(',', '.');
                  cost = double.parse(tmp);
                }
              },
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
                  'id': item.groupId,
                  'type': 'GROUP',
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
    var response = await groupsProvider.transferFromGroupStock(data, id);
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
            title: 'OK',
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
