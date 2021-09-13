import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../core/models/group.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';

import '../../../locator.dart';

class EditGroupPageModel extends BaseViewModel {
  Group _group;
  Group get group => _group;
  set group(value) => _group = value;

  String _label;
  set label(value) {
    _label = value;
    notifyListeners();
  }

  String get label => _label;

  Future createGroup() async {
    var response =
        await locator<GroupsProvider>().createGroup({'label': _label});
    if (response.status == Status.success) {
      locator<InterfaceService>().goBack();
      locator<InterfaceService>().showSnackBar(
        message: 'Parceria criada com sucesso.',
        backgroundColor: locator<AppColors>().lightGreen,
      );
    } else {
      locator<InterfaceService>().showSnackBar(
        message: translateError(response.data),
        backgroundColor: locator<AppColors>().red,
      );
    }
  }

  Future editGroup() async {
    var response =
        await locator<GroupsProvider>().editGroup(_group.id, {'label': _label});
    if (response.status == Status.success) {
      locator<InterfaceService>().showSnackBar(
        message: 'Parceria editada com sucesso.',
        backgroundColor: locator<AppColors>().lightGreen,
      );
      locator<InterfaceService>().goBack();
    } else {
      locator<InterfaceService>().showSnackBar(
        message: translateError(response.data),
        backgroundColor: locator<AppColors>().red,
      );
    }
  }
}
