import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../../src/interface/shared/validators.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';

import '../../../locator.dart';

class EditOperatorPageModel extends BaseViewModel {
  User user = User.op();
  final groupsProvider = locator<GroupsProvider>();
  final interfaceService = locator<InterfaceService>();
  final colors = locator<AppColors>();
  final userProvider = locator<UserProvider>();

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

  bool validateFields() {
    if (user.name == null) {
      interfaceService.showSnackBar(
          message: 'Nome é obrigatório.', backgroundColor: colors.red);
      return false;
    }
    if (user.email == null) {
      interfaceService.showSnackBar(
          message: 'Email é obrigatório.', backgroundColor: colors.red);
      return false;
    }
    if (user.groupIds.isEmpty) {
      interfaceService.showSnackBar(
          message: 'O operador deve pertencer à pelo menos uma parceria.',
          backgroundColor: colors.red);
      return false;
    }

    return true;
  }

  Map<String, dynamic> createData() {
    var data = <String, dynamic>{};
    data['name'] = user.name;
    data['email'] = user.email;
    data['groupIds'] = user.groupIds;
    data['isActive'] = user.isActive;
    if (user.phoneNumber != null) {
      if (user.phoneNumber.length > 14) {
        data['phoneNumber'] = convertPhoneNumberToAPI(user.phoneNumber);
      } else {
        data['phoneNumber'] = user.phoneNumber;
      }
    }
    data['permissions'] = {
      'editMachines': user.permissions.editMachines,
      'deleteMachines': user.permissions.deleteMachines,
      'fixMachineStock': user.permissions.fixMachineStock,
      'toggleMaintenanceMode': user.permissions.toggleMaintenanceMode,
      'addRemoteCredit': user.permissions.addRemoteCredit,
      'editCollections': user.permissions.editCollections,
      'deleteCollections': user.permissions.deleteCollections,
    };
    return data;
  }

  void createOperator() async {
    if (validateFields()) {
      var data = createData();
      data.remove('isActive');
      interfaceService.showLoader();
      var response = await userProvider.createOperator(data);
      interfaceService.closeLoader();
      if (response.status == Status.success) {
        interfaceService.goBack();
        interfaceService.showSnackBar(
          message: 'Operador criado com sucesso.',
          backgroundColor: colors.lightGreen,
        );
      } else {
        interfaceService.showSnackBar(
          message: translateError(response.data),
          backgroundColor: colors.red,
        );
      }
    }
  }

  void updateOperator() async {
    if (validateFields()) {
      var data = createData();
      data.remove('name');
      data.remove('email');
      interfaceService.showLoader();
      var response = await userProvider.editOperator(data, user.id);
      interfaceService.closeLoader();
      if (response.status == Status.success) {
        interfaceService.goBack();
        interfaceService.showSnackBar(
          message: 'Operador editado com sucesso.',
          backgroundColor: colors.lightGreen,
        );
      } else {
        interfaceService.showSnackBar(
          message: translateError(response.data),
          backgroundColor: colors.red,
        );
      }
    }
  }
}
