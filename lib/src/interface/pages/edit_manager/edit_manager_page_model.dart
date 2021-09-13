import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../widgets/dialog_action.dart';

import '../../../locator.dart';

class EditManagerPageModel extends BaseViewModel {
  User user = User.manager();
  final userProvider = locator<UserProvider>();
  final groupsProvider = locator<GroupsProvider>();
  final interfaceService = locator<InterfaceService>();
  final colors = locator<AppColors>();

  void loadData() async {
    setBusy(true);
    interfaceService.showLoader();
    await groupsProvider.getAllGroups();
    interfaceService.closeLoader();
    setBusy(false);
  }

  void addGroupId(String groupId) {
    if (!user.groupIds.contains(groupId)) {
      user.groupIds.add(groupId);
    } else {
      user.groupIds.remove(groupId);
    }
    notifyListeners();
  }

  void changeIsActive(value) {
    user.isActive = value;
    notifyListeners();
  }

  void toggleCreateManager(value) async {
    if (value) {
      var toggle = false;
      await interfaceService.showDialogMessage(
        title: 'Atenção',
        message:
            'Ao criar um colaborador que pode criar outros colaboradores, este terá, automaticamente, todas as permissões.',
        actions: [
          DialogAction(
            title: 'Cancelar',
            onPressed: () {
              interfaceService.goBack();
            },
          ),
          DialogAction(
            title: 'Confirmar',
            onPressed: () {
              toggle = true;
              interfaceService.goBack();
            },
          )
        ],
      );
      if (toggle) {
        user.permissions.createManagers = true;
        user.permissions.createOperators = true;
        user.permissions.listManagers = true;
        user.permissions.listOperators = true;
        user.permissions.generateReports = true;
        user.permissions.createGroups = true;
        user.permissions.editGroups = true;
        user.permissions.deleteGroups = true;
        user.permissions.createRoutes = true;
        user.permissions.editRoutes = true;
        user.permissions.deleteRoutes = true;
        user.permissions.createPointsOfSale = true;
        user.permissions.editPointsOfSale = true;
        user.permissions.deletePointsOfSale = true;
        user.permissions.createProducts = true;
        user.permissions.editProducts = true;
        user.permissions.deleteProducts = true;
        user.permissions.createCategories = true;
        user.permissions.editCategories = true;
        user.permissions.deleteCategories = true;
        user.permissions.createMachines = true;
        user.permissions.editMachines = true;
        user.permissions.fixMachineStock = true;
        user.permissions.deleteMachines = true;
        user.permissions.toggleMaintenanceMode = true;
        user.permissions.addRemoteCredit = true;
      }
    } else {
      user.permissions.createManagers = false;
    }
    notifyListeners();
  }

