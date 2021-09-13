import 'package:stacked/stacked.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/interface/shared/error_translator.dart';
import '../../../core/providers/counter_types_provider.dart';
import '../../../core/services/interface_service.dart';
import '../../shared/colors.dart';
import '../../../locator.dart';

class EditCounterTypePageModel extends BaseViewModel {
  String label;
  String id;
  String type;
  final counterTypesProvider = locator<CounterTypesProvider>();

  bool validateFields() {
    if (label == null) {
      locator<InterfaceService>().showSnackBar(
          message: 'Nome é obrigatório',
          backgroundColor: locator<AppColors>().red);
      return false;
    }
    if (type == null) {
      locator<InterfaceService>().showSnackBar(
          message: 'Tipo é obrigatório',
          backgroundColor: locator<AppColors>().red);
      return false;
    }
    return true;
  }

  Future editCounterType() async {
    if (validateFields()) {
      locator<InterfaceService>().showLoader();
      var response =
          await counterTypesProvider.editCounterType({'label': label}, id);
      if (response.status == Status.success) {
        locator<InterfaceService>().showSnackBar(
          message: 'Tipo de contador editado com sucesso.',
          backgroundColor: locator<AppColors>().lightGreen,
        );
        locator<InterfaceService>().goBack();
      } else {
        locator<InterfaceService>().showSnackBar(
            message: translateError(response.data),
            backgroundColor: locator<AppColors>().red);
      }
      locator<InterfaceService>().closeLoader();
    }
  }

  Future createCounterType() async {
    if (validateFields()) {
      locator<InterfaceService>().showLoader();
      var response = await counterTypesProvider
          .createCounterType({'label': label, 'type': type});
      if (response.status == Status.success) {
        locator<InterfaceService>().showSnackBar(
          message: 'Tipo de contador criado com sucesso.',
          backgroundColor: locator<AppColors>().lightGreen,
        );
        locator<InterfaceService>().goBack();
      } else {
        locator<InterfaceService>().showSnackBar(
            message: translateError(response.data),
            backgroundColor: locator<AppColors>().red);
      }
      locator<InterfaceService>().closeLoader();
    }
  }
}