  Future<bool> warnUserAboutCreatingOperator() async {
    var tmp = false;
    await interfaceService.showDialogMessage(
      title: 'Atenção',
      message:
          'Ao desmarcar esta permissão, o seu colaborador não poderá ter a permissão de criar operadores.',
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () {
            interfaceService.goBack();
            tmp = true;
          },
        )
      ],
    );
    return tmp;
  }

  Future<bool> warnUserAboutCreatingManager() async {
    var tmp = false;
    await interfaceService.showDialogMessage(
      title: 'Atenção',
      message:
          'Ao desmarcar esta permissão, o seu colaborador não poderá ter a permissão de criar colaboradores.',
      actions: [
        DialogAction(
          title: 'Cancelar',
          onPressed: () {
            interfaceService.goBack();
          },
        ),
        DialogAction(
          title: 'Confirmar',
          onPressed: () {
            interfaceService.goBack();
            tmp = true;
          },
        )
      ],
    );
    return tmp;
  }

  void toggleCreateOperator(value) async {
    if (value) {
      var toggle = false;
      await interfaceService.showDialogMessage(
        title: 'Atenção',
        message:
            'Ao criar um colaborador que pode criar operadores, este terá, automaticamente, todas as permissões de operador.',
        actions: [
          DialogAction(
            title: 'Cancelar',
            onPressed: () {
              interfaceService.goBack();
            },
          ),
          DialogAction(
            title: 'Confirmar',
            onPressed: () {
              toggle = true;
              interfaceService.goBack();
            },
          )
        ],
      );
      if (toggle) {
        user.permissions.createOperators = true;
        user.permissions.editMachines = true;
        user.permissions.fixMachineStock = true;
        user.permissions.deleteMachines = true;
        user.permissions.toggleMaintenanceMode = true;
        user.permissions.addRemoteCredit = true;
      }
    } else {
      user.permissions.createOperators = false;
    }
    notifyListeners();
  }

  bool validateFields() {
    if (user.name == null) {
      interfaceService.showSnackBar(
          message: 'Nome é obrigatório.', backgroundColor: colors.red);
      return false;
    }

    if (user.phoneNumber != null) {
      if (user.phoneNumber.length == 14 || user.phoneNumber.length == 15) {
        if (!user.phoneNumber.contains('+55')) {
          user.phoneNumber = convertPhoneNumberToAPI(user.phoneNumber);
        }
      }
    }

    if (user.email == null) {
      interfaceService.showSnackBar(
          message: 'Email é obrigatório.', backgroundColor: colors.red);
      return false;
    }
    if (user.groupIds.isEmpty) {
      interfaceService.showSnackBar(
          message: 'O colaborador deve pertencer à pelo menos uma parceria.',
          backgroundColor: colors.red);
      return false;
    }
    return true;
  }

  Map<String, dynamic> createRequestBody() {
    var data = <String, dynamic>{};
    data['name'] = user.name;
    data['email'] = user.email;
    data['isActive'] = user.isActive;
    data['groupIds'] = user.groupIds;
    if (user.phoneNumber != null) data['phoneNumber'] = user.phoneNumber;
    data['permissions'] = {
      'listOperators': user.permissions.listOperators,
      'listManagers': user.permissions.listManagers,
      'generateReports': user.permissions.generateReports,
      'createGroups': user.permissions.createGroups,
      'editGroups': user.permissions.editGroups,
      'deleteGroups': user.permissions.deleteGroups,
      'createRoutes': user.permissions.createRoutes,
      'editRoutes': user.permissions.editRoutes,
      'deleteRoutes': user.permissions.deleteRoutes,
      'createPointsOfSale': user.permissions.createPointsOfSale,
      'editPointsOfSale': user.permissions.editPointsOfSale,
      'deletePointsOfSale': user.permissions.deletePointsOfSale,
      'createProducts': user.permissions.createProducts,
      'editProducts': user.permissions.editProducts,
      'deleteProducts': user.permissions.deleteProducts,
      'createCategories': user.permissions.createCategories,
      'editCategories': user.permissions.editCategories,
      'deleteCategories': user.permissions.deleteCategories,
      'createMachines': user.permissions.createMachines,
      'fixMachineStock': user.permissions.fixMachineStock,
      'editMachines': user.permissions.editMachines,
      'deleteMachines': user.permissions.deleteMachines,
      'createOperators': user.permissions.createOperators,
      'createManagers': user.permissions.createManagers,
      'toggleMaintenanceMode': user.permissions.toggleMaintenanceMode,
      'addRemoteCredit': user.permissions.addRemoteCredit
    };
    return data;
  }

  void updateManager() async {
    if (validateFields()) {
      var data = createRequestBody();
      data.remove('email');
      data.remove('name');
      interfaceService.showLoader();
      var response = await userProvider.editManager(data, user.id);
      interfaceService.closeLoader();
      if (response.status == Status.success) {
        interfaceService.showSnackBar(
          message: 'Colaborador editado com sucesso.',
          backgroundColor: colors.lightGreen,
        );
        interfaceService.goBack();
      } else {
        interfaceService.showSnackBar(
          message: translateError(response.data),
          backgroundColor: colors.red,
        );
      }
    }
  }

  void createManager() async {
    if (validateFields()) {
      var data = createRequestBody();
      data.remove('isActive');
      interfaceService.showLoader();
      var response = await userProvider.createManager(data);
      interfaceService.closeLoader();
      if (response.status == Status.success) {
        interfaceService.showSnackBar(
          message: 'Colaborador criado com sucesso.',
          backgroundColor: colors.lightGreen,
        );
        interfaceService.goBack();
      } else {
        interfaceService.showSnackBar(
          message: translateError(response.data),
          backgroundColor: colors.red,
        );
      }
    }
  }
}
